class Weapon_XK2SMG_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_XK2_SM.Pickups.XK2_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_XK2SMG_Main'
	PickupSound=Sound'BWKF_XK2_SN.XK2.XK2-Pullout'
	StaticMesh=StaticMesh'BWKF_XK2_SM.Pickups.XK2_MainPickup_SM'
	
	Weight=5.000000
	cost=700
	AmmoCost=20
	BuyClipSize=24
	PowerValue=20
	SpeedValue=80
	RangeValue=40
	Description="XK2 Submachine Gun"
	ItemName="XK2 Submachine Gun"
	ItemShortName="XK2 Submachine Gun"
	AmmoItemName="9mm Ammo"
	SecondaryAmmoShortName="Ice Squall: E-D Amplifier"
	PickupMessage="You picked up the XK2 SubmachineGun"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=3
	CorrespondingPerkIndex=0
	DrawScale=1.000000
}
