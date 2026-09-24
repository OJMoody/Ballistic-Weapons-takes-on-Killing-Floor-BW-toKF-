class Weapon_Wilson41_Main extends BallisticWeapon;

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_Wilson41_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_Wilson41_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_Wilson41_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_Wilson41_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_Wilson41_Attachment'
	
	bHasSecondaryAmmo=True
	AltAmmoLoaded=1
	bReduceMagAmmoOnSecondaryFire=False
	
	WeaponReloadAnim=Reload_SingleFlare
    ItemName="Wilson-41 Revolver"
    Description=""

    bShovelLoad=False
    MagCapacity=9

    Mesh=Mesh'BWKF_WIlson_A.Wilson_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto",bUnavailable=True)
	CurrentWeaponMode=0

    Priority=3
    InventoryGroup=2
    GroupOffset=100
    Weight=4.000000
    bModeZeroCanDryFire=True
    SellValue=300

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True

	//HudImage=Texture'BWKF_M806_T.Icons.MedIcon_M806_Unselected'
    //SelectedHudImage=Texture'BWKF_M806_T.Icons.MedIcon_M806_Selected'
	//TraderInfoTexture=Texture'BWKF_M806_T.Icons.MedIcon_M806'

    ClipOutSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-BulletsOut')
    ClipInSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-BulletsIn')
	CockSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-Cock')
	SlideInSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-Close')
	SlideOutSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-Open')
	
	ClipOutAltSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-ShellOut')
	ClipInAltSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-ShellIn')

    PlayerViewOffset=(X=7.000000,Y=12.000000,Z=-7.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    //SightFXClass=Class'BW_WD001_KF.Weapon_M806Pistol_SightLEDs'
    SightFXBone="Front"
    SkinRefs(0)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(1)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(2)=Shader'BWKF_Wilson_T.Weapon.leMat_Shine'
    SkinRefs(3)=Texture'BWKF_Wilson_T.Weapon.leMat_Shield'
    SkinRefs(4)=Texture'BWKF_Wilson_T.Weapon.leMat_Speed'
}