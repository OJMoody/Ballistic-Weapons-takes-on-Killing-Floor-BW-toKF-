class Weapon_M46A1Rifle_StickyMine extends Weapon_M46A1Rifle_MineBase;

var bool bDetonated;
var Pawn StuckPawn;

var() float StickyDamage;
var() float StickyDamageRadius;

function AttachToTarget(Actor Target, Vector HitLocation, Vector HitVelocity)
{
    local float BoneDist;

    if (Role != ROLE_Authority || Target == None)
        return;

    StuckPawn = Pawn(Target);

    SetPhysics(PHYS_None);
    bHardAttach = True;

    if (StuckPawn != None && StuckPawn.DrawType == DT_Mesh)
    {
        StuckPawn.AttachToBone(
            Self,
            StuckPawn.GetClosestBone(HitLocation, HitVelocity, BoneDist)
        );
    }
    else
    {
        SetBase(Target);
    }

    SetLocation(HitLocation);
    SetTimer(1.0, False);
}

function Timer()
{
    if (Role != ROLE_Authority || bDetonated)
        return;

    DetonateStickyMine();
}

function DetonateStickyMine()
{
    if (Role != ROLE_Authority || bDetonated)
        return;

    bDetonated = True;

    if (StuckPawn != None && StuckPawn.Health > 0)
    {
        StuckPawn.TakeDamage(
            StickyDamage,
            Instigator,
            StuckPawn.Location,
            vect(0,0,0),
            MyDamageType
        );
    }

    SpawnMineExplosionEffects();

    if (StickyDamageRadius > 0)
    {
        HurtRadius(
            StickyDamage,
            StickyDamageRadius,
            MyRadiusDamageType,
            MomentumTransfer,
            Location
        );
    }

    Destroy();
}

simulated function bool IsStationary()
{
    return True;
}

defaultproperties
{
    StaticMesh=StaticMesh'BWKF_M46_SM.pickups.M46_GrenadeProj_Main'
    ShakeRadius=512.000000
    MotionBlurRadius=384.000000
    MotionBlurFactor=3.000000
    MotionBlurTime=4.000000
    StickyDamage=100.000000
    StickyDamageRadius=300.000000
    Damage=100.000000
    DamageRadius=300.000000
    MomentumTransfer=50000.000000

    MyDamageType=None
    MyRadiusDamageType=None

    CullDistance=2500.000000
    bNetTemporary=False
    Physics=PHYS_None
    LifeSpan=0.000000
    DrawScale=0.450000
    bUnlit=False

    CollisionRadius=16.000000
    CollisionHeight=16.000000
    bCollideWorld=False
    bProjTarget=True
    bNetNotify=True
}