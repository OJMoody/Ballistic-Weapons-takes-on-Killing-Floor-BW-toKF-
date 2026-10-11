class Weapon_M763Shotgun_Main extends BallisticWeapon;

var Weapon_M763Shotgun_GasControl GC;
var bool bM763UseEmptyReloadEnd;

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
    Description=""
	
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
    GroupOffset=100
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