class Weapon_A909Blades_SecondaryFire extends BallisticMeleeFire;

simulated event ModeDoFire()
{
    bMeleeStrikeAnimationPlayed = false;

    Super(BallisticMeleeFire).ModeDoFire();
}

simulated function InitEffects()
{
}

defaultproperties
{
    DamageMin=55.000000
	DamageMax=55.000000
	bHasPrep=False
	bFireOnRelease=False
	bWaitForRelease=False
    FireAnim="FireStab"
    FireRate=1.1
    BotRefireRate=1.1
    MeleeHitSounds(0)=Sound'KF_KnifeSnd.Knife_HitFlesh'
    HitEffectClass=class'KnifeHitEffect'
}
