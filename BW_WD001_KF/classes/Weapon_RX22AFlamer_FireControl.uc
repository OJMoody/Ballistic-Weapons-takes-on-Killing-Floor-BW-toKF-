class Weapon_RX22AFlamer_FireControl extends Info;

// All fuel patches and fires currently managed by this controller.
var array<BW_FuelPatch> GasNodes;
var array<Weapon_RX22AFlamer_SurfaceFire> GroundFires;

var array<struct SingeVictim
{
    var Pawn Vic;
    var int Burns;
    var float NextReduceTime;
}> SingeVictims;

struct FlameHit
{
    var Pawn Instigator;
    var vector HitLoc;
    var vector HitNorm;
    var float HitTime;
    var Actor HitActor;
};

var array<FlameHit> FlameHits;

struct SingeSpot
{
    var vector Loc;
    var int Hits;
    var Weapon_RX22AFlamer_SurfaceFire Fire;
};

var array<SingeSpot> SingeSpots;


// Server-side damage handling for all ground fires.
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
        SetTimer(0.4, true);
}

function Timer()
{
    local int i, k;
    local Actor Other;
    local array<Actor> Served;
    local vector Offset;
    local float XYDist;

    for (i = 0; i < GroundFires.Length; i++)
    {
        if (GroundFires[i] == None)
            continue;

        foreach CollidingActors(class'Actor', Other, 256, GroundFires[i].Location)
        {
            if (Other == None ||
                (Pawn(Other) == None && BW_FuelPatch(Other) == None))
                continue;

            Offset = Other.Location - GroundFires[i].Location;
            XYDist = VSize(Offset * vect(1,1,0));

            // Check whether the actor overlaps the fire's damage area.
            if (XYDist > GroundFires[i].CollisionRadius + Other.CollisionRadius ||
                Abs(Offset.Z) > GroundFires[i].CollisionHeight + Other.CollisionHeight)
                continue;

            // Avoid applying damage more than once per timer cycle.
            for (k = 0; k < Served.Length; k++)
            {
                if (Served[k] == Other)
                    break;
            }

            if (k >= Served.Length)
            {
                GroundFires[i].Toast(Other);
                Served[Served.Length] = Other;
            }
        }
    }
}


// Spawn a projectile and register its delayed flame hit.
simulated function FireShot(vector Start, vector End, float Dist, bool bHit, vector HitNorm, Pawn InstigatedBy, Actor HitActor)
{
    local Weapon_RX22AFlamer_Projectile Proj;
    local int i;

    Proj = Spawn(class'Weapon_RX22AFlamer_Projectile', InstigatedBy,, Start, Rotator(End - Start));

    if (Proj != None)
    {
        Proj.Instigator = InstigatedBy;
        Proj.FireControl = self;
        Proj.InitFlame(End);
    }

    if (bHit)
    {
        i = FlameHits.Length;
        FlameHits.Length = i + 1;

        FlameHits[i].Instigator = InstigatedBy;
        FlameHits[i].HitLoc = End;
        FlameHits[i].HitNorm = HitNorm;
        FlameHits[i].HitTime = Level.TimeSeconds + Dist / 3600;
        FlameHits[i].HitActor = HitActor;
    }
}


// Increment singe count for a pawn and possibly start an actor fire.
function FireSinge(Pawn P, Pawn InstigatedBy)
{
    local BW_FuelPatch Patch;
    local int i;

    if (HasBurner(P, Patch))
        Patch.AddFuel(0.5);
    else
    {
        for (i = 0; i < SingeVictims.Length; i++)
        {
            if (SingeVictims[i].Vic == P)
            {
                SingeVictims[i].NextReduceTime = Level.TimeSeconds + 2.0;
                SingeVictims[i].Burns++;

                if (SingeVictims[i].Burns > 10)
                    MakeNewBurner(P, 5, InstigatedBy);

                return;
            }
        }

        SingeVictims.Length = i + 1;
        SingeVictims[i].NextReduceTime = Level.TimeSeconds + 2.0;
        SingeVictims[i].Vic = P;
        SingeVictims[i].Burns = 1;
    }
}


