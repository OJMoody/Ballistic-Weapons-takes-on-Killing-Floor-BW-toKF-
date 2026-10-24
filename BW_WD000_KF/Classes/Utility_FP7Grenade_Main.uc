class Utility_FP7Grenade_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_FP7Grenade_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_FP7Grenade_SecondaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_FP7Grenade_Pickup'
	MeleeFireClass=Class'Utility_FP7Grenade_MeleeFire'
	
	AmmoClass(0)=Class'BW_WD000_KF.Utility_FP7Grenade_Ammo'
	AmmoClass(1)=Class'BW_WD000_KF.Utility_FP7Grenade_Ammo'

    bKFNeverThrow=True
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-40.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_FP7_A.FP7_FP_Mesh'
	ItemName="FP7 Incendiary Grenade"
	Description="A deadly hand grenade, the FP7 releases a searing blast of flames capable of melting metal with tempatures of over 7500 degrees Fahrenheit. The flames will continue to burn for a while, causing significant damage to anyone caught within the blast radius. FP7s are still widely used against both soldiers and equipment. The weapon was used extensivly during both Human-Skrith wars and is especially famous for its part in the UTC-Cryon battles where the UTC 'Ice Hogs' used it to incinerate Cryon cyborgs."
	
	HudImage=texture'BWKF_FP7_T.Icons.MedIcon_FP7_Unselected'
    SelectedHudImage=texture'BWKF_FP7_T.Icons.MedIcon_FP7_Selected'
   	TraderInfoTexture=texture'BWKF_FP7_T.Icons.MedIcon_FP7'
}