class Utility_T10Grenade_SecondaryFire extends BallisticHandGrenadeFire;

defaultproperties
{
    ProjectileClass=Class'BW_WD000_KF.Utility_T10Grenade_Projectile'
    AmmoClass=Class'BW_WD000_KF.Utility_T10Grenade_Ammo'

	GrenadePrepareAnimation="PrepRoll"
    GrenadeThrowAnimation="Roll"
	
	GrenadeBaseThrowSpeed=425.000000
    GrenadeThrowChargeTime=1.000000
    GrenadeMaxThrowBonus=0.10000

    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}