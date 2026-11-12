class Weapon_XK2SMG_Main extends BallisticWeapon;

#exec OBJ LOAD FILE=BWKF_Core_T.utx

//=============================================================================
// DAMAGE AMPLIFIER VARIABLES
//=============================================================================

var bool bAmpAttached;
var bool bAmpAnimating;

var float AMPBattery;
var bool bAMPDrainStarted;
var bool bAMPDepleted;

var() BUtil.FullSound AMPTurnSound;
var() BUtil.FullSound AMPOnSound;
var() BUtil.FullSound AMPOffSound;
var() BUtil.FullSound AMPDeactivateSound;

replication
{
    reliable if (Role == ROLE_Authority)
        AMPBattery, bAMPDepleted, bAmpAttached;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
        Class'FreezeRules'.static.FindOrSpawnMe(Level.Game);
}

//=============================================================================
// SECONDARY FIRE - AMP ATTACHMENT
//=============================================================================

simulated function bool StartFire(int Mode)
{
    // Prevent all firing input during AMP animations.
    if (bAmpAnimating)
        return false;

    if (Mode == 1)
    {
        if (MeleeState != MS_None)
            return false;

        if (bIsReloading || bBallisticReload || bBallisticAltReload
            || bBallisticReloadClipIn || bReloadPending)
            return false;

		// Cannot attach an AMP without reserve ammunition.
		if (!bAmpAttached && AmmoAmount(1) <= 0)
			return false;

        if (Super.StartFire(Mode))
		{
			// Exit ADS before starting the AMP animation.
			if (bAimingRifle)
			{
				ZoomOut(true);

				if (Role < ROLE_Authority)
					ServerZoomOut(false);
			}

			bAmpAnimating = true;

			if (bAmpAttached)
				PlayAnim('AMPOff', 1.0, 0.0);
			else
				PlayAnim('AMPOn', 1.0, 0.0);

			return true;
		}

        return false;
    }

    return Super.StartFire(Mode);
}

simulated function MeleeHoldImpl()
{
    if (bAmpAnimating)
        return;

    Super.MeleeHoldImpl();
}

exec function ReloadMeNow()
{
    if (bAmpAnimating)
        return;

    if (MagAmmoRemaining <= 0)
    {
        ReloadAnim = 'ReloadEmpty';
        WeaponReloadResumeAnimation = 'ReloadResumeEmpty';
    }
    else
    {
        ReloadAnim = 'Reload';
        WeaponReloadResumeAnimation = 'ReloadResume';
    }

    Super.ReloadMeNow();
}

simulated function string GetCurrentWeaponModeName()
{
    if (CurrentWeaponMode == 3 && WeaponModes.Length > 3)
        return WeaponModes[3].ModeName;

    return Super.GetCurrentWeaponModeName();
}

function StartAMPDrain()
{
    if (Role != ROLE_Authority || bAMPDrainStarted || bAMPDepleted)
        return;

    bAMPDrainStarted = true;
    SetTimer(1.0, true);
}

function Timer()
{
    Super.Timer();

    if (!bAMPDrainStarted || bAMPDepleted || !bAmpAttached)
    {
        SetTimer(0.0, false);
        return;
    }

    AMPBattery -= 4.0;
	UpdateBatteryHUD();

    if (AMPBattery <= 0.0)
    {
        AMPBattery = 0.0;
        bAMPDepleted = true;
		class'BUtil'.static.PlayFullSound(self, AMPDeactivateSound, true);
		AltAmmoLoaded = 0;
		UpdateAMPMaterials();
		UpdateBatteryHUD();
        bAMPDrainStarted = false;

        SetTimer(0.0, false);

        UpdateAMPFlashBone();
    }
}

simulated function UpdateAMPMaterials()
{
    if (bAMPDepleted)
    {
        Skins[4] = Texture'BWKF_Core_T.Misc.Invisible';
        Skins[3] = Texture'BWKF_Core_T.AMP.Amp-BaseDepleted';
    }
    else
    {
        Skins[3] = Shader'BWKF_Core_T.AMP.Amp-FinalCyan';
        Skins[4] = Shader'BWKF_Core_T.AMP.Amp-GlowCyanShader';
    }
}

simulated function UpdateBatteryHUD(optional bool bForceHide)
{
    local BW_HUD H;

    if (Instigator == None || !Instigator.IsLocallyControlled())
        return;

    H = BW_HUD(PlayerController(Instigator.Controller).myHUD);

    if (H == None)
        return;

    H.bShowWeaponBattery = bAmpAttached && !bForceHide;
    H.WeaponBatteryValue = int(AMPBattery);
}

