class Utility_NRP57Grenade_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_NRP57Grenade_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_NRP57Grenade_SecondaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_NRP57Grenade_Pickup'
	MeleeFireClass=Class'Utility_NRP57Grenade_MeleeFire'
	AttachmentClass=Class'BW_WD000_KF.Utility_NRP57Grenade_Attachment'
	
	AmmoClass(0)=Class'BW_WD000_KF.Utility_NRP57Grenade_Ammo'
	AmmoClass(1)=Class'BW_WD000_KF.Utility_NRP57Grenade_Ammo'

    bKFNeverThrow=True
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-40.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_NRP5_A.NRP5_FP_Mesh'
	ItemName="NRP57 Frag Grenade"
	Description="One of Black & Wood's most famous devices, the versatile NRP57 is a UTC favourite. Once the pin is pulled, it can be held ready as long as needed. The longer it is held, the further it will be thrown. The 3 second timer can be shortened by releasing the clip prior to throwing, but this greatly increases the risk of termination. The NRP57 is an effective tool which can be bounced around corners, lobbed over obstacles and has a high damage and a decent radius of effect, but it's true power lies in the soldier's ability to time the detonation and speed according to the distance of the target. The most famous story involving the Pineapple tells how the UTC Phobos Marines painted it yellow and rigged it for the unsuspecting Skrith who had, over the decades, developed an incredible taste for the terran fruit."
	
	HudImage=texture'BWKF_NRP5_T.Icons.MedIcon_NRP57_Unselected'
    SelectedHudImage=texture'BWKF_NRP5_T.Icons.MedIcon_NRP57_Selected'
   	TraderInfoTexture=texture'BWKF_NRP5_T.Icons.MedIcon_NRP57'
}