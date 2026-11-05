//=============================================================================
// DT_BWExplode.
//
// Base damage type that implements some gore for explosions
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DT_BWExplode extends BallisticDamageType;

defaultproperties
{
    EffectChance=1.000000
    bIgniteFires=True
    DamageDescription=",Explode,Hazard,NonSniper,"
    bLocationalHit=False
    bThrowRagdoll=True
    GibModifier=2.000000
    PawnDamageSounds(0)=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletFlesh'
    GibPerterbation=0.500000
    KDamageImpulse=20000.000000
	TransientSoundVolume=2
}