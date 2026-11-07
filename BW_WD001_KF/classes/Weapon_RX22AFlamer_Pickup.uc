class Weapon_RX22AFlamer_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_M46_SM.Pickups.M46_ClipPickup_Main'
	InventoryType=Class'BW_WD001_KF.Weapon_RX22AFlamer_Main'
	PickupSound=Sound'BWKF_M46_SN.M46.OA-AR_Pullout'
	StaticMesh=StaticMesh'BWKF_M46_SM.Pickups.M46A2_WeaponPickup_Main'
	
	Weight=12.000000
	cost=1500
	AmmoCost=20
	BuyClipSize=24
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="RX-22A Flamethrower"
	ItemName="RX-22A Flamethrower"
	ItemShortName="RX-22A Flamethrower"
	AmmoItemName=".310 M46 Rounds"
	PickupMessage="You picked up the RX-22A Flamethrower"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=4
	CorrespondingPerkIndex=3
	DrawScale=0.500000
}
