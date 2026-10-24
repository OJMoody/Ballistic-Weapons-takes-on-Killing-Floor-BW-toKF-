//=============================================================================
// NRP57 Grenade Pickup.
//=============================================================================
class Utility_FP7Grenade_Pickup extends BallisticHandGrenadePickup;

defaultproperties
{
    Weight=0.000000
    cost=20
    PowerValue=5
    SpeedValue=60
    RangeValue=0
	StaticMesh=StaticMesh'BWKF_FP7_SM.FP7_MainPickup_SM'
    Description="FP7 Incendiary Grenade"
    ItemName="FP7 Incendiary Grenade"
    ItemShortName="FP7 Grenade"
    InventoryType=Class'BW_WD000_KF.Utility_FP7Grenade_Main'
	AmmoAmount(0)=4
    AmmoAmount(1)=4
    PickupMessage="You picked up the FP7 Incendiary Grenade"
    PickupSound=none
    PickupForce="AssaultRiflePickup"
    CollisionHeight=5.000000
    CorrespondingPerkIndex=4
}