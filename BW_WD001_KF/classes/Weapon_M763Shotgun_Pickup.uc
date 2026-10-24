class Weapon_M763Shotgun_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_M763_SM.M763_MainPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_M763Shotgun_Main'
	PickupSound=Sound'BWKF_M763_SN.M763.M763Pullout'
	StaticMesh=StaticMesh'BWKF_M763_SM.M763_MainPickup_SM'
	
	Weight=6.000000
	cost=700
	AmmoCost=20
	BuyClipSize=8
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="M763 Shotgun"
	ItemName="M763 Shotgun"
	ItemShortName="M763 Shotgun"
	AmmoItemName="12 Gauge Shells"
	SecondaryAmmoShortName="12 Gauge Gas Shells"
	PickupMessage="You picked up the M763 Shotgun"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=1
	CorrespondingPerkIndex=1
}