simulated function bool PutDown()
{
    local bool bResult;

    bResult = Super.PutDown();

    if (bResult)
    {
        if (Role == ROLE_Authority)
        {
            // Pause the battery countdown.
            SetTimer(0.0, false);
            bAMPDrainStarted = false;

            // Deduct 10%, but never reduce the battery below 5%.
            if (bAmpAttached && !bAMPDepleted && AMPBattery > 5.0)
            {
                AMPBattery -= 10.0;

                if (AMPBattery < 5.0)
                    AMPBattery = 5.0;
            }
        }

        UpdateBatteryHUD(true);
    }

    return bResult;
}

function DropFrom(vector StartLocation)
{
    if (Role == ROLE_Authority && bAmpAttached)
    {
        // Fully deplete the AMP when the weapon is dropped.
        AMPBattery = 0.0;
        bAMPDepleted = true;
        bAMPDrainStarted = false;

        // Stop any active battery countdown.
        SetTimer(0.0, false);

        // Clear the loaded AMP ammo state.
        AltAmmoLoaded = 0;

        UpdateAMPMaterials();
        UpdateAMPFlashBone();
    }

    Super.DropFrom(StartLocation);
}


//=============================================================================
// ANIMATION END
//=============================================================================

simulated function AnimEnd(int Channel)
{
    if (Channel == 0 && bAmpAnimating)
        bAmpAnimating = false;

    Super.AnimEnd(Channel);
}


//=============================================================================
// DAMAGE AMPLIFIER NOTIFIERS
//=============================================================================

simulated function Notify_AMPTurn()
{
    class'BUtil'.static.PlayFullSound(self, AMPTurnSound, true);
}


simulated function Notify_AMPOn()
{
    if (Role == ROLE_Authority)
    {
        if (AltAmmoLoaded > 0 || AmmoAmount(1) <= 0)
            return;

        if (!ConsumeAmmo(1, 1))
            return;

        AltAmmoLoaded = 1;
    }

    bAmpAttached = true;
	
	AMPBattery = 100.0;
	bAMPDrainStarted = false;
	bAMPDepleted = false;

	UpdateAMPMaterials();
	UpdateBatteryHUD();

    // Set the alternate-loaded state and activate ice mode.
    //SetAltLoaded();

    class'BUtil'.static.PlayFullSound(self, AMPOnSound, true);

    UpdateAMPFlashBone();
}

simulated function Notify_AMPOff()
{
    if (Role == ROLE_Authority)
        AltAmmoLoaded = 0;

    bAmpAttached = false;
	UpdateBatteryHUD();

    // Clear the alternate-loaded state and return to normal mode.
    ClearAltLoaded();

    class'BUtil'.static.PlayFullSound(self, AMPOffSound, true);

    UpdateAMPFlashBone();
}


simulated function Notify_AMPHide()
{
    local Weapon_XK2SMG_Attachment XK2Attachment;

    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 0.0, 'AMP');

    XK2Attachment = Weapon_XK2SMG_Attachment(ThirdPersonActor);

    if (XK2Attachment != None)
        XK2Attachment.SetBoneScale(0, 0.0, 'AMP');
}


simulated function Notify_AMPShow()
{
    local Weapon_XK2SMG_Attachment XK2Attachment;

    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 1.0, 'AMP');

    XK2Attachment = Weapon_XK2SMG_Attachment(ThirdPersonActor);

    if (XK2Attachment != None)
        XK2Attachment.SetBoneScale(0, 1.0, 'AMP');
}

//=============================================================================
// WEAPON INITIALISATION
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);
	
	UpdateBatteryHUD();

    bAmpAnimating = false;

    if (Instigator != None && Instigator.IsLocallyControlled())
	{
		if (bAmpAttached)
			SetBoneScale(0, 1.0, 'AMP');
		else
			SetBoneScale(0, 0.0, 'AMP');
	}

	if (ThirdPersonActor != None)
	{
		if (bAmpAttached)
			ThirdPersonActor.SetBoneScale(0, 1.0, 'AMP');
		else
			ThirdPersonActor.SetBoneScale(0, 0.0, 'AMP');
	}
	
	UpdateAMPFlashBone();
}

