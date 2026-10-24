class Utility_FP7Grenade_Projectile extends BallisticHandGrenadeProjectile;

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Actor FireActor;

    if (bHasExploded)
        return;

    bHasExploded = True;

    Log("FP7: Explode called. Role="$Role$" Location="$Location);

    if (Role == ROLE_Authority)
    {
        FireActor = Spawn(Class'BW_WD000_KF.Utility_FP7Grenade_FireControl',,, Location + vect(0,0,16), rot(0,0,0));

        Log("FP7: FireControl spawn result="$FireActor);

        if (FireActor != None)
            FireActor.Instigator = Instigator;
    }

    Destroy();
}


defaultproperties
{
    StaticMesh=StaticMesh'BWKF_FP7_SM.pickups.FP7_MainProj_SM'

    ImpactDamage=15
    ImpactDamageType=Class'BW_WD000_KF.Utility_FP7Grenade_DamType'
    MyDamageType=Class'BW_WD000_KF.Utility_FP7Grenade_DamType'

    ImpactSound=Sound'BWKF_Core_SN.NRP57.NRP57-Concrete'

    DampenFactor=0.050000
    DampenFactorParallel=0.350000
    ExplodeTimer=2.000000
}