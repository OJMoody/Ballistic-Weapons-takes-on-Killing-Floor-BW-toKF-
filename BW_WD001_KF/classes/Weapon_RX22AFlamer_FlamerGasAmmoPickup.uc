class Weapon_RX22AFlamer_FlamerGasAmmoPickup extends KFAmmoPickup;

defaultproperties
{
    AmmoAmount=120
    InventoryType=Class'BW_WD001_KF.Weapon_RX22AFlamer_FlamerGasAmmo'
    PickupMessage="You picked up a tank of flamethrower gas."
	PickupForce="AssaultAmmoPickup"
	DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'BWKF_RX22A_SM.Pickups.RX22A_ClipPickup_SM'
    DrawScale=0.300000
}