// Process a delayed flame hit.
simulated function DoFlameHit(FlameHit Hit)
{
    local int i;
    local BW_FuelPatch Other;

    BurnRadius(4, 256, class'Weapon_RX22AFlamer_DTBurned', 0, Hit.HitLoc, Hit.Instigator);

    if (NearFire(Hit.HitLoc, Other))
        Other.AddFuel(0.5);
    else
    {
        for (i = 0; i < SingeSpots.Length; i++)
        {
            if (VSize(SingeSpots[i].Loc - Hit.HitLoc) < 128)
            {
                SingeSpots[i].Hits++;

                if (SingeSpots[i].Hits > 3)
                {
                    MakeNewFire(Hit.HitLoc + Hit.HitNorm * 32, Hit.HitNorm, Hit.Instigator, Hit.HitActor);
                    SingeSpots.Remove(i, 1);
                    return;
                }

                break;
            }
        }

        if (i >= SingeSpots.Length)
        {
            i = SingeSpots.Length;
            SingeSpots.Length = i + 1;
            SingeSpots[i].Loc = Hit.HitLoc;
            SingeSpots[i].Hits = 1;

            class'Weapon_RX22AFlamer_IMScorch'.static.StartSpawn(Hit.HitLoc, Hit.HitNorm, 0, self);
        }
    }
}


// Create a surface fuel deposit or add fuel to an existing one.
function SprayWall(vector Loc, vector Norm, Pawn InstigatedBy, Actor HitActor)
{
    local BW_FuelPatch Other;

    if (NearPool(Loc, Other))
        Other.AddFuel(1);
    else
        MakeNewPool(Loc, Norm, InstigatedBy, HitActor);
}


// Create an airborne fuel deposit or add fuel to an existing one.
function SprayAir(vector Loc, Pawn InstigatedBy)
{
    local BW_FuelPatch Other;

    if (NearCloud(Loc, Other))
        Other.AddFuel(1.5);
    else
        MakeNewCloud(Loc, InstigatedBy);
}


function SpraySoak(Actor Other, Pawn InstigatedBy, optional float FuelAmount)
{
    local BW_FuelPatch Patch;
    local vector Dummy;

    if (FuelAmount == 0)
        FuelAmount = 1;

    if (HasSoak(Other, Patch))
        Patch.AddFuel(FuelAmount);
    else if (Pawn(Other) != None &&
        (KFHumanPawn(Other) == None ||
        Level.Game.ReduceDamage(10, KFHumanPawn(Other), InstigatedBy, Other.Location, Dummy, class'Weapon_RX22AFlamer_DTBurned') > 0))
        MakeNewSoaker(Other, InstigatedBy);
}


// Remove a patch from the main list.
function PatchRemove(Emitter Other)
{
    local int i;

    i = GetNodeIndex(Other);

    if (i > -1)
        GasNodes.Remove(i, 1);

    if (Weapon_RX22AFlamer_SurfaceFire(Other) != None)
    {
        for (i = 0; i < GroundFires.Length && Other != GroundFires[i]; i++);

        if (i < GroundFires.Length)
            GroundFires.Remove(i, 1);
    }
}


// Replace an existing fuel patch with another patch.
function PatchReplace(BW_FuelPatch OldPatch, BW_FuelPatch NewPatch)
{
    GasNodes[GetNodeIndex(OldPatch)] = NewPatch;

    if (Weapon_RX22AFlamer_SurfaceFire(NewPatch) != None)
        GroundFires[GroundFires.Length] = Weapon_RX22AFlamer_SurfaceFire(NewPatch);
}


