class Weapon_A909Blades_MeleeFire extends BallisticMeleeFire;


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	HitEffectClass=class'Weapon_A909Blades_HitEffects'
	WallHitPoint=2
	NumSwipePoints=5

	TraceExtent=(X=0.000000,Y=15.000000,Z=15.000000)
	TraceRange=140.000000

	MeleeDamageMin=35.000000
	MeleeDamageMax=35.000000
	Momentum=100.000000

	MaxBonusHoldTime=1.500000
	ChargeDamageBonusFactor=1.000000

	bCanBackstab=True
	FlankDamageMult=1.150000
	BackDamageMult=1.300000

	FireSound=SoundGroup'BWKF_A909_SN.A909.A909Slash'
	StereoFireSoundRef="BWKF_A909_SN.A909.A909Slash"

	bFireOnRelease=True
	bWaitForRelease=True
	bModeExclusive=True

	FireRate=0.450000
	AmmoPerFire=0

	PreFireAnim="MeleePrep"
	FireAnim="MeleeFire"
	FireAnimRate=1.000000
	TweenTime=0.100000
}