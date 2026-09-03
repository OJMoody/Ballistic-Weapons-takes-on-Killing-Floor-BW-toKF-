//=============================================================================
// BenelliPickup
//=============================================================================
// Benellie shotgun pickup class
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class Weapon_M806Pistol_Pickup extends BallisticPickup;

/*function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if( Single(I)!=None )
		{
			if( Inventory!=None )
				Inventory.Destroy();
			InventoryType = Class'Dualies';
			I.Destroyed();
			I.Destroy();
			return Super.SpawnCopy(Other);
		}
	}
	InventoryType = Default.InventoryType;
	Return Super.SpawnCopy(Other);
}*/

defaultproperties
{
	Weight=0.000000
	cost=0
	AmmoCost=20
	BuyClipSize=8
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	Description="M806A2 Pistol"
	ItemName="M806A2 Pistol"
	ItemShortName="M806A2 Pistol"
	AmmoItemName=".45 high velocity M806 bullets"
	AmmoMesh=StaticMesh'BW_M806_SM.M806_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_M806Pistol_Main'
	PickupMessage="You got the M806A2 Pistol"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BW_M806_SM.M806_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
