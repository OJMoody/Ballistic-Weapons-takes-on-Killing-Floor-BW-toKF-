//=============================================================================
// Weapon_RX22AFlamer_SurfaceFire.
//
// A fire on a surface. Intensity varies depending on fuel.
//
// Ported from RX22ASurfaceFire.
//=============================================================================

class Weapon_RX22AFlamer_SurfaceFire extends BW_FuelPatch
    placeable;

var() float Damage;
var() class<DamageType> DamageType;
var Controller InstigatorController;
var float LastTriggerTime;
var() Sound IgniteSound;

var Weapon_RX22AFlamer_FireControl GasControl;
var Pawn Ignitioneer;

var bool bPlayIgnite;
var Actor MyAmbientSoundActor;

replication
{
    unreliable if (Role == ROLE_Authority && bNetInitial)
        bPlayIgnite;
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (bPlayIgnite && Role < ROLE_Authority)
        PlayIgnite();
}

simulated function PlayIgnite()
{
    local Weapon_RX22AFlamer_TrailIgnite IgniteFX;

    if (Level.NetMode != NM_DedicatedServer)
    {
        IgniteFX = Spawn(class'Weapon_RX22AFlamer_TrailIgnite',,,Location);

        if (IgniteFX != None)
            IgniteFX.Trigger(self, Instigator);
    }

    if (Role == ROLE_Authority)
        bPlayIgnite = true;
}

// Scales a RangeVector
simulated function RangeVector MultiplyRV(RangeVector RV, float Scale)
{
    RV.X.Max *= Scale;
    RV.Y.Max *= Scale;
    RV.Z.Max *= Scale;
    RV.X.Min *= Scale;
    RV.Y.Min *= Scale;
    RV.Z.Min *= Scale;

    return RV;
}

simulated function FuelChanged()
{
    if (Level.NetMode == NM_DedicatedServer)
        return;

    Emitters[0].StartSizeRange = MultiplyRV(default.Emitters[0].StartSizeRange, Lerp(Fuel / MaxFuel, 1, 2.5));
    Emitters[1].StartSizeRange = MultiplyRV(default.Emitters[1].StartSizeRange, Lerp(Fuel / MaxFuel, 1, 2.25));

    if (Fuel / MaxFuel > 0.4)
    {
        Emitters[2].Disabled = false;
        Emitters[2].StartSizeRange = MultiplyRV(default.Emitters[2].StartSizeRange, Lerp((Fuel - 40) / (MaxFuel - 40), 1, 1.5));
    }
    else
        Emitters[2].Disabled = true;
}

function Timer()
{
    if (PhysicsVolume.bWaterVolume)
        return;

    Super.Timer();
}

function Toast(Actor A)
{
    if ((Instigator == None || Instigator.Controller == None) && InstigatorController != None)
        A.SetDelayedDamageInstigatorController(InstigatorController);

    if (Ignitioneer != None && (A == Instigator || BW_FuelPatch(A) != None) || (Instigator == None && InstigatorController == None))
        class'BallisticDamageType'.static.GenericHurt(A, Damage, Ignitioneer, A.Location, vect(0,0,0), DamageType);
    else
        class'BallisticDamageType'.static.GenericHurt(A, Damage, Instigator, A.Location, vect(0,0,0), DamageType);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        if (Instigator == None)
            Instigator = Pawn(Owner);

        if (InstigatorController == None && Instigator != None)
            InstigatorController = Instigator.Controller;
    }

    if (PhysicsVolume.bWaterVolume)
    {
        Destroy();
        return;
    }

    AddFuel(0);

    if (Level.NetMode != NM_DedicatedServer)
    {
        PlaySound(IgniteSound,, 0.4,, 96);
        MyAmbientSoundActor = Spawn(class'Weapon_RX22AFlamer_FlameSound',,,Location);
    }
}

simulated function Destroyed()
{
    if (MyAmbientSoundActor != None)
        MyAmbientSoundActor.Destroy();

    if (GasControl != None)
        GasControl.PatchRemove(self);

    Super.Destroyed();
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (NewVolume.bWaterVolume)
        Kill();
}

defaultproperties
{
    Damage=25.000000
    DamageType=Class'BW_WD001_KF.Weapon_RX22AFlamer_DTFireTrap'
    IgniteSound=Sound'BWKF_RX22A_SN.RX22A.RX22A-IgniteFire'

    Fuel=20.000000
    MaxFuel=150.000000
    Extent=64
    bCanIgnite=False

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        BlendBetweenSubdivisions=True
        Acceleration=(Z=80.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.900000,Max=0.900000),Z=(Min=0.600000,Max=0.600000))
        FadeOutStartTime=0.490000
        FadeInEndTime=0.490000
        MaxParticles=2
        StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
        StartSpinRange=(X=(Min=0.450000,Max=0.550000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=50.000000,Max=60.000000),Y=(Min=40.000000,Max=50.000000),Z=(Min=40.000000,Max=50.000000))
        Texture=Texture'BWKF_Core_T.Particles.BlazingSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(0)=SpriteEmitter'Weapon_RX22AFlamer_SurfaceFire.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter2
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.800000,Max=0.800000),Z=(Min=0.500000,Max=0.500000))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.500000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        DetailMode=DM_SuperHigh
        StartLocationOffset=(X=-31.000000)
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=40.000000,Max=60.000000),Y=(Min=40.000000,Max=60.000000),Z=(Min=40.000000,Max=60.000000))
        Texture=Texture'BWKF_Core_T.Particles.Explode2'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(1)=SpriteEmitter'Weapon_RX22AFlamer_SurfaceFire.SpriteEmitter2'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter5
        FadeOut=True
        FadeIn=True
        Disabled=True
        Backup_Disabled=True
        UniformSize=True
        Acceleration=(Z=80.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=32,G=64,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.800000,Max=0.800000),Z=(Min=0.500000,Max=0.500000))
        FadeOutStartTime=0.392000
        FadeInEndTime=0.392000
        MaxParticles=2
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        StartSizeRange=(X=(Max=140.000000),Y=(Max=140.000000),Z=(Max=140.000000))
        InitialParticlesPerSecond=5000.000000
        Texture=Texture'BWKF_Core_T.Particles.FlareB2'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=0.800000,Max=0.800000)
    End Object
    Emitters(2)=SpriteEmitter'Weapon_RX22AFlamer_SurfaceFire.SpriteEmitter5'

    AutoDestroy=True
    bNetInitialRotation=True
    RemoteRole=ROLE_SimulatedProxy
    bCollideActors=False
	bBlockActors=False
	CollisionRadius=72.000000
	CollisionHeight=1.000000
}