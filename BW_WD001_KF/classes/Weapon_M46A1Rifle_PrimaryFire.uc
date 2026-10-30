class Weapon_M46A1Rifle_PrimaryFire extends BallisticInstantFire;

simulated event ModeDoFire()
{
    local Weapon_M46A1Rifle_Main M46;

    M46 = Weapon_M46A1Rifle_Main(Weapon);

    if (M46 != None)
    {
        if (M46.bM46MinePrimed || M46.bM46MineLaunching || M46.bM46MinePriming)
            return;
    }

    Super.ModeDoFire();
}

simulated function bool AllowFire()
{
    local Weapon_M46A1Rifle_Main M46;

    M46 = Weapon_M46A1Rifle_Main(Weapon);

    if (M46 != None &&
        (M46.bM46MinePriming || M46.bM46MinePrimed || M46.bM46MineLaunching))
        return false;

    return Super.AllowFire();
}

defaultproperties
{
    DamageType=Class'KFMod.DamTypeAK47AssaultRifle'
    DamageMin=35
    DamageMax=45
    Momentum=10000.000000
    bPawnRapidFireAnim=True
    bAttachSmokeEmitter=True
    TransientSoundVolume=1.8
    FireSound=Sound'BWKF_M46_SN.M46.OA-AR_Fire1'
    StereoFireSoundRef="BWKF_M46_SN.M46.OA-AR_Fire1"
    NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
    FireForce="AssaultRifleFire"
    FireRate=0.15
    RecoilRate=0.1
    maxVerticalRecoilAngle=300
    maxHorizontalRecoilAngle=50
    TweenTime=0.025
    AmmoClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_Ammo'
    AmmoPerFire=1
    BotRefireRate=0.350000
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_PrimaryFlashEmitter'
    aimerror=30.000000
    Spread=0.015000
    SpreadStyle=SS_Random
    bWaitForRelease=false
    ShakeOffsetMag=(X=6.0,Y=3.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=2.0
    ShakeRotMag=(X=75.0,Y=75.0,Z=250.0)
    ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
    ShakeRotTime=3.0
    ShellEjectClass=class'ROEffects.KFShellEjectAK'
    bRandomPitchFireSound=false
}