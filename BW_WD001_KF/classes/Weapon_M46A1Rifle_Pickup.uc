class Weapon_M46A1Rifle_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_M763_SM.M763_MainPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_M46A1Rifle_Main'
	PickupSound=Sound'BWKF_M763_SN.M763.M763Pullout'
	StaticMesh=StaticMesh'BWKF_M763_SM.M763_MainPickup_SM'
	
	Weight=8.000000
	cost=900
	AmmoCost=20
	BuyClipSize=24
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="M46A1 'Jackle' Combat Rifle"
	ItemName="M46A1 'Jackle' Combat Rifle"
	ItemShortName="M46A1 Combat Rifle"
	AmmoItemName=".310 M46 Rounds"
	SecondaryAmmoShortName="M46 Proximity Grenades"
	PickupMessage="You picked up the M46 Combat Rifle"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=1
	CorrespondingPerkIndex=1
}
