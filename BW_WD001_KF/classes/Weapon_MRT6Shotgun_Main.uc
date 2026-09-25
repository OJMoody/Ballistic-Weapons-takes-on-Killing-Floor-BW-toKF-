class Weapon_MRT6Shotgun_Main extends BallisticWeapon;

var bool bOneBarrelFired;
var bool bReloadEmptyPlaying;
var bool bReloadEmptyFinishPending;

var byte ThirdPersonFireBarrel;

replication
{
    reliable if (Role == ROLE_Authority)
        ThirdPersonFireBarrel;
}

simulated function bool ConsumeAmmo(int Mode, float Load, optional bool bAmountNeededIsMax)
{
    local bool bResult;
    local int FollowupAmmo;

    if (Mode == 0 && (bOneBarrelFired || MagAmmoRemaining == 1))
    {
        FollowupAmmo = Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).AmmoPerFire;
        return Super.ConsumeAmmo(Mode, FollowupAmmo, bAmountNeededIsMax);
    }

    bResult = Super.ConsumeAmmo(Mode, Load, bAmountNeededIsMax);

    if (bResult && Mode == 0 && Load > 1)
        MagAmmoRemaining -= int(Load) - 1;

    return bResult;
}

simulated function int GetSecondaryAmmoPerFire()
{
    return Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).AmmoPerFire;
}

simulated function int GetSecondaryProjPerFire()
{
    return Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).ProjPerFire;
}

simulated function name GetSecondaryFireAnim()
{
    if (Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).bFireRight)
        return 'FireRight';

    return 'FireLeft';
}

simulated function ResetSecondaryFireAnim()
{
    Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).bFireRight = false;
}

simulated function ActuallyFinishReloading()
{
    if (bReloadEmptyPlaying)
    {
        bReloadEmptyFinishPending = true;
        return;
    }

    Super.ActuallyFinishReloading();

    if (MagAmmoRemaining == 0)
    {
        bOneBarrelFired = false;
        ResetSecondaryFireAnim();
    }
}

simulated function bool StartFire(int Mode)
{
    if (bIsReloading || bBallisticReload || bReloadResumePlaying)
        return false;

    return Super.StartFire(Mode);
}

exec function ReloadMeNow()
{
    if (MagAmmoRemaining == 0)
        ReloadAnim = 'ReloadEmpty';
    else
        ReloadAnim = 'Reload';

    bReloadEmptyFinishPending = false;

    Super.ReloadMeNow();

    if (MagAmmoRemaining == 0 && bIsReloading)
        bReloadEmptyPlaying = true;
    else
        bReloadEmptyPlaying = false;
}

simulated function bool IsActionLocked()
{
    local name AnimName;
    local float AnimFrame;
    local float AnimRate;

    if (bReloadEmptyPlaying)
        return true;

    GetAnimParams(0, AnimName, AnimFrame, AnimRate);

    if (AnimName == 'Fire' || AnimName == 'FireLeft' || AnimName == 'FireRight' ||
        AnimName == 'FireNoCock' || AnimName == 'FireRightNoCock')
        return true;

    return Super.IsActionLocked();
}

simulated function AnimEnd(int Channel)
{
    local name AnimName;
    local float AnimFrame;
    local float AnimRate;

    if (Channel == 0)
    {
        GetAnimParams(0, AnimName, AnimFrame, AnimRate);

        if (bReloadEmptyPlaying && AnimName == 'ReloadEmpty')
        {
            bReloadEmptyPlaying = false;

            if (bReloadEmptyFinishPending)
            {
                bReloadEmptyFinishPending = false;
                Super.ActuallyFinishReloading();

                if (MagAmmoRemaining == 0)
                {
                    bOneBarrelFired = false;
                    ResetSecondaryFireAnim();
                }

                return;
            }
        }

        if (bReloadResumePlaying && AnimName == 'ReloadResumeEmpty')
        {
            bReloadResumePlaying = false;
            Super.AnimEnd(Channel);
            WeaponReloadResumeAnimation = 'ReloadResume';
            return;
        }
    }

    Super.AnimEnd(Channel);
}

simulated function bool InterruptReload()
{
    if (MagAmmoRemaining == 0)
    {
        bReloadEmptyPlaying = false;
        bReloadEmptyFinishPending = false;
        WeaponReloadResumeAnimation = 'ReloadResumeEmpty';
    }
    else
        WeaponReloadResumeAnimation = 'ReloadResume';

    return Super.InterruptReload();
}

simulated function Sound GetSecondaryFireSound()
{
    return Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).FireSound;
}

simulated function Sound GetSecondaryStereoFireSound()
{
    return Weapon_MRT6Shotgun_SecondaryFire(FireMode[1]).StereoFireSound;
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_MRT6Shotgun_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_MRT6Shotgun_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Attachment'
	
	WeaponReloadAnim=Reload_Single9mm
    ItemName="MRT-6 Shotgun"
    Description="MRT6 Shotgun Sidearm||Manufacturer: Wot ya Packin Gun Corp|Primary: Dual Barrel Shot|Secondary: Single Barrel Shot||One of Wot Ya Packin's most famous creations, the ridiculous MRT6 has grown quite a reputaton. A favourite of gangsters, thieves and countless other such criminals, the MRT6 is a small, fairly light shotgun that can easily be mistaken for a pistol. It has two barrels that can be fired simultaneously, it can be reloaded quickly and has an eight shell magazine. It is rarely seen in professional military use due to its loud noise, short range and extreme spread, but it is has a very high damage when used at close range, as anyone that is unfortunate enough to be aboard an unsuspecting ship attacked by a band of cargo raiders would testify. In fact, during an incident where Var Dehidra's pirates boarded a private exploration vessel, already being attacked by another band. They used their MRT6's to defeat the entire band of over thirty B1 'Possum' wielding marauders as well as the ship's defenders."
    
    bShovelLoad=False
    MagCapacity=10

    Mesh=Mesh'BWKF_MRT6_A.MRT6_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto",bUnavailable=True)
	CurrentWeaponMode=0

    Priority=3
    InventoryGroup=2
    GroupOffset=100
    Weight=0.000000
    bModeZeroCanDryFire=True

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True

	HudImage=Texture'BWKF_MRT6_T.Icons.MedIcon_MRT6Unselected'
    SelectedHudImage=Texture'BWKF_MRT6_T.Icons.MedIcon_MRT6Selected'
	TraderInfoTexture=Texture'BWKF_MRT6_T.Icons.MedIcon_MRT6'

    PlayerViewOffset=(X=13.000000,Y=12.000000,Z=-7.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    SightFXClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_SightLEDs'
    SightFXBone="MRT6"
	
    ClipHitSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6ClipIn')
    ClipOutSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6ClipOut')
    ClipInSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6ClipHit')
	CockSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6Cock')
	
    SkinRefs(0)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(1)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(2)=Texture'BWKF_Core_T.Ammo.MRT6Skin'
    SkinRefs(3)=Texture'BWKF_Core_T.Ammo.MRT6Small'
}