//=============================================================================
// NRP57 Grenade Pickup.
//=============================================================================
class Utility_NRXGrenade_Pickup extends BallisticHandGrenadePickup;

defaultproperties
{
    Weight=0.000000
    cost=20
    PowerValue=5
    SpeedValue=60
    RangeValue=0
	StaticMesh=StaticMesh'BWKF_NRXS_SM.pickups.NRXS_MainPickup_SM'
    Description="NRX-82 'Scarab' Cluster Grenade"
    ItemName="NRX-82 'Scarab' Cluster Grenade"
    ItemShortName="NRX-82 Cluster Grenade"
    InventoryType=Class'BW_WD000_KF.Utility_NRP57Grenade_Main'
	AmmoAmount(0)=4
    AmmoAmount(1)=4
    PickupMessage="You picked up the NRX-82 'Scarab' Cluster Grenade"
    PickupSound=none
    PickupForce="AssaultRiflePickup"
    CollisionHeight=5.000000
    CorrespondingPerkIndex=4
}