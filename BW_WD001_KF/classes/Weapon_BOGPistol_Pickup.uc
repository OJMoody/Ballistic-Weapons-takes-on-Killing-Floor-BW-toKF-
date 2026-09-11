//=============================================================================
// BenelliPickup
//=============================================================================
// Benellie shotgun pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Weapon_BOGPistol_Pickup extends BallisticPickup;

defaultproperties
{
	Weight=4.000000
	cost=400
	AmmoCost=40
	BuyClipSize=2
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="BORT-85 Grenade Pistol"
	ItemName="BORT-85 Grenade Pistol"
	ItemShortName="BORT-85 Grenade Pistol"
	AmmoItemName="BORT-85 Grenades"
	AmmoMesh=StaticMesh'BWKF_BOGP_SM.BOGP_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_BOGPistol_Main'
	PickupMessage="You got the BORT-85 MP Grenade Pistol"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_BOGP_SM.BOGP_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
