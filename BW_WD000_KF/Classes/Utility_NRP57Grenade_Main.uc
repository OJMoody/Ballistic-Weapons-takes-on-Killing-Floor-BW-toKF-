class Utility_NRP57Grenade_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_NRP57Grenade_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_NRP57Grenade_PrimaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_NRP57Grenade_Pickup'

    InventoryGroup=4
    Priority=5

    ItemName="NRP57 Grenade"

    GrenadePrepareAnimation="PrepThrow"
    GrenadeThrowAnimation="Throw"

    bKFNeverThrow=True
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-40.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_NRP5_A.NRP5_FP_Mesh'
}