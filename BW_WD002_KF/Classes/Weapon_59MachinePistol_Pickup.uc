class Weapon_59MachinePistol_Pickup extends BallisticPickup;

defaultproperties
{
	Weight=0.000000
	cost=400
	AmmoCost=20
	BuyClipSize=8
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="Fifty-9 Machine Pistol"
	ItemName="Fifty-9 Machine Pistol"
	ItemShortName="Fifty-9 Machine Pistol"
	AmmoItemName="9mm bullets"
	//AmmoMesh=StaticMesh'BWKF_M806_SM.M806_ClipPickup_SM'
	InventoryType=Class'BW_WD002_KF.Weapon_59MachinePistol_Main'
	PickupMessage="You got the Fifty-9 Machine Pistol"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_M806_SM.M806_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=5
	CorrespondingPerkIndex=0
}
