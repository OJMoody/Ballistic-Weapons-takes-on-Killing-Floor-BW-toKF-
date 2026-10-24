//=============================================================================
// NRP57 Grenade Pickup.
//=============================================================================
class Utility_T10Grenade_Pickup extends BallisticHandGrenadePickup;

defaultproperties
{
    Weight=0.000000
    cost=20
    PowerValue=5
    SpeedValue=60
    RangeValue=0
	StaticMesh=StaticMesh'BWKF_T10_SM.T10_MainPickup_SM'
    Description="T10 Toxic Grenade"
    ItemName="T10 Toxic Grenade"
    ItemShortName="T10 Grenade"
    InventoryType=Class'BW_WD000_KF.Utility_T10Grenade_Main'
	AmmoAmount(0)=4
    AmmoAmount(1)=4
    PickupMessage="You picked up the T10 Toxic Grenade"
    PickupSound=none
    PickupForce="AssaultRiflePickup"
    CollisionHeight=5.000000
    CorrespondingPerkIndex=4
}