// Process delayed flame hits and reduce singe counts.
event Tick(float DT)
{
    local int i;

    Super.Tick(DT);

    for (i = 0; i < FlameHits.Length; i++)
    {
        if (Level.TimeSeconds >= FlameHits[i].HitTime)
        {
            DoFlameHit(FlameHits[i]);
            FlameHits.Remove(i, 1);
            i--;
        }
    }

    for (i = 0; i < SingeVictims.Length; i++)
    {
        if (Level.TimeSeconds >= SingeVictims[i].NextReduceTime)
        {
            SingeVictims[i].Burns--;

            if (SingeVictims[i].Burns < 1)
            {
                SingeVictims.Remove(i, 1);
                i--;
            }
            else
                SingeVictims[i].NextReduceTime = Level.TimeSeconds + 0.25;
        }
    }
}


// Apply flame damage to nearby actors.
simulated function BurnRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, Pawn InstigatedBy, optional Actor Victim)
{
    local Actor Victims;
    local float DamageScale, Dist;
    local vector Dir, Dummy;

    if (bHurtEntry)
        return;

    bHurtEntry = true;

    foreach VisibleCollidingActors(class'Actor', Victims, DamageRadius, HitLocation)
    {
        if ((Victims != self) &&
            (Victims.Role == ROLE_Authority) &&
            (!Victims.IsA('FluidSurfaceInfo')) &&
            Victims != Victim)
        {
            Dir = Victims.Location - HitLocation;
            Dist = FMax(1, VSize(Dir));
            Dir = Dir / Dist;

            DamageScale = 1 - FMax(0, (Dist - Victims.CollisionRadius) / DamageRadius);

            if (KFHumanPawn(Victims) != None &&
                Level.Game.ReduceDamage(DamageScale * DamageAmount, KFHumanPawn(Victims), InstigatedBy, HitLocation, Dummy, DamageType) <= 0)
                continue;

            if (Pawn(Victims) != None && FRand() - 0.4 < DamageScale)
                FireSinge(Pawn(Victims), InstigatedBy);

            class'BallisticDamageType'.static.GenericHurt
            (
                Victims,
                DamageScale * DamageAmount,
                InstigatedBy,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,
                (DamageScale * Momentum * Dir),
                DamageType
            );
        }
    }

    bHurtEntry = false;
}


// Find the index of a patch in the main list.
function int GetNodeIndex(Emitter Other)
{
    local int i;

    for (i = 0; i < GasNodes.Length; i++)
    {
        if (GasNodes[i] == None)
        {
            GasNodes.Remove(i, 1);
            i--;
            continue;
        }

        if (GasNodes[i] == Other)
            return i;
    }

    return -1;
}


function bool HasSoak(Actor Other, out BW_FuelPatch Patch)
{
    local int i;

    for (i = 0; i < GasNodes.Length; i++)
    {
        if (GasNodes[i] != None &&
            (GasNodes[i].Base == Other ||
            (Weapon_RX22AFlamer_ActorFire(GasNodes[i]) != None &&
            Weapon_RX22AFlamer_ActorFire(GasNodes[i]).Victim == Other)))
        {
            Patch = GasNodes[i];
            return true;
        }
    }

    return false;
}


function bool HasBurner(Actor Other, out BW_FuelPatch Patch)
{
    local int i;

    for (i = 0; i < GasNodes.Length; i++)
    {
        if (GasNodes[i] != None &&
            Weapon_RX22AFlamer_ActorFire(GasNodes[i]) != None &&
            (Weapon_RX22AFlamer_ActorFire(GasNodes[i]).Victim == Other ||
            GasNodes[i].Base == Other))
        {
            Patch = GasNodes[i];
            return true;
        }
    }

    return false;
}


