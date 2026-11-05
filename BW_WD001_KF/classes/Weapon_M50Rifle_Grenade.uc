//=============================================================================
// Weapon_M50Rifle_Grenade
//
// M50 Rifle impact grenade.
//
// Based on the original Ballistic Weapons BallisticGrenade behaviour.
//=============================================================================

class Weapon_M50Rifle_Grenade extends BallisticProjectile;

var() float ImpactDamage;
var() class<DamageType> ImpactDamageType;

var() float DampenFactor;
var() float DampenFactorParallel;
var() float PawnDampAdjust;

//=============================================================================
// GRENADE SETTINGS
//=============================================================================

var() float ArmingDelay;
var() float DetonateDelay;

var bool bM50Armed;
var bool bM50DetonationPending;
var bool bM50Detonating;
var bool bM50Initialized;


//=============================================================================
// INITIALIZATION
//=============================================================================

simulated function InitProjectile()
{
    Super.InitProjectile();

    if (bM50Initialized)
        return;

    bM50Initialized = True;

    bM50Armed = False;
    bM50DetonationPending = False;
    bM50Detonating = False;

    if (ArmingDelay > 0)
        SetTimer(ArmingDelay, False);
    else
        bM50Armed = True;
}


//=============================================================================
// TIMER
//=============================================================================

simulated function Timer()
{
    // Preserve BallisticProjectile's delayed-start handling.
    if (StartDelay > 0)
    {
        Super.Timer();
        return;
    }

    // An unarmed impact has started the detonation countdown.
    if (bM50DetonationPending)
    {
        Explode(Location, Normal(Velocity));
        return;
    }

    // Otherwise, the grenade has finished arming.
    if (!bM50Armed)
    {
        bM50Armed = True;
        return;
    }
}


//=============================================================================
// IMPACT TIMER
//=============================================================================

simulated function StartImpactDetonation()
{
    if (bM50DetonationPending || bM50Detonating)
        return;

    bM50DetonationPending = True;

    SetTimer(DetonateDelay, False);
}


//=============================================================================
// WORLD COLLISION
//=============================================================================

simulated function HitWall(Vector HitNormal, Actor Wall)
{
    local Vector VNorm;

    if (bM50Detonating || bExploded)
        return;

    // Armed grenades detonate immediately.
    if (bM50Armed)
    {
        Explode(Location, HitNormal);
        return;
    }

    // Start the timed detonation on the first impact.
    if (!bM50DetonationPending)
        StartImpactDetonation();

    // Apply reduced bounce damping against pawns.
    if (Pawn(Wall) != None)
    {
        DampenFactor *= PawnDampAdjust;
        DampenFactorParallel *= PawnDampAdjust;
    }

    bCanHitOwner = True;

    VNorm = (Velocity Dot HitNormal) * HitNormal;

    Velocity =
        -VNorm * DampenFactor +
        (Velocity - VNorm) * DampenFactorParallel;

    Speed = VSize(Velocity);

    if (Speed < 10.0)
    {
        bBounce = False;
        SetPhysics(PHYS_None);
    }
}

//=============================================================================
// ACTOR COLLISION
//=============================================================================

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    local Vector HitNormal;

    if (Other == None || bM50Detonating || bExploded)
        return;

    if (Other == Instigator || Other == Owner || Other.Base == Instigator)
        return;

    if (HitActor == Other)
        return;

    // Apply direct impact damage on the server.
    if (Role == ROLE_Authority && ImpactDamage > 0)
    {
        HitActor = Other;

        if (Instigator == None || Instigator.Controller == None)
            Other.SetDelayedDamageInstigatorController(InstigatorController);

        Other.TakeDamage
        (
            ImpactDamage,
            Instigator,
            HitLocation,
            MomentumTransfer * Normal(Velocity),
            ImpactDamageType
        );
    }

    HitNormal = Normal(HitLocation - Other.Location);

    // An armed grenade detonates on actor impact.
    if (bM50Armed)
    {
        Explode(HitLocation, HitNormal);
        return;
    }

    // An unarmed grenade bounces off the actor.
    HitWall(HitNormal, Other);
}


//=============================================================================
// LANDING
//=============================================================================

simulated function Landed(Vector HitNormal)
{
    HitWall(HitNormal, None);
}


//=============================================================================
// EXPLOSION
//=============================================================================

simulated function Explode(Vector HitLocation, Vector HitNormal)
{
    if (bM50Detonating || bExploded)
        return;

    bM50Detonating = True;

    SetTimer(0.0, False);

    Super.Explode(HitLocation, HitNormal);
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    Damage=70.000000
	DamageRadius=240.000000
	MomentumTransfer=75000.000000
	
	ImpactDamage=15.000000
	DampenFactor=0.050000
	DampenFactorParallel=0.350000
	PawnDampAdjust=0.250000
	
	ArmingDelay=0.300000
    DetonateDelay=1.000000

    ImpactManager=Class'BW_WD001_KF.Weapon_M50Rifle_GrenadeImpact'
    TrailClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_MineTrail'

    TrailOffset=(X=-8.000000)

    StaticMesh=StaticMesh'BWKF_M50_SM.pickups.M50_GrenadeProj_SM'

    Speed=2700.000000
    MaxSpeed=0.000000

    ShakeRadius=256.000000

    MyDamageType=Class'BW_WD001_KF.Weapon_M50Rifle_DTGrenade'
    MyRadiusDamageType=Class'BW_WD001_KF.Weapon_M50Rifle_DTGrenadeRadius'

    bCheckHitSurface=True
    bBounce=True

    Physics=PHYS_Falling
    bTrueBallistics=False
    bNetTemporary=False
}