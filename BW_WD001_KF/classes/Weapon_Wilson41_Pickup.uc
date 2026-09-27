class Weapon_Wilson41_Pickup extends BallisticPickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if( Weapon_Wilson41_Main(I)!=None )
		{
			if( Inventory!=None )
				Inventory.Destroy();

			InventoryType = Class'Weapon_Wilson41Dual_Main';
			I.Destroy();
			return Super.SpawnCopy(Other);
		}
	}

	InventoryType = Default.InventoryType;
	Return Super.SpawnCopy(Other);
}

defaultproperties
{
	Weight=4.000000
	cost=400
	AmmoCost=20
	BuyClipSize=9
	PowerValue=30
	SpeedValue=40
	RangeValue=40
	SecondaryAmmoCost=10
	Description="Wilson 41-DB LeMat Revolver"
	ItemName="Wilson 41-DB LeMat Revolver"
	ItemShortName="Wilson 41 Revolver"
	AmmoItemName=".41 Wilson DB Bullets"
	SecondaryAmmoShortName="16 Gauge Shells"
	AmmoMesh=StaticMesh'BWKF_Wilson_SM.Wilson41_ClipPickup_SM'
	InventoryType=Class'BW_WD001_KF.Weapon_Wilson41_Main'
	PickupMessage="You got the Wilson 41-DB LeMat Revolver"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_Wilson_SM.Wilson41_MainPickup_SM'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
	PickupSound=Sound'BWKF_M806_SN.M806Pullout'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
