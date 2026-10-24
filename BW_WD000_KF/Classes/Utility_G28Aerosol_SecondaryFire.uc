class Utility_G28Aerosol_SecondaryFire extends BallisticHandGrenadeFire;

defaultproperties
{
    ProjectileClass=Class'BW_WD000_KF.Utility_G28Aerosol_Projectile'
    AmmoClass=Class'BW_WD000_KF.Utility_G28Aerosol_Ammo'

	GrenadePrepareAnimation="PrepRoll"
    GrenadeThrowAnimation="Roll"
	
	GrenadeBaseThrowSpeed=200.000000
    GrenadeThrowChargeTime=1.500000
    GrenadeMaxThrowBonus=0.10000

    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}