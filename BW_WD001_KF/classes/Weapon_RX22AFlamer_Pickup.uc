class Weapon_RX22AFlamer_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_RX22A_SM.Pickups.RX22A_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_RX22AFlamer_Main'
	PickupSound=Sound'BWKF_RX22A_SN.RX22A.RX22A-Pullout'
	StaticMesh=StaticMesh'BWKF_RX22A_SM.Pickups.RX22A_MainPickup_SM'
	
	Weight=11.000000
	cost=1100
	AmmoCost=50
	BuyClipSize=24
	PowerValue=20
	SpeedValue=100
	RangeValue=70
	Description="RX-22A Flamethrower"
	ItemName="RX-22A Flamethrower"
	ItemShortName="RX-22A Flamethrower"
	AmmoItemName=".310 M46 Rounds"
	PickupMessage="You picked up the RX-22A Flamethrower"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=5
	CorrespondingPerkIndex=5
	DrawScale=0.350000
}
