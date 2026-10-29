class Weapon_M46A1Rifle_SecondaryFire extends BallisticShotgunFire;

simulated function bool AllowFire()
{
    return Weapon != None && Super(WeaponFire).AllowFire();
}

simulated event ModeDoFire()
{
    // Mine input and animation are handled by Weapon_M46A1Rifle_Main.
}

simulated function StopFiring()
{
    Super.StopFiring();
}

defaultproperties
{
    AmmoPerFire=0
    bWaitForRelease=True
    FireRate=1.000000
}