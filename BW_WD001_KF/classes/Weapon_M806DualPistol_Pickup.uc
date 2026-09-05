//=============================================================================
// BenelliPickup
//=============================================================================
// Benellie shotgun pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Weapon_M806DualPistol_Pickup extends BallisticPickup;

defaultproperties
{
	Weight=4.000000
	cost=150
	AmmoCost=20
	BuyClipSize=8
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="A Pair of M806A2 Pistols"
	ItemName="M806A2 Pistol"
	ItemShortName="M806A2 Pistol"
	AmmoItemName=".45 high velocity M806 bullets"
	AmmoMesh=StaticMesh'BWKF_M806_SM.M806_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_M806DualPistol_Main'
	PickupMessage="You got the M806A2 Pistol"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_M806_SM.M806_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
