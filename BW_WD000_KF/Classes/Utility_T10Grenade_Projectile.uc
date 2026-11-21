class Utility_T10Grenade_Projectile extends BallisticHandGrenadeProjectile;

#exec OBJ LOAD FILE=BWKF_T10_SN.uax

var Actor PATrail;
var() class<Actor> PATrailClass;
var() vector TrailOffset;

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

    // Prevent KFMod.Nade.Destroyed() from triggering another explosion on clients.
    if (Role < ROLE_Authority)
        bHasExploded = True;

    Super.Destroyed();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Utility_T10Grenade_CloudControl C;
    local vector X, Y, Z;
    local vector SprayLocation;
    local rotator SprayRotation;

    if (bHasExploded)
        return;

    bHasExploded = True;

    if (Role == ROLE_Authority)
    {
        GetAxes(rot(16384,0,0), X, Y, Z);
        X = X >> Rotation;
        Y = Y >> Rotation;
        Z = Z >> Rotation;

        SprayLocation = Location + class'BUtil'.static.AlignedOffset(Rotation, TrailOffset);
        SprayRotation = OrthoRotation(X,Y,Z);

        C = Spawn(class'Utility_T10Grenade_CloudControl', Self,, HitLocation + HitNormal * 2);

        if (C != None)
        {
            C.Instigator = Instigator;
            C.InstigatorController = InstigatorController;

            C.SprayLocation = SprayLocation;
            C.SprayRotation = SprayRotation;
            C.bSprayDataReady = True;       

			C.StartClientEffects();
		}
    }

    LifeSpan = 8.0;
    SetTimer(6.5, False);
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