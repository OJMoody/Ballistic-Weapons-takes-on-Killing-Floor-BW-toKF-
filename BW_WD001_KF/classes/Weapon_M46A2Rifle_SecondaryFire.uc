class Weapon_M46A2Rifle_SecondaryFire extends BallisticShotgunFire;

simulated function bool AllowFire()
{
    return Weapon != None && Super(WeaponFire).AllowFire();
}

simulated function InitEffects()
{
    Super.InitEffects();

    // Move the first-person grenade flash to its own muzzle bone.
    if (FlashEmitter != None && Weapon != None)
        Weapon.AttachToBone(FlashEmitter, 'GrenMuzzle');
}

simulated function TriggerGrenadeFlash()
{
    if (FlashEmitter != None)
        FlashEmitter.Trigger(Weapon, Instigator);
}

simulated event ModeDoFire()
{
    // Mine input and animation are handled by Weapon_M46A2Rifle_Main.
}

simulated function StopFiring()
{
    Super.StopFiring();
}

defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_AmmoGrenade'
    AmmoPerFire=0
    bWaitForRelease=True
    FireRate=1.000000
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_SecondaryFlashEmitter'
}