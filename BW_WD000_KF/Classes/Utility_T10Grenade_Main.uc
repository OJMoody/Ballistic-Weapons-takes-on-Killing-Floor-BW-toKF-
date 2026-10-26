class Utility_T10Grenade_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_T10Grenade_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_T10Grenade_SecondaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_T10Grenade_Pickup'
	MeleeFireClass=Class'Utility_T10Grenade_MeleeFire'
	AttachmentClass=Class'BW_WD000_KF.Utility_T10Grenade_Attachment'
	
	AmmoClass(0)=Class'BW_WD000_KF.Utility_T10Grenade_Ammo'
	AmmoClass(1)=Class'BW_WD000_KF.Utility_T10Grenade_Ammo'

    bKFNeverThrow=True
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-40.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_T10_A.T10_FP_Mesh'
	ItemName="T10 Toxic Grenade"
	Description="A recent addition to the Terran arsenal, the T10 toxin grenade was designed primarily for anti-Krao missions in underground facilities. When the clip is released, the grenade will start to release toxic fumes and dangerous gasses until depleted. The grenade can still roll or fly, whilst releasing toxic vapours. This becomes useful for clearing out passageways or small rooms and leaving no room for the enemy to breathe."
    
	HudImage=texture'BWKF_T10_T.Icons.MedIcon_T10_Unselected'
    SelectedHudImage=texture'BWKF_T10_T.Icons.MedIcon_T10_Selected'
   	TraderInfoTexture=texture'BWKF_T10_T.Icons.MedIcon_T10'
}