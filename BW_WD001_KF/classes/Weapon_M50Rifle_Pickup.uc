class Weapon_M50Rifle_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_M46_SM.Pickups.M46_ClipPickup_Main'
	InventoryType=Class'BW_WD001_KF.Weapon_M50Rifle_Main'
	PickupSound=Sound'BWKF_M46_SN.M46.OA-AR_Pullout'
	StaticMesh=StaticMesh'BWKF_M46_SM.Pickups.M46A2_WeaponPickup_Main'
	
	Weight=8.000000
	cost=900
	AmmoCost=20
	BuyClipSize=24
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="M50 Assault Rifle"
	ItemName="M50 Assault Riflee"
	ItemShortName="M50 Assault Rifle"
	AmmoItemName="5.56mm Ammo"
	SecondaryAmmoShortName="M46 Proximity Grenades"
	PickupMessage="You picked up the M50 Assault Rifle"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=4
	CorrespondingPerkIndex=3
	DrawScale=0.500000
}
