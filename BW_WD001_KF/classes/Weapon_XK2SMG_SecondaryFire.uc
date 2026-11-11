class Weapon_XK2SMG_SecondaryFire extends BallisticShotgunFire;


//=============================================================================
// FIRE PERMISSION
//=============================================================================

simulated function bool AllowFire()
{
    return Weapon != None && Super(WeaponFire).AllowFire();
}


//=============================================================================
// SECONDARY FIRE
//=============================================================================

simulated event ModeDoFire()
{
    // AMP attachment and removal are handled
    // by Weapon_XK2SMG_Main.
}


simulated function StopFiring()
{
    Super.StopFiring();
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    AmmoPerFire=0
    bWaitForRelease=True
    FireRate=1.000000
}