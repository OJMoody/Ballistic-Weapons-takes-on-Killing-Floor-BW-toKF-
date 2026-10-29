class Weapon_M46A1Rifle_MineProjectile extends BallisticProjectile;

var Actor StuckActor;
var bool bPlaced;

var Vector M46LastLoggedLocation;
var float M46LogElapsed;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    Log("M46 DEBUG: PostNetBeginPlay reached.");
    Log("M46 DEBUG: Velocity="$Velocity);
    Log("M46 DEBUG: Acceleration="$Acceleration);
    Log("M46 DEBUG: Physics="$Physics);
    Log("M46 DEBUG: Location="$Location);
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    M46LogElapsed += DeltaTime;

    if (M46LogElapsed >= 0.5)
    {
        M46LogElapsed = 0.0;

        Log("M46 PROJECTILE: Location="$Location);
        Log("M46 PROJECTILE: Velocity="$Velocity);
        Log("M46 PROJECTILE: Physics="$Physics);
    }
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
    Log("M46 DEBUG: ProcessTouch Other="$Other);
	Log("M46 DEBUG: ProcessTouch Location="$Location);
	Log("M46 DEBUG: ProcessTouch Velocity="$Velocity);
	
	if (Role != ROLE_Authority || bPlaced)
        return;

    if (Other == None || Other == Instigator)
        return;

    // Ignore the firing player's attached actors.
    if (Other.Owner == Instigator)
        return;

    // Ignore players, but allow Zeds to trigger sticky-mine placement.
    if (Pawn(Other) != None && KFMonster(Other) == None)
        return;

    if (KFMonster(Other) != None)
    {
        StuckActor = Other;
        DoDamage(Other, HitLocation);
        PlaceMine(HitLocation, Normal(HitLocation - Other.Location));
    }
}

simulated event HitWall(Vector HitNormal, Actor Wall)
{
    Log("M46 DEBUG: HitWall called. Wall="$Wall);
    Log("M46 DEBUG: HitWall Location="$Location);
    Log("M46 DEBUG: HitWall Velocity="$Velocity);
    Log("M46 DEBUG: HitWall Normal="$HitNormal);

    if (Role != ROLE_Authority)
        return;

    if (bPlaced)
        return;

    // Ignore player pawns.
    if (Pawn(Wall) != None && KFMonster(Wall) == None)
        return;

    // Only Zeds should receive sticky mines.
    if (KFMonster(Wall) != None)
        StuckActor = Wall;

    // Preserve the original placement flow.
    PlaceMine(Location, HitNormal);
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

    Log("M46 PROJECTILE: PlaceMine called. StuckActor="$StuckActor$" HitLocation="$HitLocation);

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

        Log("M46 PROJECTILE: Surface trace result="$HitSurface);
        Log("M46 PROJECTILE: Surface normal="$SurfaceNormal);

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
            Log("M46 PROJECTILE: Proximity mine spawned.");
        }
        else
            Log("M46 PROJECTILE: Proximity mine spawn FAILED.");
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
            Log("M46 PROJECTILE: Sticky mine spawned.");
        }
        else
            Log("M46 PROJECTILE: Sticky mine spawn FAILED.");
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