class Weapon_EKS43Katana_SecondaryFire extends BallisticMeleeFire;

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
    FireSound=SoundGroup'BWKF_EKS43_SN.EKS43.EKS-Slash'
	StereoFireSoundRef="BWKF_EKS43_SN.EKS43.EKS-Slash"
	
	DamageMin=135.000000
	DamageMax=135.000000
	AmmoClass=None
	bHasPrep=False
	bFireOnRelease=False
	bWaitForRelease=False
    FireAnim="FireStab"
    FireRate=1.1
    BotRefireRate=1.1
    MeleeHitSounds(0)=Sound'KF_KatanaSnd.Katana_HitFlesh'
	MeleeHitEffectClass=class'Weapon_EKS43Katana_HitEffects'
}
