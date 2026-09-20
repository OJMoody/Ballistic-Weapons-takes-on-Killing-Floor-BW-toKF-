//=============================================================================
// BenelliBullet
//=============================================================================
// Benelli shotgun pellet
//=============================================================================
// Killing Floor Source
// Copyright (C) 2011 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class BallisticShotgunProj extends ShotgunBullet;

defaultproperties
{
     DamageAtten=5.000000
     MaxPenetrations=2
     PenDamageReduction=0.500000
     HeadShotDamageMult=1.500000
     Speed=3500.000000
     MaxSpeed=4000.000000
     bSwitchToZeroCollision=True
     Damage=35.000000
     DamageRadius=0.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'KFMod.DamTypeBenelli'
     ExplosionDecal=Class'KFMod.ShotgunDecal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'kf_generic_sm.Shotgun_Pellet'
     CullDistance=3000.000000
     LifeSpan=3.000000
     DrawScale=1.0
     Style=STY_Alpha
     ImpactEffect=class'BallisticWeaponHitEffects'
}
