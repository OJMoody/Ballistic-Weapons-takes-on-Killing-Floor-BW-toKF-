class Utility_G28Aerosol_Pickup extends BallisticHandGrenadePickup;

defaultproperties
{
    Weight=0.000000
    cost=20
    PowerValue=5
    SpeedValue=60
    RangeValue=0
	StaticMesh=StaticMesh'BWKF_G28M_SM.G28_MainPickup_SM'
    Description="FMD G28 Medicinal Aerosol"
    ItemName="FMD G28 Medicinal Aerosol"
    ItemShortName="G28 Aerosol"
    InventoryType=Class'BW_WD000_KF.Utility_G28Aerosol_Main'
	AmmoAmount(0)=4
    AmmoAmount(1)=4
    PickupMessage="You picked up the FMD G28 Medicinal Aerosol"
    PickupSound=none
    PickupForce="AssaultRiflePickup"
    CollisionHeight=5.000000
    CorrespondingPerkIndex=4
}