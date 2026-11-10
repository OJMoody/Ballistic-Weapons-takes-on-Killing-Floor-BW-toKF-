//=============================================================================
// EKS-43 Katana Pickup.
//=============================================================================
class Weapon_EKS43Katana_Pickup extends BallisticWeaponPickup;

defaultproperties
{
	Weight=6.000000
	cost=800
	PowerValue=80
	SpeedValue=50
	RangeValue=-20
	Description="EKS-43 Katana"
	ItemName="EKS-43 Katana"
	ItemShortName="EKS-43 Katana"
	InventoryType=Class'BW_WD001_KF.Weapon_EKS43Katana_Main'
	PickupMessage="You picked up the EKS-43 Katana"
	PickupSound=Sound'BWKF_EKS43_SN.EKS43.EKS-Pullout'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_EKS43_SM.Pickups.EKS_MainPickup_SM'
	CollisionHeight=5.000000
	CorrespondingPerkIndex=4
}
