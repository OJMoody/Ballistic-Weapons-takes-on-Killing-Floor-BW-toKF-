class Utility_FP7Grenade_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_FP7Grenade_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_FP7Grenade_PrimaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_FP7Grenade_Pickup'
	
	AmmoClass(0)=Class'BW_WD000_KF.Utility_FP7Grenade_Ammo'
	AmmoClass(1)=Class'BW_WD000_KF.Utility_FP7Grenade_Ammo'

    bKFNeverThrow=True
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-40.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_FP7_A.FP7_FP_Mesh'
	ItemName="FP7 Incendiary Grenade"
	
	HudImage=texture'BWKF_FP7_T.Icons.MedIcon_FP7_Unselected'
    SelectedHudImage=texture'BWKF_FP7_T.Icons.MedIcon_FP7_Selected'
   	TraderInfoTexture=texture'BWKF_FP7_T.Icons.MedIcon_FP7'
}