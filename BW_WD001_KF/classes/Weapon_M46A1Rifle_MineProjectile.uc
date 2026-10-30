class Weapon_M46A1Rifle_MineProjectile extends BallisticProjectile;

var Actor StuckActor;
var bool bPlaced;

var() int ZedImpactDamage;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
    local Vector HitNormal;
    local float OriginalDamage;

    if (Role != ROLE_Authority || bPlaced)
        return;

    if (Other == None || Other == Instigator)
        return;

    if (Other.Owner == Instigator)
        return;

    // Zeds take a small amount of impact damage before the mine bounces.
    if (KFMonster(Other) != None)
    {
        if (ZedImpactDamage > 0)
        {
            OriginalDamage = Damage;
            Damage = ZedImpactDamage;
            DoDamage(Other, HitLocation);
            Damage = OriginalDamage;
        }

        HitNormal = Normal(Location - Other.Location);

        if (VSize(HitNormal) < 0.1)
            HitNormal = Normal(-Velocity);

        // Retain only 25% of the original velocity.
        Velocity = MirrorVectorByNormal(Velocity, HitNormal) * 0.25;

        SetLocation(
            Other.Location +
            HitNormal * (Other.CollisionRadius + CollisionRadius + 8.0)
        );

        SetRotation(Rotator(Velocity));
    }
}

simulated event HitWall(Vector HitNormal, Actor Wall)
{
    if (Role != ROLE_Authority || bPlaced)
        return;

    // Never attach mines to pawns.
    if (Pawn(Wall) != None)
        return;

    PlaceMine(Location, HitNormal);
}

simulated event Landed(Vector HitNormal)
{
    HitWall(HitNormal, None);
}

function PlaceMine(Vector HitLocation, Vector HitNormal)
{
    local Actor HitSurface;
    local Vector TraceStart, TraceEnd;
    local Vector SurfaceLocation, SurfaceNormal;
    local Rotator MineRotation;
    local Weapon_M46A1Rifle_ProximityMine ProximityMine;
    local Weapon_M46A1Rifle_StickyMine StickyMine;

    if (Role != ROLE_Authority)
        return;

    if (bPlaced)
        return;

    bPlaced = True;

    if (StuckActor == None)
    {
        TraceStart = HitLocation + Normal(HitNormal) * 16.0;
        TraceEnd = HitLocation - Normal(HitNormal) * 128.0;

        HitSurface = Trace(
            SurfaceLocation,
            SurfaceNormal,
            TraceEnd,
            TraceStart,
            False
        );

        if (HitSurface == None)
        {
            Destroy();
            return;
        }

        if (!HitSurface.bWorldGeometry && Mover(HitSurface) == None)
        {
            Destroy();
            return;
        }

        SurfaceLocation += SurfaceNormal * 5.0;
        SurfaceNormal = -SurfaceNormal;
    }
    else
    {
        HitSurface = StuckActor;
        SurfaceLocation = HitLocation;
        SurfaceNormal = Normal(Velocity);
    }

    MineRotation = Rotator(SurfaceNormal);
    MineRotation.Roll = Rand(65536);

    if (StuckActor == None)
    {
        ProximityMine = Spawn(
            class'Weapon_M46A1Rifle_ProximityMine',
            Instigator,
            ,
            SurfaceLocation,
            MineRotation
        );

        if (ProximityMine != None)
        {
            ProximityMine.Instigator = Instigator;
            ProximityMine.InstigatorController = InstigatorController;
            ProximityMine.SetBase(HitSurface);

            if (ProximityMine.AttachSound != None)
                ProximityMine.PlaySound(ProximityMine.AttachSound,, 1.0,, 256.0);
        }
    }
    else
    {
        StickyMine = Spawn(
            class'Weapon_M46A1Rifle_StickyMine',
            Instigator,
            ,
            SurfaceLocation,
            MineRotation
        );

        if (StickyMine != None)
        {
            StickyMine.Instigator = Instigator;
            StickyMine.InstigatorController = InstigatorController;
            StickyMine.AttachToTarget(StuckActor, SurfaceLocation, Velocity);

            if (StickyMine.AttachSound != None)
                StickyMine.PlaySound(StickyMine.AttachSound,, 1.0,, 256.0);
        }
    }

    Destroy();
}

function bool IsIgnoredTouchActor(Actor Other)
{
    if (Other == None)
        return True;

    if (Other == Instigator)
        return True;

    if (Other.Owner == Instigator)
        return True;

    return False;
}

simulated function SpawnImpactEffect(Vector HitLocation, Vector HitNormal)
{
    if (ImpactManager != None)
        ImpactManager.static.StartSpawn(HitLocation, HitNormal, 0, Instigator);
}

defaultproperties
{
    bAlwaysTick=True
    ZedImpactDamage=10
    ImpactManager=Class'BW_WD001_KF.Weapon_M46A1Rifle_Impact'
    TrailClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_MineTrail'
    TrailOffset=(X=-8.000000)
    StaticMesh=StaticMesh'BWKF_M46_SM.pickups.M46_GrenadeProj_Main'
    ShakeRadius=512.000000
    MotionBlurRadius=384.000000
    MotionBlurFactor=3.000000
    MotionBlurTime=4.000000
    Speed=2700.000000
    MyDamageType=None
    DrawScale=0.450000
    MaxSpeed=0.000000
    bNetTemporary=False
    Physics=PHYS_Falling
    bTrueBallistics=False
}