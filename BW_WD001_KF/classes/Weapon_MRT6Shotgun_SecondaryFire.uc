class Weapon_MRT6Shotgun_SecondaryFire extends BallisticShotgunFire;

var bool bFireRight;

simulated function InitEffects()
{
    Super.InitEffects();

    if (FlashEmitterLeft == None && FlashEmitterClass != None)
        FlashEmitterLeft = Weapon.Spawn(FlashEmitterClass);

    if (FlashEmitterLeft != None)
    {
        Weapon.AttachToBone(FlashEmitterLeft, 'TipL');
		FlashEmitterLeft.SetRelativeRotation(Rot(0, 32768, 0));
    }

    if (FlashEmitter != None)
    {
        Weapon.AttachToBone(FlashEmitter, 'TipR');
		FlashEmitter.SetRelativeRotation(Rot(0, 32768, 0));
    }
}

function FlashMuzzleFlash()
{
    if (bFireRight)
    {
        if (FlashEmitter != None)
            FlashEmitter.Trigger(Weapon, Instigator);
    }
    else
    {
        if (FlashEmitterLeft != None)
            FlashEmitterLeft.Trigger(Weapon, Instigator);
    }
}

simulated function DestroyEffects()
{
    Super.DestroyEffects();

    if (FlashEmitterLeft != None)
    {
        FlashEmitterLeft.Destroy();
        FlashEmitterLeft = None;
    }
}

simulated event ModeDoFire()
{
    local BallisticWeapon BW;
    local Weapon_MRT6Shotgun_Main MRT6;
    local int OldAmmo;
    local bool bWasFireRight;

    BW = BallisticWeapon(Weapon);
    MRT6 = Weapon_MRT6Shotgun_Main(BW);

    if (BW == None || MRT6 == None)
        return;

    OldAmmo = BW.MagAmmoRemaining;
    bWasFireRight = bFireRight;

    if (bFireRight)
    {
        FireAnim = 'FireRight';

        if (BW.MagAmmoRemaining <= 1)
            FireAnim = 'FireRightNoCock';

        // Secondary shot is coming from the right barrel.
        MRT6.ThirdPersonFireBarrel = 2;
    }
    else
    {
        FireAnim = 'FireLeft';

        if (BW.MagAmmoRemaining <= 1)
            FireAnim = 'FireNoCock';

        // Secondary shot is coming from the left barrel.
        MRT6.ThirdPersonFireBarrel = 1;
    }

    Super.ModeDoFire();

    if (BW.MagAmmoRemaining < OldAmmo)
    {
        if (bWasFireRight)
        {
            MRT6.bOneBarrelFired = false;
            MRT6.ResetSecondaryFireAnim();
            bFireRight = false;
        }
        else
        {
            MRT6.bOneBarrelFired = true;
            bFireRight = true;
        }
    }
}

simulated function bool AllowFire()
{
    local BallisticWeapon BW;
    local name AnimName;
    local float AnimFrame;
    local float AnimRate;

    BW = BallisticWeapon(Weapon);

    if (BW == None)
        return false;

    if (BW.IsHoldingMelee() || BW.IsActionLocked())
        return false;

    if (bBurstMode && bBurstComplete)
        return false;

    if (BW.MagAmmoRemaining <= 0)
    {
        BW.ReloadMeNow();
        return false;
    }

    if (Weapon != None)
    {
        Weapon.GetAnimParams(0, AnimName, AnimFrame, AnimRate);

        if (AnimName == 'FireLeft' || AnimName == 'FireRight' ||
            AnimName == 'FireNoCock' || AnimName == 'FireRightNoCock')
            return false;
    }

    return Super(WeaponFire).AllowFire();
}

defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Ammo'
    ProjectileClass=Class'BW_Core_KF.BallisticShotgunProj'
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_FlashEmitter'
	
	KickMomentum=(X=-45.000000,Z=10.000000)
    ProjPerFire=5
    AmmoPerFire=1
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSoundRef="BWKF_MRT6_SN.MRT6.MRT6SingleFire"
    StereoFireSoundRef="BWKF_MRT6_SN.MRT6.MRT6SingleFire"
    NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
    FireRate=0.2
    FireAnimRate=1.0
	BotRefireRate=0.200000
    aimerror=1.000000
    Spread=1125.0
    maxVerticalRecoilAngle=1500
    maxHorizontalRecoilAngle=900
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=3.0
    ShakeRotMag=(X=50.0,Y=50.0,Z=400.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=5.0
    bWaitForRelease=true
    bRandomPitchFireSound=true
}