class Utility_T10Grenade_PrimaryFire extends BallisticHandGrenadeFire;

defaultproperties
{
    ProjectileClass=Class'BW_WD000_KF.Utility_T10Grenade_Projectile'
    AmmoClass=Class'BW_WD000_KF.Utility_T10Grenade_Ammo'

	GrenadePrepareAnimation="PrepThrow"
    GrenadeThrowAnimation="Throw"

    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}