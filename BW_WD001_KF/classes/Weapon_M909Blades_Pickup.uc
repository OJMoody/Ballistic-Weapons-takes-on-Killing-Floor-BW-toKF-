//=============================================================================
// Knife Pickup.
//=============================================================================
class Weapon_M909Blades_Pickup extends BallisticWeaponPickup;

defaultproperties
{
	Weight=0.000000
	cost=50
	PowerValue=5
	SpeedValue=60
	RangeValue=-20
	Description="Basic kitchen utensil. Sharp."
	ItemName="Knife"
	ItemShortName="Knife"
	InventoryType=Class'BW_WD001_KF.Weapon_M909Blades_Main'
	PickupMessage="You got the Kitchen Knife."
	PickupSound=none // can't ever drop this weapon
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'KF_pickups_Trip.Knife_pickup'
	CollisionHeight=5.000000
	CorrespondingPerkIndex=4
}
