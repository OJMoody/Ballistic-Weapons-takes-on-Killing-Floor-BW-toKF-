class Weapon_59MachinePistol_Main extends BallisticWeapon;


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD002_KF.Weapon_59MachinePistol_PrimaryFire'
    //FireModeClass(1)=Class'BW_WD002_KF.Weapon_59MachinePistol_SecondaryFire'
    MeleeFireClass=Class'BW_WD002_KF.Weapon_59MachinePistol_MeleeFire'
    PickupClass=Class'BW_WD002_KF.Weapon_59MachinePistol_Pickup'
    AttachmentClass=Class'BW_WD002_KF.Weapon_59MachinePistol_Attachment'
	
	WeaponReloadAnim=Reload_Single9mm
    ItemName="Fifty-9 Machine Pistol"
    Description="Krome Firepower is a relatively new arms company created with the aim of producing guns with 'style'. The Fifty-9 is one such weapon. Taking an original small arm, and replacing certain parts, adding new attachments, custom paint jobs, etc. Krome weapons are designed for civilian purposes, self defense, bounty hunters, enthusiasts, and collectors. This particular model comes with attached Krome blades, to add some extra flair to the weapon."

    MagCapacity=25

    Mesh=Mesh'BWKF_59M_A.59M_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
	CurrentWeaponMode=2

    Priority=3
    InventoryGroup=3
    GroupOffset=1
    Weight=4.000000
    bModeZeroCanDryFire=True
    SellValue=200

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True

	HudImage=Texture'BWKF_59M_T.Icons.MedIcon_Fifty9_Unselected'
    SelectedHudImage=Texture'BWKF_59M_T.Icons.MedIcon_Fifty9_Selected'
	TraderInfoTexture=Texture'BWKF_59M_T.Icons.MedIcon_Fifty9'

    PlayerViewOffset=(X=80.000000,Y=60.000000,Z=-20.000000)
	PlayerViewPivot=(Yaw=0)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    //SightFXClass=Class'BW_WD001_KF.Weapon_M806Pistol_SightLEDs'
    SightFXBone="Uzi"
    ClipHitSound=(Sound=Sound'BWKF_M806_SN.M806-ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M806_SN.M806-ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M806_SN.M806-ClipIn')
}