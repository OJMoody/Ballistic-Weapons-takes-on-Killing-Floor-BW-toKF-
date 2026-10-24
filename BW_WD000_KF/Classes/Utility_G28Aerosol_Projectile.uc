class Utility_G28Aerosol_Projectile extends BallisticHandGrenadeProjectile;

#exec OBJ LOAD FILE=BWKF_G28M_SN.uax

var Actor AerosolTrail;
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
    local Vector X, Y, Z;

    if (bHasExploded)
        return;

    if (Role == ROLE_Authority)
    {
        C = Spawn(class'BW_WD000_KF.Utility_G28Aerosol_CloudControl', self,, HitLocation - HitNormal * 2);

        if (C != None)
            C.Instigator = Instigator;
    }

    if (Level.NetMode != NM_DedicatedServer && TrailClass != None && AerosolTrail == None)
	{
		GetAxes(rot(16384,0,0), X, Y, Z);

		X = X >> Rotation;
		Y = Y >> Rotation;
		Z = Z >> Rotation;

		AerosolTrail = Spawn(TrailClass, self,, Location + class'BUtil'.static.AlignedOffset(Rotation, TrailOffset), OrthoRotation(X, Y, Z));

		if (AerosolTrail != None)
			AerosolTrail.SetBase(self);

        PlaySound(Sound'BWKF_G28M_SN.G28.G28-Ignite',, 0.7,, 128, 1.0, true);
        AmbientSound = Sound'BWKF_G28M_SN.G28.G28-ToxinLoop';
    }

    // Prevent the standard grenade explosion from occurring.
    bHasExploded = true;
    LifeSpan = 12.0;
    SetTimer(10.5, false);
}

//=============================================================================
// TIMER
//=============================================================================

simulated function Timer()
{
    Super.Timer();

    if (LifeSpan < 3.0 && AerosolTrail != None)
    {
        AmbientSound = None;
        AerosolTrail.Destroy();
        AerosolTrail = None;
    }
}

//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (AerosolTrail != None)
    {
        AerosolTrail.Destroy();
        AerosolTrail = None;
    }

    if (PATrail != None)
    {
        PATrail.Destroy();
        PATrail = None;
    }

    AmbientSound = None;

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