class Weapon_EKS43Katana_MeleeFire extends BallisticMeleeFire;


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	MeleeHitEffectClass=class'Weapon_EKS43Katana_HitEffects'
	WallHitPoint=2
	NumSwipePoints=5
	bCanLunge=True

	TraceExtent=(X=0.000000,Y=15.000000,Z=15.000000)
	TraceRange=140.000000

	MeleeDamageMin=130.000000
	MeleeDamageMax=130.000000
	Momentum=150.000000

	MaxBonusHoldTime=1.500000
	ChargeDamageBonusFactor=1.000000

	bCanBackstab=True
	FlankDamageMult=1.150000
	BackDamageMult=1.300000

	FireSound=SoundGroup'BWKF_EKS43_SN.EKS43.EKS-Slash'
	StereoFireSoundRef="BWKF_EKS43_SN.EKS43.EKS-Slash"

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