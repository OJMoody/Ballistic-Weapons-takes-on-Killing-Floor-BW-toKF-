//=============================================================================
// Weapon_M763Shotgun_GasSlugProj 
//
// KF1 port of the UT2004 Ballistic Weapons M763 tear-gas projectile.
//=============================================================================

class Weapon_M763Shotgun_GasSlugProj extends BallisticProjectile;

//=============================================================================
// M763 IMPACT DAMAGE
//=============================================================================

var() int ImpactDamage;
var() class<DamageType> ImpactDamageType;


//=============================================================================
// EXPLODE
//=============================================================================

simulated function Explode(Vector HitLocation, Vector HitNormal)
{
	local int Surf;
	local Actor Wall;
	local Weapon_M763Shotgun_GasCloudControl C;

	if (bExploded)
		return;

	if (ShakeRadius > 0)
		ShakeView(HitLocation);

	if (Role == ROLE_Authority)
	{
		if (bCheckHitSurface)
			CheckSurface(HitLocation, HitNormal, Surf, Wall);

		if (ImpactManager != None)
			ImpactManager.static.StartSpawn(HitLocation, HitNormal, Surf, self);

		BlowUp(HitLocation);

		C = Spawn(class'Weapon_M763Shotgun_GasCloudControl', Self,, HitLocation - HitNormal * 2);

		if (C != None)
			C.Instigator = Instigator;
	}

	bExploded = True;
	Destroy();
}


//=============================================================================
// HIT WALL
//=============================================================================

simulated event HitWall(Vector HitNormal, Actor Wall)
{
	if (Role == ROLE_Authority)
		Explode(Location, HitNormal);
}


//=============================================================================
// PROCESS TOUCH
//=============================================================================

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Other == None)
		return;

	if (!bCanHitOwner && (Other == Instigator || Other == Owner))
		return;

	if (Role == ROLE_Authority && Other != HitActor)
	{
		HitActor = Other;

		if (ImpactDamage > 0 && Other != Level)
		{
			if (Instigator == None || Instigator.Controller == None)
				Other.SetDelayedDamageInstigatorController(InstigatorController);

			Other.TakeDamage
			(
				ImpactDamage,
				Instigator,
				HitLocation,
				vect(0,0,0),
				ImpactDamageType
			);
		}

		Explode(HitLocation, Normal(HitLocation - Other.Location));
	}
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	ImpactDamage=80
	ImpactDamageType=Class'BW_WD001_KF.Weapon_M763Shotgun_DamTypeM763Gas'

	MyRadiusDamageType=Class'BW_WD001_KF.Weapon_M763Shotgun_DamTypeM763Gas'
	MyDamageType=Class'BW_WD001_KF.Weapon_M763Shotgun_DamTypeM763Gas'

	AccelSpeed=50000.000000
	TrailOffset=(X=-8.000000)

	Speed=200.000000
	MaxSpeed=100000.000000

	Damage=90.000000
	DamageRadius=96.000000
	MomentumTransfer=0.000000

	MotionBlurRadius=130.000000

	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'BWKF_M763_SM.pickups.M763_GasSlugProj_SM'
}