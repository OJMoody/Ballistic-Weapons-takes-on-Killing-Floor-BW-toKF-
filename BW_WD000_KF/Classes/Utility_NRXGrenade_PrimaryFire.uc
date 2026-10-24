class Utility_NRXGrenade_PrimaryFire extends BallisticHandGrenadeFire;

defaultproperties
{
    ProjectileClass=Class'BW_WD000_KF.Utility_NRXGrenade_Projectile'
    AmmoClass=Class'BW_WD000_KF.Utility_NRXGrenade_Ammo'

	GrenadePrepareAnimation="PrepThrow"
    GrenadeThrowAnimation="Throw"
	
	GrenadeThrowSound=(Sound=Sound'BWKF_NRXS_SN.NRXS.NRXS-Throw',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)

    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}