class Weapon_M46A1Rifle_ImpactManager extends BCImpactManager;

var() float		SurfaceRange;
var() float		MinFluidDepth;

simulated function SpawnEffects(int HitSurfaceType, vector Norm, optional byte Flags)
{
    local vector WLoc, WNorm;
    local bool bHitWater;
    local float ImpactDepth;

    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (PhysicsVolume.bWaterVolume)
    {
        bHitWater = !PhysicsVolume.TraceThisActor(
            WLoc,
            WNorm,
            Location,
            Location + vect(0,0,1) * SurfaceRange
        );

        ImpactDepth = WLoc.Z - Location.Z;

        if (ImpactDepth > MinFluidDepth)
        {
            if (bHitWater && ImpactDepth < SurfaceRange)
                Spawn(Class'IE_WaterSurfaceBlast', Owner,, WLoc);

            HitEffects[0] = Class'IE_UnderWaterExplosion';

            // Retain the configured explosion sound instead of
            // referencing the unavailable underwater SoundGroup.
        }
    }

    Super.SpawnEffects(HitSurfaceType, Norm, Flags);
}

defaultproperties
{
     SurfaceRange=384.000000
     MinFluidDepth=128.000000
     HitEffects(0)=Class'BW_WD001_KF.Weapon_M46A1Rifle_ExplosionEffects'
     HitDecals(0)=Class'BW_Core_KF.AD_Explosion'
     HitSounds(0)=SoundGroup'BWKF_Core_SN.Explosions.Explode-Small'
     HitSoundVolume=1.000000
     HitSoundRadius=1024.000000
     EffectBackOff=64.000000
}