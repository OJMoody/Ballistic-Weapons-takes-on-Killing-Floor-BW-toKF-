class Weapon_M46A1Rifle_Main extends BallisticWeapon;

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 0.0, 'RDS');
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_M46A1Rifle_PrimaryFire'
    //FireModeClass(1)=Class'BW_WD001_KF.Weapon_M46A1Rifle_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_Attachment'
	
	WeaponReloadAnim=Reload_AK47
    ItemName="M46A1 'Jackal' Combat Rifle"
    Description="The M46 was one of Black & Wood's first forays into high powered assault weaponry, specifically rifles. As with all of Black & Wood's weapons, the 'Jackal' is incredibly reliable and tough. Used by certain Terran units, the M46 is typically equipped with a short-range optical scope and often various Grenade Launcher attachments. While not quite yet a widely used weapon, its reputation has grown in recent times as heroic stories of Armoured Squadron 190's use of it has spread amongst the bulk of the UTC troops."

    MagCapacity=24

    Mesh=Mesh'BWKF_M46_A.M46A1_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
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

	HudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A1_Unselected'
    SelectedHudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A1_Selected'
	TraderInfoTexture=Texture'BWKF_M46_T.Icons.MedIcon_M46A1'

    PlayerViewOffset=(X=26.000000,Y=38.000000,Z=-15.000000)
	PlayerViewPivot=(Yaw=0)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    //SightFXClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_SightLEDs'
    SightFXBone="OA-AR"
    ClipHitSound=(Sound=Sound'BWKF_M806_SN.M806-ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M806_SN.M806-ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M806_SN.M806-ClipIn')
	
	bScoped=True
	ScopeTextureOverlay=FinalBlend'BWKF_M46_T.Scope.M46ScopeViewFinalBlend'
	ScopeMaskMaterial=Texture'BWKF_M46_T.Scope.M46ScopeViewRender'
	ScopeFallbackMaterial=Combiner'BWKF_M46_T.Scope.M46Lens_cmb'
	ScopeLensMaterialID=2
}