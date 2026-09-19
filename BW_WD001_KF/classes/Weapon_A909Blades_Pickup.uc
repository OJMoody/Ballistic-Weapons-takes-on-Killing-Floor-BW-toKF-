//=============================================================================
// A909 Skrith Blades Pickup.
//=============================================================================
class Weapon_A909Blades_Pickup extends BallisticWeaponPickup;

defaultproperties
{
	Weight=0.000000
	cost=50
	PowerValue=5
	SpeedValue=60
	RangeValue=-20
	Description="A909 Skrith Blades"
	ItemName="A909 Skrith Blades"
	ItemShortName="A909 Skrith Blades"
	InventoryType=Class'BW_WD001_KF.Weapon_A909Blades_Main'
	PickupMessage="You picked up the A909 Skrith Blades"
	PickupSound=none // can't ever drop this weapon
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_A909_SM.Pickups.A909_MainPickup_SM'
	CollisionHeight=5.000000
	CorrespondingPerkIndex=4
}
