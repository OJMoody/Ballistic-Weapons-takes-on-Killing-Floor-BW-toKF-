class Utility_NRXGrenade_Projectile extends BallisticHandGrenadeProjectile;

defaultproperties
{
    StaticMesh=StaticMesh'BWKF_NRXS_SM.pickups.NRXS_MainProj_SM'
	
	ImpactDamage=15
    ImpactDamageType=Class'BW_WD000_KF.Utility_NRXGrenade_DamType'
	GrenadeExplosionEffectClass=Class'BW_WD000_KF.Utility_NRXGrenade_ExplosionEffects'
	//GrenadeExplosionSound=Sound'BWKF_NRXS_SN.NRXS.NRXS-Explode'
	GrenadeExplosionSound=SoundGroup'BWKF_Core_SN.Explosions.Explode-Small'

    MyDamageType=Class'BW_WD000_KF.Utility_NRXGrenade_DamType'

    ImpactSound=SoundGroup'BWKF_NRXS_SN.NRXS.NRXS-Concrete'
	
	ShrapnelCount=12
    ShrapnelClass=Class'KFMod.KFShrapnel'
}