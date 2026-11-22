class Weapon_MRT6Shotgun_SecondaryFire extends BallisticShotgunFire;

var bool bMRT6PredictedFireLocked;

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
    if (Weapon == None || Weapon.Role < ROLE_Authority)
        return;

    if (Weapon_MRT6Shotgun_Main(Weapon).bMRT6FireRight)
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

simulated function ClientPlayConfirmedFire(byte Barrel)
{
    if (Weapon == None || Weapon.Role == ROLE_Authority)
        return;
		
    if (Barrel == 2)
    {
        if (FlashEmitter != None)
            FlashEmitter.Trigger(Weapon, Instigator);
    }
    else
    {
        if (FlashEmitterLeft != None)
            FlashEmitterLeft.Trigger(Weapon, Instigator);
    }
	
	if (Instigator != None && Instigator.IsLocallyControlled())
		ShakeView();

    if (Instigator != None && Instigator.IsLocallyControlled() &&
		Instigator.IsFirstPerson() && StereoFireSound != None)
	{
		Weapon.PlayOwnedSound(StereoFireSound, SLOT_Interact,
			TransientSoundVolume * 0.85,, TransientSoundRadius, 1.0, false);
	}
	else
	{
		Weapon.PlayOwnedSound(FireSound, SLOT_Interact,
			TransientSoundVolume,, TransientSoundRadius, 1.0, false);
	}
}

simulated event ModeDoFire()
{
    local BallisticWeapon BW;
    local Weapon_MRT6Shotgun_Main MRT6;
    local int OldAmmo;
    local bool bWasFireRight;
    local byte ConfirmedBarrel;

    BW = BallisticWeapon(Weapon);
    MRT6 = Weapon_MRT6Shotgun_Main(BW);

    if (BW == None || MRT6 == None)
        return;

    OldAmmo = BW.MagAmmoRemaining;

    if (Weapon.Role < ROLE_Authority)
        bWasFireRight = MRT6.bMRT6PredictedFireRight;
    else
        bWasFireRight = MRT6.bMRT6FireRight;

    ConfirmedBarrel = 1;
    if (bWasFireRight)
        ConfirmedBarrel = 2;

    MRT6.bMRT6PredictedBarrel = ConfirmedBarrel;

    if (bWasFireRight)
    {
        FireAnim = 'FireRight';

        if (BW.MagAmmoRemaining <= 1)
            FireAnim = 'FireRightNoCock';

        MRT6.ThirdPersonFireBarrel = 2;
    }
    else
    {
        FireAnim = 'FireLeft';

        if (BW.MagAmmoRemaining <= 1)
            FireAnim = 'FireNoCock';

        MRT6.ThirdPersonFireBarrel = 1;
    }

    Super.ModeDoFire();

    if (Weapon.Role == ROLE_Authority && BW.MagAmmoRemaining < OldAmmo)
    {
        BW.PlayFireAnimation(FireAnim, FireAnimRate, TweenTime, 0);
        MRT6.ClientPlayMRT6FireEffects(ConfirmedBarrel);
    }

    if (Weapon.Role == ROLE_Authority && BW.MagAmmoRemaining < OldAmmo)
    {
        if (bWasFireRight)
        {
            MRT6.bOneBarrelFired = false;
            MRT6.ResetSecondaryFireAnim();
        }
        else
        {
            MRT6.bOneBarrelFired = true;
            MRT6.bMRT6FireRight = true;
        }
    }
}

simulated function PlayFiring()
{
    if (Weapon != None && Weapon.Role < ROLE_Authority &&
		Instigator != None && Instigator.IsLocallyControlled())
		bMRT6PredictedFireLocked = true;

	Super.PlayFiring();
	
    if (Weapon != None && Weapon.Role < ROLE_Authority &&
        Instigator != None && Instigator.IsLocallyControlled())
    {
        Weapon_MRT6Shotgun_Main(Weapon).bMRT6PredictedFireRight =
            (Weapon_MRT6Shotgun_Main(Weapon).bMRT6PredictedBarrel == 1);
    }
}

simulated function bool AllowFire()
{
    local BallisticWeapon BW;
    local Weapon_MRT6Shotgun_Main MRT6;
    local name AnimName;
    local float AnimFrame;
    local float AnimRate;
    local bool bAllowed;
    local bool bActionLocked;
    local bool bIsFireAnim;

    BW = BallisticWeapon(Weapon);
    MRT6 = Weapon_MRT6Shotgun_Main(Weapon);

    if (BW == None || MRT6 == None)
        return false;

    if (BW.IsHoldingMelee())
        return false;

    Weapon.GetAnimParams(0, AnimName, AnimFrame, AnimRate);

    bIsFireAnim = (AnimName == 'FireLeft' ||
                   AnimName == 'FireRight' ||
                   AnimName == 'FireNoCock' ||
                   AnimName == 'FireRightNoCock');

    bActionLocked = BW.IsActionLocked();

    if (bActionLocked && (!bIsFireAnim || Level.NetMode == NM_Standalone))
		return false;

    if (bBurstMode && bBurstComplete)
        return false;

    if (BW.MagAmmoRemaining <= 0)
    {
        BW.ReloadMeNow();
        return false;
    }

    if (Weapon.Role < ROLE_Authority &&
        Instigator != None && Instigator.IsLocallyControlled())
    {
        if (bMRT6PredictedFireLocked)
            return false;
    }

    bAllowed = Super(WeaponFire).AllowFire();

    return bAllowed;
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
    FireRate=0.07
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