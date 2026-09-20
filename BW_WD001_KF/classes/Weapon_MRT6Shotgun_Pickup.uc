class Weapon_MRT6Shotgun_Pickup extends BallisticPickup;

defaultproperties
{
	AmmoMesh=StaticMesh'BWKF_MRT6_SM.MRT6_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Main'
	PickupSound=Sound'BWKF_MRT6_SN.MRT6.MRT6Pullout'
	StaticMesh=StaticMesh'BWKF_MRT6_SM.MRT6_MainPickup_SM'
	
	Weight=4.000000
	cost=400
	AmmoCost=20
	BuyClipSize=10
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="MRT-6 Shotgun"
	ItemName="MRT-6 Shotgun"
	ItemShortName="MRT-6 Shotgun"
	AmmoItemName="12 Gauge Shells"
	PickupMessage="You got the MRT-6 Shotgun"
	PickupForce="AssaultRiflePickup"
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
