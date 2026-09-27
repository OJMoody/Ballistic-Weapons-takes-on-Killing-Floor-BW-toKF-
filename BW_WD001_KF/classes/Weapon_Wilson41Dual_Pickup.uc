class Weapon_Wilson41Dual_Pickup extends BallisticPickup;

defaultproperties
{
	Weight=4.000000
	cost=800
	AmmoCost=20
	BuyClipSize=9
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	SecondaryAmmoCost=10
	Description="A Pair of Wilson 41-DB LeMat Revolvers"
	ItemName="Dual Wilson 41-DB LeMat Revolvers"
	ItemShortName="Dual Wilson 41 Revolvers"
	AmmoItemName=".41 Wilson DB Bullets"
	SecondaryAmmoShortName="16 Gauge Shells"
	AmmoMesh=StaticMesh'BWKF_Wilson_SM.Wilson41_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_Wilson41Dual_Main'
	PickupMessage="You got the Wilson 41-DB LeMat Revolver"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_Wilson_SM.Wilson41_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
