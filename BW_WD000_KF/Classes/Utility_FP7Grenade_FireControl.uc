class Utility_FP7Grenade_FireControl extends Actor;

const MAX_FIRE_SPOTS = 40;

#exec OBJ LOAD FILE=BWKF_FP7_SN.uax

struct HitPawnInfo
{
    var Pawn HitPawn;
    var float HitTime;
};

var() float DamageRadius;
var float Damage;
var float BaseDamage;

var vector GroundFireSpots[MAX_FIRE_SPOTS];
var array<HitPawnInfo> HitPawnData;
var array<Utility_FP7Grenade_GroundFire> Fires;

var bool bClientFiresSpawned;

replication
{
    reliable if (Role == ROLE_Authority)
        GroundFireSpots;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
        Initialize();
}

//=============================================================================
// CLEANUP
//=============================================================================

function Reset()
{
    Destroy();
}

//=============================================================================
// PAWN DAMAGE TRACKING
// Prevent overlapping fire patches from damaging the same pawn too often.
//=============================================================================

function int FindIndex(Pawn Sought)
{
    local int i;

    for (i = 0; i < HitPawnData.Length && HitPawnData[i].HitPawn != Sought; i++);

    if (i == HitPawnData.Length)
    {
        HitPawnData.Length = i + 1;
        HitPawnData[i].HitPawn = Sought;
    }

    return i;
}

function TryDamage(Pawn Victim, float Interval, class<DamageType> DamageType)
{
    local int Index;

    if (Victim == None)
        return;

    Index = FindIndex(Victim);

    if (HitPawnData[Index].HitTime + Interval < Level.TimeSeconds
        || HitPawnData[Index].HitTime == 0)
    {
        HitPawnData[Index].HitTime = Level.TimeSeconds;

        if (Instigator != None)
            class'BallisticDamageType'.static.GenericHurt(Victim, Damage, Instigator, Victim.Location, vect(0,0,0), DamageType);
    }
}

//=============================================================================
// INITIALIZATION
//=============================================================================

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
}

simulated function Initialize()
{
    local int i;
    local vector Start, End, HitLoc, HitNorm;
    local Actor T, A;
    local KFHumanPawn Human;
    local Utility_FP7Grenade_GroundFire GF;
    local Utility_FP7Grenade_ActorBurner Burner;
	
	PlaySound(Sound'BWKF_FP7_SN.FP7.FP7Ignition',, 1.0,, DamageRadius);

    // Apply initial damage and ignite nearby human players.
    foreach VisibleCollidingActors(class'Actor', A, DamageRadius, Location)
    {
        Human = KFHumanPawn(A);

        if (Human != None)
        {
            Burner = Spawn(class'BW_WD000_KF.Utility_FP7Grenade_ActorBurner', self,, Human.Location);

            if (Burner != None)
            {
                Burner.Instigator = Instigator;
                Burner.Initialize(Human);
            }
        }

        class'BallisticDamageType'.static.GenericHurt(
            A,
            (1.0 - (VSize(A.Location - Location) / DamageRadius)) * BaseDamage,
            Instigator,
            A.Location,
            Normal(A.Location - Location) * 500,
            class'BW_WD000_KF.Utility_FP7Grenade_DamType'
        );
    }

    // Only the server creates authoritative fire patches.
    if (Level.NetMode == NM_Client)
        return;

    Start = Location + vect(0,0,8);

    for (i = 0; i < MAX_FIRE_SPOTS; i++)
    {
        End = VRand();
        End.Z = Abs(End.Z);
        End = Start + End * DamageRadius * 0.7;

        T = Trace(HitLoc, HitNorm, End, Start,, vect(6,6,6));

        if (T == None)
            HitLoc = End;

        GF = Spawn(class'BW_WD000_KF.Utility_FP7Grenade_GroundFire', self,, HitLoc, rot(0,0,0));

        if (GF != None)
        {
            GF.Velocity = HitLoc - Location;
            GF.Instigator = Instigator;
            GF.FireControl = self;

            GroundFireSpots[i] = HitLoc;
        }
    }
}

//=============================================================================
// CLIENT FIRE PATCH REPLICATION
//=============================================================================

simulated function PostNetReceive()
{
    local int i;
    local Utility_FP7Grenade_GroundFire GF;

    if (Level.NetMode != NM_Client || bClientFiresSpawned)
        return;

    for (i = 0; i < ArrayCount(GroundFireSpots); i++)
    {
        if (GroundFireSpots[i] != vect(0,0,0))
        {
            GF = Spawn(class'BW_WD000_KF.Utility_FP7Grenade_GroundFire', self,, GroundFireSpots[i], rot(0,0,0));

            if (GF != None)
                GF.Velocity = GroundFireSpots[i] - Location;
        }
    }

    bClientFiresSpawned = True;
}

//=============================================================================
// TRACK GROUND FIRE ACTORS
//=============================================================================

simulated function GainedChild(Actor A)
{
    if (Utility_FP7Grenade_GroundFire(A) != None)
        Fires[Fires.Length] = Utility_FP7Grenade_GroundFire(A);
}

simulated function LostChild(Actor A)
{
    local int i;

    if (Utility_FP7Grenade_GroundFire(A) == None)
        return;

    for (i = 0; i < Fires.Length && Fires[i] != A; i++);

    if (i < Fires.Length)
        Fires.Remove(i, 1);
}

//=============================================================================
// DEFAULTS
//=============================================================================

defaultproperties
{	
	DamageRadius=256.000000
    Damage=30.000000
    BaseDamage=40.000000

    bHidden=True
    bAlwaysRelevant=True
    RemoteRole=ROLE_SimulatedProxy
}