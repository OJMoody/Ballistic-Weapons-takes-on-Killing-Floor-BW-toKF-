class Weapon_XK2SMG_Main extends BallisticWeapon;

//=============================================================================
// DAMAGE AMPLIFIER VARIABLES
//=============================================================================

var bool bAmpAttached;
var bool bAmpAnimating;

var() BUtil.FullSound AMPTurnSound;
var() BUtil.FullSound AMPOnSound;
var() BUtil.FullSound AMPOffSound;

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
    class'BUtil'.static.PlayFullSound(self, AMPOnSound, true);

    bAmpAttached = true;
	UpdateAMPFlashBone();
	CommonSwitchWeaponMode(3);
}


simulated function Notify_AMPOff()
{
    class'BUtil'.static.PlayFullSound(self, AMPOffSound, true);

    bAmpAttached = false;
	UpdateAMPFlashBone();
	CommonSwitchWeaponMode(2);
}


simulated function Notify_AMPHide()
{
    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 0.0, 'AMP');
}


simulated function Notify_AMPShow()
{
    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 1.0, 'AMP');
}


//=============================================================================
// WEAPON INITIALISATION
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    bAmpAnimating = false;

    if (Instigator != None && Instigator.IsLocallyControlled())
    {
        if (bAmpAttached)
            SetBoneScale(0, 1.0, 'AMP');
        else
            SetBoneScale(0, 0.0, 'AMP');
    }
	
	UpdateAMPFlashBone();
}

simulated function UpdateAMPFlashBone()
{
    local BallisticInstantFire PrimaryFire;

    PrimaryFire = BallisticInstantFire(FireMode[0]);

    if (PrimaryFire == None || PrimaryFire.FlashEmitter == None)
        return;

    if (bAmpAttached)
        FlashBoneRight = 'tip2';
    else
        FlashBoneRight = 'tip';

    if (Instigator != None && Instigator.IsLocallyControlled())
        AttachToBone(PrimaryFire.FlashEmitter, FlashBoneRight);
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
    AMPTurnSound=(Sound=SoundGroup'BWKF_XK2_SN.XK2.XK2-AMPTurn',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	AMPOnSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-AMPOn',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	AMPOffSound=(Sound=Sound'BWKF_XK2_SN.XK2.XK2-AMPOff',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	bHasSecondaryAmmo=True
    AltAmmoLoaded=0
    bReduceMagAmmoOnSecondaryFire=False
    bShowAltAmmoChamber=True

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
    Weight=8.000000

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