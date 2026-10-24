class Utility_FP7Grenade_GroundFire extends BallisticEmitter
    placeable;

const BURNINTERVAL = 0.2;

var float BurnTime;
var float Damage;
var() class<DamageType> DamageType;

var AvoidMarker Fear;
var Controller InstigatorController;
var Utility_FP7Grenade_FireControl FireControl;

//=============================================================================
// INITIALIZATION
//=============================================================================

function Reset()
{
    Destroy();
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_Client)
        SetTimer(BURNINTERVAL + (FRand() * 0.5), True);

    BurnTime -= 4 * FRand();

    if (Level.NetMode == NM_DedicatedServer)
    {
        if (Emitters.Length > 0)
            Emitters[0].Disabled = True;
        if (Emitters.Length > 1)
            Emitters[1].Disabled = True;
        if (Emitters.Length > 2)
            Emitters[2].Disabled = True;
    }
}

//=============================================================================
// LIFETIME
//=============================================================================

simulated function Tick(float DT)
{
    Super.Tick(DT);

    if (BurnTime == 666)
        return;

    BurnTime -= DT;

    if (BurnTime <= 0)
    {
        Kill();
        BurnTime = 666;
    }
}

singular simulated event BaseChange()
{
    if (Mover(Base) != None)
        Destroy();
}

//=============================================================================
// LANDING
//=============================================================================

function Landed(vector HitNormal)
{
    HitWall(HitNormal, None);
}

function HitWall(vector HitNormal, Actor Wall)
{
    SetPhysics(PHYS_None);

    if (Level.NetMode == NM_Client)
        return;

    bCollideWorld = False;
    SetCollision(True, False, False);
    SetCollisionSize(72, 72);

    Fear = Spawn(Class'AvoidMarker');

    if (Fear != None)
    {
        Fear.SetCollisionSize(120, 120);
        Fear.StartleBots();
    }
}

//=============================================================================
// DAMAGE
//=============================================================================

function Timer()
{
    local Actor A;
    local Pawn P;

    if (Level.NetMode == NM_DedicatedServer && BurnTime == 666)
    {
        Destroy();
        return;
    }

    if (PhysicsVolume != None && PhysicsVolume.bWaterVolume)
        return;

    foreach TouchingActors(Class'Actor', A)
    {
        P = Pawn(A);

        if (P != None)
        {
            if (FireControl != None)
                FireControl.TryDamage(P, BURNINTERVAL, DamageType);
        }
        else if (Role == ROLE_Authority)
        {
            if ((Instigator == None || Instigator.Controller == None)
                && InstigatorController != None)
                A.SetDelayedDamageInstigatorController(InstigatorController);

            Class'BallisticDamageType'.static.GenericHurt(
                A, Damage, Instigator, A.Location, vect(0,0,0), DamageType);
        }
    }
}

//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (Fear != None)
        Fear.Destroy();

    Super.Destroyed();
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (NewVolume != None && NewVolume.bWaterVolume)
    {
        if (Level.NetMode == NM_DedicatedServer)
            Destroy();
        else
            Kill();
    }
}

defaultproperties
{
    BurnTime=10.000000
    Damage=15.000000
    DamageType=Class'BW_WD000_KF.Utility_FP7Grenade_DamType'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.600000,Max=0.800000),Z=(Min=0.400000,Max=0.600000))
        FadeOutStartTime=0.500000
        MaxParticles=10
        StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=2.000000,Max=3.000000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=4.000000,Max=7.000000))
        InitialParticlesPerSecond=60.000000
        Texture=Texture'BWKF_Core_T.Particles.FlamePartsAlpha'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Z=(Max=125.000000))
    End Object
    Emitters(0)=SpriteEmitter'BW_WD000_KF.Utility_FP7Grenade_GroundFire.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter9
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.900000),Y=(Min=0.600000,Max=0.700000),Z=(Min=0.400000,Max=0.600000))
        FadeOutStartTime=0.400000
        FadeInEndTime=0.200000
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationOffset=(Z=15.000000)
        StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
        StartSpinRange=(X=(Min=0.500000,Max=0.500000))
        StartSizeRange=(X=(Min=30.000000,Max=50.000000))
        InitialParticlesPerSecond=4.000000
        Texture=Texture'BWKF_Core_T.Particles.BlazingSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(Z=(Max=65.000000))
    End Object
    Emitters(1)=SpriteEmitter'BW_WD000_KF.Utility_FP7Grenade_GroundFire.SpriteEmitter9'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter10
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        UniformSize=True
        Acceleration=(Z=60.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.400000,Max=0.800000),Z=(Min=0.000000,Max=0.400000))
        FadeOutStartTime=0.240000
        FadeInEndTime=0.075000
        MaxParticles=2
        DetailMode=DM_SuperHigh
        StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Max=30.000000))
        StartSizeRange=(X=(Min=7.000000,Max=70.000000),Y=(Min=7.000000,Max=70.000000),Z=(Min=7.000000,Max=70.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'BWKF_Core_T.Particles.AquaFlareA1'
        LifetimeRange=(Min=0.100000,Max=0.500000)
        StartVelocityRange=(Z=(Max=30.000000))
    End Object
    Emitters(2)=SpriteEmitter'BW_WD000_KF.Utility_FP7Grenade_GroundFire.SpriteEmitter10'

    AutoDestroy=True
    Physics=PHYS_Falling
    CollisionRadius=2.000000
    CollisionHeight=2.000000
    bCollideWorld=True
    bUseCylinderCollision=True
    Mass=30.000000
    bNotOnDedServer=False
}