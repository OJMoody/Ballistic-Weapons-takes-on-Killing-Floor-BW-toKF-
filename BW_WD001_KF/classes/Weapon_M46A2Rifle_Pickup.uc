class Weapon_M46A2Rifle_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_M46_SM.Pickups.M46_ClipPickup_Main'
	InventoryType=Class'BW_WD001_KF.Weapon_M46A2Rifle_Main'
	PickupSound=Sound'BWKF_M46_SN.M46.OA-AR_Pullout'
	StaticMesh=StaticMesh'BWKF_M46_SM.Pickups.M46A2_WeaponPickup_Main'
	
	Weight=8.000000
	cost=900
	AmmoCost=20
	BuyClipSize=24
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="M46A2 'Jackle' Combat Rifle"
	ItemName="M46A2 'Jackle' Combat Rifle"
	ItemShortName="M46A2 Combat Rifle"
	AmmoItemName=".310 M46 Rounds"
	SecondaryAmmoShortName="M46 Proximity Grenades"
	PickupMessage="You picked up the M46A2 Combat Rifle"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=1
	CorrespondingPerkIndex=1
	DrawScale=0.500000
}