simulated function UpdateAMPFlashBone()
{
    local BallisticInstantFire PrimaryFire;
    local class<Emitter> NewFlashClass;

    PrimaryFire = BallisticInstantFire(FireMode[0]);

    if (PrimaryFire == None)
        return;

    // Select the correct flash and attachment bone.
    if (bAmpAttached)
	{
		FlashBoneRight = 'tip2';

		if (bAMPDepleted)
			NewFlashClass = class'BW_WD001_KF.Weapon_XK2SMG_FlashEmitter';
		else
			NewFlashClass = class'BW_WD001_KF.Weapon_XK2SMG_IceFlashEmitter';
	}
	else
	{
		FlashBoneRight = 'tip';
		NewFlashClass = class'BW_WD001_KF.Weapon_XK2SMG_FlashEmitter';
	}

    // Replace the existing first-person flash emitter if necessary.
    if (PrimaryFire.FlashEmitterClass != NewFlashClass)
    {
        if (PrimaryFire.FlashEmitter != None)
        {
            PrimaryFire.FlashEmitter.Destroy();
            PrimaryFire.FlashEmitter = None;
        }

        PrimaryFire.FlashEmitterClass = NewFlashClass;
    }

    // Create the selected emitter if it doesn't exist.
    if (PrimaryFire.FlashEmitter == None
        && Level.NetMode != NM_DedicatedServer
        && Instigator != None
        && Instigator.IsLocallyControlled())
    {
        PrimaryFire.FlashEmitter = Spawn(NewFlashClass);
    }

    // Attach the emitter to the appropriate muzzle bone.
    if (PrimaryFire.FlashEmitter != None
        && Instigator != None
        && Instigator.IsLocallyControlled())
    {
        AttachToBone(PrimaryFire.FlashEmitter, FlashBoneRight);
    }
	
	// Update third-person muzzle flash and tracer.
    if (ThirdPersonActor != None)
    {
        Weapon_XK2SMG_Attachment(ThirdPersonActor).UpdateAMPVisuals();
    }
}


//=============================================================================
// RELOAD
//=============================================================================

simulated function bool InterruptReload()
{
    if (MagAmmoRemaining <= 0)
        WeaponReloadResumeAnimation = 'ReloadResumeEmpty';
    else
        WeaponReloadResumeAnimation = 'ReloadResume';

    return Super.InterruptReload();
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    AMPTurnSound=(Sound=SoundGroup'BWKF_XK2_SN.XK2.XK2-AMPTurn',Volume=1.000000,Radius=24.000000,Slot=SLOT_None,Pitch=1.000000,bAtten=True)
	AMPOnSound=(Sound=Sound'BWKF_Core_SN.AMP.Amp-Install',Volume=1.000000,Radius=24.000000,Slot=SLOT_None,Pitch=1.000000,bAtten=True)
	AMPOffSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-AMPOff',Volume=1.000000,Radius=24.000000,Slot=SLOT_None,Pitch=1.000000,bAtten=True)
	AMPDeactivateSound=(Sound=Sound'BWKF_Core_SN.AMP.Amp-Depleted',Volume=1.000000,Radius=24.000000,Slot=SLOT_None,Pitch=1.000000,bAtten=True)
	
	bNetNotify=True
	bHasSecondaryAmmo=True
    AltAmmoLoaded=0
    bReduceMagAmmoOnSecondaryFire=False
    bShowAltAmmoChamber=True
	AmmoClass(1)=Class'BW_WD001_KF.Weapon_XK2SMG_AmmoAMP'
	AltLoadedWeaponMode=3
	AltLoadedReturnWeaponMode=2

    FireModeClass(0)=Class'BW_WD001_KF.Weapon_XK2SMG_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_XK2SMG_SecondaryFire'

    MeleeFireClass=Class'BW_WD001_KF.Weapon_XK2SMG_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_XK2SMG_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_XK2SMG_Attachment'

    WeaponReloadAnim=Reload_AK47
    ItemName="XK2 Submachine Gun"
    Description="Yet another high quality weapon by Black & Wood, the XK2 is a lightweight, suppressed sub-machinegun. It has a fast rate of fire, but its low velocity bullets make it less dangerous than other weapons. However, these low velocity rounds do allow the weapon to be easily silenced, turning it into an effective stealth weapon, used by many law enforcement organisations, and Black-Ops military units alike. The weapon's high rate of fire, and quick reload times, means that the soldier can pump out rounds quicker than even the M353, making it very useful for cover-fire."

    MagCapacity=40

    Mesh=Mesh'BWKF_XK2_A.XK2_FP_Mesh'

    WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
    WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
    WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
    WeaponModes(3)=(ModeName="AMP: Ice Squall",ModeID="WM_FullAuto",bUnavailable=True)
    CurrentWeaponMode=2

    Priority=3
    InventoryGroup=3
    GroupOffset=2
    Weight=5.000000
	
	SightFXClass=Class'BW_WD001_KF.Weapon_XK2SMG_SightLEDs'
    SightFXBone="XK2"

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True
    bModeZeroCanDryFire=True
    bPlusOne=True

    HudImage=Texture'BWKF_XK2_T.Icons.MedIcon_XK2_Unselected'
    SelectedHudImage=Texture'BWKF_XK2_T.Icons.MedIcon_XK2_Selected'
    TraderInfoTexture=Texture'BWKF_XK2_T.Icons.MedIcon_XK2'

    BobDamping=0.1
    PlayerViewOffset=(X=-1.000000,Y=8.000000,Z=-4.000000)

    SelectSoundRef="BWKF_XK2_SN..XK2.XK2-Pullout"
    PulloutSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)

    ClipOutSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-ClipOut')
    ClipInSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-ClipIn')
    CockSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-Cock')
}