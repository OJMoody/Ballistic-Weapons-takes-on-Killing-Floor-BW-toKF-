class Utility_T10Grenade_GasCloud extends BallisticEmitter placeable;

var AvoidMarker Fear;
var Utility_T10Grenade_CloudControl MyControl;
var float Density;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    MyControl = Utility_T10Grenade_CloudControl(Owner);

    if (Level.NetMode != NM_Client)
    {
        Fear = Spawn(class'AvoidMarker', Self,, Location);

        if (Fear != None)
        {
            Fear.SetCollisionSize(200, 200);
            Fear.StartleBots();
        }

        if (Level.NetMode == NM_DedicatedServer)
        {
            Emitters[0].Disabled = True;
            Emitters[1].Disabled = True;
        }
    }
}

function Reset()
{
    Destroy();
}

simulated function Terminate(float Delay)
{
    SetTimer(Delay, False);
}

simulated function Timer()
{
    if (Level.NetMode == NM_DedicatedServer)
        GotoState('DSDying');
    else
        Kill();
}

state DSDying
{
Begin:
    Sleep(3.0);
    Destroy();
}

simulated function Destroyed()
{
    if (MyControl != None)
        MyControl.CloudDie(Self);

    if (Fear != None)
        Fear.Destroy();

    Super.Destroyed();
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (NewVolume != None && NewVolume.bWaterVolume)
        Kill();
}

defaultproperties
{
    Density=1.0

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=20.0)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.0,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.0,Max=0.0),Z=(Min=0.0,Max=0.0))
        Opacity=0.49
        FadeOutStartTime=1.05
        FadeInEndTime=1.05
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationRange=(X=(Min=-96.0,Max=96.0),Y=(Min=-32.0,Max=32.0),Z=(Min=-32.0,Max=32.0))
        SpinsPerSecondRange=(X=(Max=0.01))
        StartSpinRange=(X=(Max=1.0))
        SizeScale(0)=(RelativeSize=0.3)
        SizeScale(1)=(RelativeTime=1.0,RelativeSize=1.0)
        StartSizeRange=(X=(Min=150.0,Max=200.0),Y=(Min=150.0,Max=200.0),Z=(Min=150.0,Max=200.0))
        InitialParticlesPerSecond=1000.0
        ParticlesPerSecond=1.0
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BWKF_Core_T.Effects.Smoke7'
        SecondsBeforeInactive=0.0
        LifetimeRange=(Min=3.0,Max=3.0)
        StartVelocityRange=(X=(Min=-15.0,Max=15.0),Y=(Min=-15.0,Max=15.0),Z=(Min=-10.0,Max=10.0))
    End Object
    Emitters(0)=SpriteEmitter'BW_WD000_KF.Utility_T10Grenade_GasCloud.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.0,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.0,Max=0.0),Z=(Min=0.0,Max=0.0))
        Opacity=0.58
        FadeOutStartTime=1.45
        FadeInEndTime=0.675
        CoordinateSystem=PTCS_Relative
        MaxParticles=3
        StartLocationRange=(X=(Min=-64.0,Max=64.0))
        SpinsPerSecondRange=(X=(Max=0.03))
        StartSpinRange=(X=(Min=1.0,Max=1.0))
        SizeScale(0)=(RelativeSize=0.2)
        SizeScale(1)=(RelativeTime=1.0,RelativeSize=1.0)
        InitialParticlesPerSecond=1000.0
        ParticlesPerSecond=1.0
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BWKF_Core_T.Particles.Smoke6'
        SecondsBeforeInactive=0.0
        LifetimeRange=(Min=2.5,Max=2.5)
    End Object
    Emitters(1)=SpriteEmitter'BW_WD000_KF.Utility_T10Grenade_GasCloud.SpriteEmitter0'

    AutoDestroy=True
    CollisionRadius=192.0
    CollisionHeight=192.0
    bCollideActors=True
    bUseCylinderCollision=True
    bNotOnDedServer=False
}