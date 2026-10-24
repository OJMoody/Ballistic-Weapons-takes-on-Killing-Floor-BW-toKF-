class Utility_G28Aerosol_PrimaryFire extends BallisticHandGrenadeFire;

defaultproperties
{
    ProjectileClass=Class'BW_WD000_KF.Utility_G28Aerosol_Projectile'
    AmmoClass=Class'BW_WD000_KF.Utility_G28Aerosol_Ammo'

	GrenadePrepareAnimation="PrepThrow"
    GrenadeThrowAnimation="Throw"
	
	GrenadeBaseThrowSpeed=400.000000
    GrenadeThrowChargeTime=1.000000
    GrenadeMaxThrowBonus=0.50000

    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}