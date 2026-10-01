class Weapon_M806Pistol_Pickup extends BallisticPickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;
	local Inventory Result;

	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if(Weapon_M806DualPistol_Main(I)!=None)
		{
			return None;
		}

		if(Weapon_M806Pistol_Main(I)!=None)
		{
			InventoryType = Class'Weapon_M806DualPistol_Main';
			I.Destroy();

			Result = Super.SpawnCopy(Other);
			return Result;
		}
	}

	InventoryType = Default.InventoryType;
	return Super.SpawnCopy(Other);
}


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
	AmmoMesh=StaticMesh'BWKF_M806_SM.M806_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_M806Pistol_Main'
	PickupMessage="You got the M806A2 Pistol"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_M806_SM.M806_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
