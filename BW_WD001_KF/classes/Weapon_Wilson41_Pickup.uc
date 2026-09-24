//=============================================================================
// BenelliPickup
//=============================================================================
// Benellie shotgun pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Weapon_Wilson41_Pickup extends BallisticPickup;

defaultproperties
{
	Weight=4.000000
	cost=400
	AmmoCost=20
	BuyClipSize=9
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="Wilson-41 Revolver"
	ItemName="Wilson-41 Revolver"
	ItemShortName="Wilson-41 Revolver"
	AmmoItemName=""
	AmmoMesh=StaticMesh'BWKF_M806_SM.M806_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_Wilson41_Main'
	PickupMessage="You got the Wilson-41 Revolver"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_M806_SM.M806_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
