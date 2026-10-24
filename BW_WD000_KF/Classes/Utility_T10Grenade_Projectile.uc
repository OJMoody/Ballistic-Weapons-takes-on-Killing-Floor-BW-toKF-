class Utility_T10Grenade_Projectile extends BallisticHandGrenadeProjectile;

#exec OBJ LOAD FILE=BWKF_T10_SN.uax

var Actor PATrail;
var() class<Actor> PATrailClass;
var() vector TrailOffset;
var Utility_T10Grenade_Spray T10Spray;

simulated function InitEffects()
{
    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (Speed > 400 && PATrailClass != None && PATrail == None && Level.DetailMode == DM_SuperHigh)
    {
        PATrail = Spawn(PATrailClass, Self,, Location);

        if (PATrail != None)
            PATrail.SetBase(Self);
    }
}

simulated function Destroyed()
{
    if (PATrail != None)
    {
        PATrail.Destroy();
        PATrail = None;
    }

    if (T10Spray != None)
    {
        T10Spray.Destroy();
        T10Spray = None;
    }

    Super.Destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Utility_T10Grenade_CloudControl C;
    local vector X, Y, Z;

    if (bHasExploded)
        return;

    bHasExploded = True;

    if (Role == ROLE_Authority)
    {
        C = Spawn(class'Utility_T10Grenade_CloudControl', Self,, HitLocation + HitNormal * 2);

        if (C != None)
        {
            C.Instigator = Instigator;
            C.InstigatorController = InstigatorController;
        }
    }

    if (Level.NetMode != NM_DedicatedServer)
    {
        GetAxes(rot(16384,0,0), X, Y, Z);
        X = X >> Rotation;
        Y = Y >> Rotation;
        Z = Z >> Rotation;

        T10Spray = Spawn(class'Utility_T10Grenade_Spray', Self,, Location + class'BUtil'.static.AlignedOffset(Rotation, TrailOffset), OrthoRotation(X,Y,Z));

        if (T10Spray != None)
            T10Spray.SetBase(Self);

        PlaySound(Sound'BWKF_T10_SN.T10.T10-Ignite',, 0.7,, 128, 1.0, True);
        AmbientSound = Sound'BWKF_T10_SN.T10.T10-toxinLoop';
    }

    LifeSpan = 8.0;
    SetTimer(6.5, False);
}

simulated function Timer()
{
    Super.Timer();

    if (LifeSpan < 3.0 && T10Spray != None)
    {
        AmbientSound = None;
        T10Spray.Destroy();
        T10Spray = None;
    }
}

defaultproperties
{
    ExplodeTimer=2.0
    ImpactDamage=15
    ImpactDamageType=Class'BW_WD000_KF.Utility_NRP57Grenade_DamType'
    TrailOffset=(Z=8.0)
    PATrailClass=Class'BW_WD000_KF.Utility_T10Grenade_Trail'
    Damage=20.0
    DamageRadius=200.0
    MyDamageType=Class'BW_WD000_KF.Utility_T10Grenade_GasDamage'
    DrawScale=0.35
    SoundVolume=192
    SoundRadius=128.0

    StaticMesh=StaticMesh'BWKF_T10_SM.pickups.T10_MainProj_SM'
}