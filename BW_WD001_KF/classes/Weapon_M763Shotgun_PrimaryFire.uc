class Weapon_M763Shotgun_PrimaryFire extends BallisticShotgunFire;

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Ammo'
    ProjectileClass=Class'BW_Core_KF.BallisticShotgunProj'
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_FlashEmitter'
	
    KickMomentum=(X=-45.000000,Z=10.000000)
    ProjPerFire=7
    AmmoPerFire=1
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSoundRef="BWKF_MRT6_SN.MRT6.MRT6Fire"
    StereoFireSoundRef="BWKF_MRT6_SN.MRT6.MRT6Fire"
    NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
    FireRate=0.7
    FireAnimRate=1.0
    BotRefireRate=0.200000
    aimerror=1.000000
    Spread=1125.0
    maxVerticalRecoilAngle=1500
    maxHorizontalRecoilAngle=900

    //** View shake **//
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=3.0
    ShakeRotMag=(X=50.0,Y=50.0,Z=400.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=5.0
    bWaitForRelease=True
    bRandomPitchFireSound=false
}