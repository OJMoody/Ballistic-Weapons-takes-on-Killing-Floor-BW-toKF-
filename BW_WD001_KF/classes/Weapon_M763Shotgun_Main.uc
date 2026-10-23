class Weapon_M763Shotgun_Main extends BallisticWeapon;

var Weapon_M763Shotgun_GasControl GC;
var bool bM763UseEmptyReloadEnd;
var bool bM763StartedEmptyAtReload;
var bool bM763PulloutPending;
var bool bM763AltShellAtPutdown;
var name M763SavedSelectAnim;
var bool bM763RestoreSelectAnimPending;

simulated function DoAltFire()
{
    local BallisticShotgunFire AltFire;

    AltFire = BallisticShotgunFire(FireMode[1]);

    if (AltFire == None)
        return;

    AltFire.bAltFire = true;
    AltFire.DoAltFireEffect();
    AltFire.bAltFire = false;

    if (Role == ROLE_Authority)
        AltAmmoLoaded = 0;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	GC = Spawn(class'Weapon_M763Shotgun_GasControl', Self);

	if (GC != None && Instigator != None)
	{
		GC.Instigator = Instigator;
		GC.InstigatorController = Instigator.Controller;
	}
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	Super.GiveTo(Other, Pickup);

	if (GC != None && Other != None)
	{
		GC.Instigator = Other;
		GC.InstigatorController = Other.Controller;
	}
}

simulated function name GetShovelReloadEndAnimation()
{
	if (bM763UseEmptyReloadEnd &&
		bShovelLoadEmptyEnd &&
		ShovelReloadEmptyEndAnimation != '' &&
		HasAnim(ShovelReloadEmptyEndAnimation))
		return ShovelReloadEmptyEndAnimation;

	return ShovelReloadEndAnimation;
}

function BeginBallisticShovelReload()
{
    CurrentShovelLoadAmount = GetShovelLoadAmount();

    bShovelReload = true;
    bShovelReloadCancelRequested = false;
    bShovelReloadEndRequested = false;
    bShovelReloadStopRequested = false;
    bShovelReloadLooping = false;

    bM763PulloutPending = false;
    bM763StartedEmptyAtReload = (ShovelReloadMode == 0 && MagAmmoRemaining <= 0);

    if (ShovelReloadMode == 0)
    {
        bShovelReloadEmpty = MagAmmoRemaining <= 0;
        bM763UseEmptyReloadEnd = (MagAmmoRemaining <= 0 && AltAmmoLoaded <= 0);
    }
    else
    {
        bShovelReloadEmpty = AltAmmoLoaded <= 0;
        bM763UseEmptyReloadEnd = false;
    }

    PlayShovelReloadStartAnimation();
}

simulated function bool PutDown()
{
    if (bShovelReload && bShovelReloadLooping)
    {
        bM763PulloutPending = true;
        bM763AltShellAtPutdown = (AltAmmoLoaded > 0);
    }

    return Super.PutDown();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    M763SavedSelectAnim = SelectAnim;

    if (bM763PulloutPending)
    {
        if (bM763StartedEmptyAtReload && !bM763AltShellAtPutdown)
        {
            SelectAnim = 'PulloutReloadEnd';
            bM763RestoreSelectAnimPending = true;
        }
        else
            bM763RestoreSelectAnimPending = false;
    }
    else
        bM763RestoreSelectAnimPending = false;

    Super.BringUp(PrevWeapon);

    bM763PulloutPending = false;
}

simulated function AnimEnd(int Channel)
{
    local name AnimName;
    local float Frame;
    local float Rate;

    if (Channel == 0 && bM763RestoreSelectAnimPending)
    {
        GetAnimParams(0, AnimName, Frame, Rate);

        if (AnimName == 'PulloutReloadEnd')
        {
            Super.AnimEnd(Channel);

            SelectAnim = M763SavedSelectAnim;
            bM763RestoreSelectAnimPending = false;
            return;
        }
    }

    Super.AnimEnd(Channel);
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_M763Shotgun_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_M763Shotgun_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_M763Shotgun_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_M763Shotgun_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M763Shotgun_Attachment'
	
	WeaponReloadAnim=Reload_Single9mm
    ItemName="M763 Shotgun"
    Description="The Avenger single barreled shotgun is the standard spread weapon of the UTC infantry divisions. Its high damage, reliability and good range for a shotgun have made this gun one of the humans' favourites; the M763 has blown open more Krao drones than can be counted. After its many successes, even during trials by the UTC's Reunited Jamaican Army, defending from wave upon wave of Krao minions during the 'Red Storm' Skrith invasion, the Avenger became the standard issue shotgun and a favorite of many forces including the UTC RJA Division."
	
    MagCapacity=8

    Mesh=Mesh'BWKF_M763_A.M763_FP_Mesh'
	bShovelLoadPrimary=True

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto",bUnavailable=True)
	WeaponModes(3)=(ModeName="Gas Shell",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
	
	bShowAmmoAsRounds=True
	bHasSecondaryAmmo=True
	AltAmmoLoaded=0
	bReduceMagAmmoOnSecondaryFire=False
	bShowAltAmmoChamber=True
	AltLoadedWeaponMode=3
	AltLoadedReturnWeaponMode=0
	bAltLoadEnabled=True
	
	CurrentWeaponMode=0

    Priority=3
    InventoryGroup=3
    GroupOffset=1
    Weight=0.000000
    bModeZeroCanDryFire=True

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True
	
	ShovelReloadStartAnimation=ReloadStart
    ShovelReloadLoopAnimation=ReloadLoop
    ShovelReloadEndAnimation=ReloadEnd
    ShovelReloadEmptyEndAnimation=ReloadEndEmpty
    bShovelLoadEmptyEnd=True

	HudImage=Texture'BWKF_M763_T.Icons.MedIcon_M763_Unselected'
    SelectedHudImage=Texture'BWKF_M763_T.Icons.MedIcon_M763_Selected'
	TraderInfoTexture=Texture'BWKF_M763_T.Icons.MedIcon_M763'

    PlayerViewOffset=(X=-10.000000,Y=8.000000,Z=-7.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M763_SN.M763.M763Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M763_SN.M763.M763Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    SightFXClass=Class'BW_WD001_KF.Weapon_M763Shotgun_SightLEDs'
    SightFXBone="M763"
	
	SlideInSound=(Sound=Sound'BWKF_M763_SN.M763.M763Hand-2')
	SlideOutSound=(Sound=Sound'BWKF_M763_SN.M763.M763Hand-1')
    ClipInSound=(Sound=Sound'BWKF_M763_SN.M763.M763LoadShell1')
	CockSound=(Sound=Sound'BWKF_M763_SN.M763.M763Cock1')
	ShellAltInSound=(Sound=Sound'BWKF_M763_SN.M763.M763LoadShell1')
}