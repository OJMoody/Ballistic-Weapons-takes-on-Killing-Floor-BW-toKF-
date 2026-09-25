//=============================================================================
// M806A2 Primary Fire
//=============================================================================
class Weapon_Wilson41_PrimaryFire extends BallisticInstantFire;


defaultproperties
{
    DamageType=Class'KFMod.DamTypeDualies'
    DamageMin=45
    DamageMax=55
    Momentum=10000.000000
    bPawnRapidFireAnim=True
    bAttachSmokeEmitter=True
    TransientSoundVolume=1.8
    FireSound=Sound'BWKF_Wilson_SN.Wilson.LM-Fire'
    StereoFireSoundRef="BWKF_Wilson_SN.Wilson.LM-Fire"
    NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
    FireForce="AssaultRifleFire"
    FireRate=0.35
    RecoilRate=0.1
    maxVerticalRecoilAngle=300
    maxHorizontalRecoilAngle=50
    TweenTime=0.025
    AmmoClass=Class'BW_WD001_KF.Weapon_M806Pistol_Ammo'
    AmmoPerFire=1
    BotRefireRate=0.350000
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_Wilson41_FlashEmitter'
    aimerror=30.000000
    Spread=0.015000
    SpreadStyle=SS_Random
    bWaitForRelease=true
    ShakeOffsetMag=(X=6.0,Y=3.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=2.0
    ShakeRotMag=(X=75.0,Y=75.0,Z=250.0)
    ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
    ShakeRotTime=3.0
    ShellEjectClass=class'ROEffects.KFShellEject9mm'
    bRandomPitchFireSound=false
}