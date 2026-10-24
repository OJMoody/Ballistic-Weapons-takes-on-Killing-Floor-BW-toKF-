class Utility_NRP57Grenade_Projectile extends BallisticHandGrenadeProjectile;

defaultproperties
{
    StaticMesh=StaticMesh'BWKF_NRP5_SM.pickups.NRP57_MainProj_SM'
	
	ImpactDamage=15
    ImpactDamageType=Class'BW_WD000_KF.Utility_NRP57Grenade_DamType'
	GrenadeExplosionEffectClass=Class'BW_WD000_KF.Utility_NRP57Grenade_ExplosionEffects'
	GrenadeExplosionSound=SoundGroup'BWKF_Core_SN.Explosions.Explode-Small'

    MyDamageType=Class'BW_WD000_KF.Utility_NRP57Grenade_DamType'

    ImpactSound=Sound'BWKF_Core_SN.NRP57.NRP57-Concrete'
}