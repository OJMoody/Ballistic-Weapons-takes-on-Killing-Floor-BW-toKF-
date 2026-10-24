//=============================================================================
// NRP57 Grenade Pickup.
//=============================================================================
class Utility_NRP57Grenade_Pickup extends BallisticHandGrenadePickup;

defaultproperties
{
    Weight=0.000000
    cost=20
    PowerValue=5
    SpeedValue=60
    RangeValue=0
	StaticMesh=StaticMesh'BWKF_NRP5_SM.NRP57_MainPickup_SM'
    Description="NRP57 Frag Grenade"
    ItemName="NRP57 Frag Grenade"
    ItemShortName="NRP57 Grenade"
    InventoryType=Class'BW_WD000_KF.Utility_NRP57Grenade_Main'
	AmmoAmount(0)=4
    AmmoAmount(1)=4
    PickupMessage="You picked up the NRP57 Frag Grenade"
    PickupSound=none
    PickupForce="AssaultRiflePickup"
    CollisionHeight=5.000000
    CorrespondingPerkIndex=4
}