class Utility_G28Aerosol_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_G28Aerosol_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_G28Aerosol_SecondaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_G28Aerosol_Pickup'
	//MeleeFireClass=Class'Utility_G28Aerosol_MeleeFire'
	AttachmentClass=Class'BW_WD000_KF.Utility_G28Aerosol_Attachment'
	
	GrenadeClipOutSound=(Sound=Sound'BWKF_G28M_SN.G28.G28-ClipTwist',Volume=1.000000,Radius=128.000000)
	
	AmmoClass(0)=Class'BW_WD000_KF.Utility_G28Aerosol_Ammo'
	AmmoClass(1)=Class'BW_WD000_KF.Utility_G28Aerosol_Ammo'

    bKFNeverThrow=True
	PlayerViewOffset=(X=35.000000,Z=-15.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_G28M_A.G28_FP_Mesh'
	ItemName="FMD G28 Medicinal Aerosol"
	Description="The FMD G28 Medicinal Aerosol is a lightweight smoke grenade filled with various healing compounds and nano-assemblers for quick wound repair on the fly. It is a medic's best friend, and has been used to save many soldiers' lives. It has unfortunately also been the cause of a few deaths, as the grenade itself is quite heavy and can cause concussions if thrown with sufficient velocity. Surgeon General's Warning: The G28 Medicinal Aerosol is a temporary healing agent, and should not be used in place of quality medical care."
	
	HudImage=texture'BWKF_G28M_T.Icons.MedIcon_G28_Unselected'
    SelectedHudImage=texture'BWKF_G28M_T.Icons.MedIcon_G28_Selected'
   	TraderInfoTexture=texture'BWKF_G28M_T.Icons.MedIcon_G28'
}