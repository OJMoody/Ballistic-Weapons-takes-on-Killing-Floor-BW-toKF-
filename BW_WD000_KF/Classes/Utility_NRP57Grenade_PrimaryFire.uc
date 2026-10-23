class Utility_NRP57Grenade_PrimaryFire extends BallisticHandGrenadeFire;

defaultproperties
{
    ProjectileClass=Class'KFMod.Nade'
    AmmoClass=Class'BW_WD000_KF.Utility_NRP57Grenade_Ammo'

	GrenadePrepareAnimation="PrepThrow"
    GrenadeThrowAnimation="Throw"

    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}