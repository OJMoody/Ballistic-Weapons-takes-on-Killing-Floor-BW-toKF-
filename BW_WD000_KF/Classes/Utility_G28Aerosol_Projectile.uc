class Utility_G28Aerosol_Projectile extends BallisticHandGrenadeProjectile;

#exec OBJ LOAD FILE=BWKF_G28M_SN.uax

var() class<Actor> TrailClass;
var() vector TrailOffset;

var Actor PATrail;
var() class<Actor> PATrailClass;

//=============================================================================
// INITIALIZATION
//=============================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    InitEffects();
}

simulated function InitEffects()
{
    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (Speed > 400 && PATrailClass != None && PATrail == None
        && Level.DetailMode == DM_SuperHigh)
    {
        PATrail = Spawn(PATrailClass, self,, Location);

        if (PATrail != None)
            PATrail.SetBase(self);
    }
}

//=============================================================================
// AEROSOL DEPLOYMENT
//=============================================================================

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Utility_G28Aerosol_CloudControl C;
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

        C = Spawn(class'BW_WD000_KF.Utility_G28Aerosol_CloudControl', Self,, HitLocation + HitNormal * 2);

        if (C != None)
        {
            C.Instigator = Instigator;
            C.SprayLocation = SprayLocation;
            C.SprayRotation = SprayRotation;
            C.bSprayDataReady = True;

            C.StartClientEffects();
        }
    }

    LifeSpan = 12.0;
    SetTimer(10.5, False);
}


//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (PATrail != None)
    {
        PATrail.Destroy();
        PATrail = None;
    }

    AmbientSound = None;

    // Prevent KFMod.Nade.Destroyed() from triggering another explosion on clients.
    if (Role < ROLE_Authority)
        bHasExploded = True;

    Super.Destroyed();
}

defaultproperties
{
    TrailClass=Class'BW_WD000_KF.Utility_G28Aerosol_Spray'
    TrailOffset=(Z=8.000000)

    ImpactDamage=15
	ImpactDamageType=Class'BW_WD000_KF.Utility_NRP57Grenade_DamType'

    DampenFactor=0.050000
    DampenFactorParallel=0.350000
    ExplodeTimer=1.000000

    ImpactSound=SoundGroup'BWKF_Core_SN.NRP57.NRP57-Concrete'
    StaticMesh=StaticMesh'BWKF_G28M_SM.G28.G28_MainProj_SM'

    SoundVolume=192
    SoundRadius=128.000000

    Damage=120.000000
    DamageRadius=300.000000
}