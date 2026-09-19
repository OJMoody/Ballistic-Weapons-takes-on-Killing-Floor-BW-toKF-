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
    FireSound=SoundGroup'BWKF_A909_SN.A909.A909Slash'
	StereoFireSoundRef="BWKF_A909_SN.A909.A909Slash"
	
	DamageMin=55.000000
	DamageMax=55.000000
	AmmoClass=None
	bHasPrep=False
	bFireOnRelease=False
	bWaitForRelease=False
    FireAnim="FireStab"
    FireRate=1.1
    BotRefireRate=1.1
    MeleeHitSounds(0)=Sound'KF_KnifeSnd.Knife_HitFlesh'
	MeleeHitEffectClass=class'Weapon_A909Blades_HitEffects'
}
