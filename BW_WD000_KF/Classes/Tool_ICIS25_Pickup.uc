class Tool_ICIS25_Pickup extends BallisticWeaponPickup;

defaultproperties
{
    InventoryType=Class'Tool_ICIS25_Main'
	Weight=0.000000
	cost=0
	PowerValue=5
	SpeedValue=60
	RangeValue=-20
	Description="FMD ICIS-25 Stim"
	ItemName="FMD ICIS-25 Stim"
	ItemShortName="FMD ICIS-25 Stim"
	PickupMessage="You picked up the FMD ICIS-25 Stim Pack"
	PickupSound=none // can't ever drop this weapon
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'BWKF_ICIS_SM.Pickups.ICIS_MainPickup_SM'
	CollisionHeight=5.000000
	CorrespondingPerkIndex=4
}