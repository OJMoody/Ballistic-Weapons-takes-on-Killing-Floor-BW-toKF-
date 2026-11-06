class Weapon_M50Rifle_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_M50_SM.Pickups.M50_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_M50Rifle_Main'
	PickupSound=Sound'BWKF_M50_SN.M50.M50Pullout'
	StaticMesh=StaticMesh'BWKF_M50_SM.Pickups.M50_MainPickup_SM'
	
	Weight=7.000000
	cost=700
	AmmoCost=20
	BuyClipSize=24
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="M50 Assault Rifle"
	ItemName="M50 Assault Rifle"
	ItemShortName="M50 Assault Rifle"
	AmmoItemName="5.56mm Ammo"
	SecondaryAmmoShortName="M900 HE Grenades"
	PickupMessage="You picked up the M50 Assault Rifle"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=4
	CorrespondingPerkIndex=3
	DrawScale=1.000000
}
