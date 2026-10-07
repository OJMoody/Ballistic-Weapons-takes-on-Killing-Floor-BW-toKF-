class Weapon_M763Shotgun_Main extends BallisticWeapon;

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_M763Shotgun_PrimaryFire'
    FireModeClass(1)=none //Class'BW_WD001_KF.Weapon_MRT6Shotgun_SecondaryFire'
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

	//HudImage=Texture'BWKF_MRT6_T.Icons.MedIcon_MRT6Unselected'
    //SelectedHudImage=Texture'BWKF_MRT6_T.Icons.MedIcon_MRT6Selected'
	//TraderInfoTexture=Texture'BWKF_MRT6_T.Icons.MedIcon_MRT6'

    PlayerViewOffset=(X=-10.000000,Y=8.000000,Z=-7.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    //SightFXClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_SightLEDs'
    //SightFXBone="MRT6"
	
    ClipHitSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6ClipIn')
    ClipOutSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6ClipOut')
    ClipInSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6ClipHit')
	CockSound=(Sound=Sound'BWKF_MRT6_SN.MRT6.MRT6Cock')
}