// Spawn a new surface fire.
function MakeNewFire(vector Loc, vector Norm, Pawn InstigatedBy, Actor HitActor)
{
    GasNodes[GasNodes.Length] = Spawn(class'Weapon_RX22AFlamer_SurfaceFire', InstigatedBy,, Loc, Rotator(Norm));

    GroundFires[GroundFires.Length] = Weapon_RX22AFlamer_SurfaceFire(GasNodes[GasNodes.Length - 1]);

    if (Weapon_RX22AFlamer_SurfaceFire(GasNodes[GasNodes.Length - 1]) != None)
    {
        Weapon_RX22AFlamer_SurfaceFire(GasNodes[GasNodes.Length - 1]).GasControl = self;

        if (HitActor != None)
            Weapon_RX22AFlamer_SurfaceFire(GasNodes[GasNodes.Length - 1]).SetBase(HitActor);
    }
}


// Spawn a new surface fuel pool.
function MakeNewPool(vector Loc, vector Norm, Pawn InstigatedBy, Actor HitActor)
{
    GasNodes[GasNodes.Length] = Spawn(class'Weapon_RX22AFlamer_GasPatch', InstigatedBy,, Loc, Rotator(Norm));

    if (GasNodes[GasNodes.Length - 1] != None &&
        Weapon_RX22AFlamer_GasPatch(GasNodes[GasNodes.Length - 1]) != None)
    {
        Weapon_RX22AFlamer_GasPatch(GasNodes[GasNodes.Length - 1]).GasControl = self;

        if (HitActor != None)
            Weapon_RX22AFlamer_GasPatch(GasNodes[GasNodes.Length - 1]).SetBase(HitActor);
    }
}


// Spawn a new airborne fuel cloud.
function MakeNewCloud(vector Loc, Pawn InstigatedBy)
{
    GasNodes[GasNodes.Length] = Spawn(class'Weapon_RX22AFlamer_GasCloud', InstigatedBy,, Loc);
    Weapon_RX22AFlamer_GasCloud(GasNodes[GasNodes.Length - 1]).GasControl = self;
}


// Spawn a new actor-attached fuel deposit.
function MakeNewSoaker(Actor Other, Pawn InstigatedBy)
{
    GasNodes[GasNodes.Length] = Spawn(class'Weapon_RX22AFlamer_GasSoak', InstigatedBy,, Other.Location, Other.Rotation);

    Weapon_RX22AFlamer_GasSoak(GasNodes[GasNodes.Length - 1]).GasControl = self;
    Weapon_RX22AFlamer_GasSoak(GasNodes[GasNodes.Length - 1]).SetBase(Other);
}


// Spawn a new actor fire.
function MakeNewBurner(Actor Other, int Fuel, Pawn InstigatedBy)
{
    local Weapon_RX22AFlamer_ActorFire PF;

    PF = Spawn(class'Weapon_RX22AFlamer_ActorFire', InstigatedBy,, Other.Location, Other.Rotation);
    PF.SetFuel(Fuel);
    PF.Initialize(Other);

    GasNodes[GasNodes.Length] = PF;
    PF.GasControl = self;
}


// Find a nearby fire.
function bool NearFire(vector Loc, out BW_FuelPatch Other)
{
    local int i;

    for (i = 0; i < GasNodes.Length; i++)
    {
        if (GasNodes[i] != None && VSize(GasNodes[i].Location - Loc) < GasNodes[i].Extent)
        {
            Other = GasNodes[i];
            return true;
        }
    }

    return false;
}


// Find a nearby gas pool.
function bool NearPool(vector Loc, out BW_FuelPatch Other)
{
    local int i;

    for (i = 0; i < GasNodes.Length; i++)
    {
        if (GasNodes[i] != None && VSize(GasNodes[i].Location - Loc) < GasNodes[i].Extent)
        {
            Other = GasNodes[i];
            return true;
        }
    }

    return false;
}


// Find a nearby gas cloud.
function bool NearCloud(vector Loc, out BW_FuelPatch Other)
{
    local int i;

    for (i = 0; i < GasNodes.Length; i++)
    {
        if (GasNodes[i] != None && VSize(GasNodes[i].Location - Loc) < GasNodes[i].Extent)
        {
            Other = GasNodes[i];
            return true;
        }
    }

    return false;
}


defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bNetNotify=True
}