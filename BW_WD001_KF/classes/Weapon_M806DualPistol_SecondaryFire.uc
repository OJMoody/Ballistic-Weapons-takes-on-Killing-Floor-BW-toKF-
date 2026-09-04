class Weapon_M806DualPistol_SecondaryFire extends KFFire;


//=============================================================================
// SECONDARY FIRE
//=============================================================================

simulated function ModeDoFire()
{
    local Weapon_M806DualPistol_Main M806;

    M806 = Weapon_M806DualPistol_Main(Weapon);

    if (M806 == None)
        return;

    M806.RequestLaserToggle();
}

simulated function bool AllowFire()
{
	local Weapon_M806DualPistol_Main M806;

	M806 = Weapon_M806DualPistol_Main(Weapon);

	if (M806 != None)
	{
		if (M806.bIsReloading)
			return false;

		if (M806.bLaserToggleInProgress)
			return false;

		if (M806.IsHoldingMelee())
			return false;
	}

	return true;
}



//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireRate=0.500000
    AmmoClass=Class'BW_WD001_KF.Weapon_M806DualPistol_Ammo'
    AmmoPerFire=0

    FireAnim="LightOnOff"
    FireAnimRate=1.000000

    FireSound=None
    FlashEmitterClass=None

    DamageMin=0
    DamageMax=0
    Momentum=0
    Spread=0.000000
    SpreadStyle=SS_None

    bFiringDoesntAffectMovement=True
    bDoClientRagdollShotFX=False
}