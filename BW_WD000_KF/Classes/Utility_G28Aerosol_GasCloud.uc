class Utility_G28Aerosol_GasCloud extends BallisticEmitter
    placeable;

var Utility_G28Aerosol_CloudControl MyControl;
var float Density;
var() Sound IgniteSound;
var Pawn Ignitioneer;

simulated event Touch(Actor Other)
{
    local int i;

    if (Other == None || Other == self)
        return;

    for (i = 0; i < Touching.Length; i++)
    {
        if (Touching[i] == Other)
            return;
    }

    Touching[Touching.Length] = Other;
}

simulated event UnTouch(Actor Other)
{
    local int i;

    for (i = 0; i < Touching.Length; i++)
    {
        if (Touching[i] == Other)
        {
            Touching.Remove(i, 1);
            return;
        }
    }
}

//=============================================================================
// INITIALIZATION
//=============================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    MyControl = Utility_G28Aerosol_CloudControl(Owner);

    if (Level.NetMode == NM_DedicatedServer)
    {
        Emitters[0].Disabled = true;
        Emitters[1].Disabled = true;
    }
}

function Reset()
{
    Destroy();
}

//=============================================================================
// TERMINATION
//=============================================================================

simulated function Terminate(float Delay)
{
    SetTimer(Delay, false);
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

//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (MyControl != None)
        MyControl.CloudDie(self);

    Super.Destroyed();
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (NewVolume != None && NewVolume.bWaterVolume)
        Kill();
}

//=============================================================================
// DEFAULTS
//=============================================================================

defaultproperties
{
    Density=1.000000

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=20.000000)
        ColorScale(0)=(Color=(B=255,G=150,R=150,A=200))
        ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=150,R=150,A=200))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=64,G=58,R=58,A=64))
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Z=(Min=0.900000,Max=0.900000))
        Opacity=0.490000
        FadeOutStartTime=1.050000
        FadeInEndTime=1.050000
        CoordinateSystem=PTCS_Relative
        MaxParticles=200
        StartLocationRange=(X=(Min=-96.000000,Max=96.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=-32.000000,Max=32.000000))
        SpinsPerSecondRange=(X=(Max=0.010000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=150.000000,Max=200.000000),Z=(Min=150.000000,Max=200.000000))
        InitialParticlesPerSecond=0.700000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BWKF_Core_T.Particles.NewSmoke1g'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-10.000000))
    End Object
    Emitters(0)=SpriteEmitter'BW_WD000_KF.Utility_G28Aerosol_GasCloud.SpriteEmitter1'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=150,R=150,A=200))
        ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=150,R=150,A=200))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=64,G=58,R=58,A=64))
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Z=(Min=0.900000,Max=0.900000))
        Opacity=0.580000
        FadeOutStartTime=1.450000
        FadeInEndTime=0.675000
        CoordinateSystem=PTCS_Relative
        MaxParticles=20
        StartLocationRange=(X=(Min=-64.000000,Max=64.000000))
        SpinsPerSecondRange=(X=(Max=0.030000))
        StartSpinRange=(X=(Min=1.000000,Max=1.000000))
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        InitialParticlesPerSecond=0.750000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BWKF_Core_T.Particles.Smoke6'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.500000,Max=2.500000)
    End Object
    Emitters(1)=SpriteEmitter'BW_WD000_KF.Utility_G28Aerosol_GasCloud.SpriteEmitter0'

    AutoDestroy=True
    CollisionRadius=192.000000
    CollisionHeight=192.000000
    bCollideActors=True
    bUseCylinderCollision=True
    bNotOnDedServer=False
}