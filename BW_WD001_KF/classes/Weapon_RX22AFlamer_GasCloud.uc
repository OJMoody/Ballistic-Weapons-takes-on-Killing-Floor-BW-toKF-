//=============================================================================
// Weapon_RX22AFlamer_GasCloud.
//
// A cloud of floating flamer fuel. Ignition creates a damaging explosion.
//
// Ported from RX22AGasCloud.
//=============================================================================

class Weapon_RX22AFlamer_GasCloud extends BW_FuelPatch
    placeable;

var Weapon_RX22AFlamer_FireControl GasControl;
var() Sound IgniteSound;
var Pawn Ignitioneer;

simulated function FuelChanged()
{
    Emitters[0].Opacity = FClamp(Fuel / MaxFuel, 0.15, 0.75) * 1.333;
    Emitters[1].Opacity = FClamp(Fuel / MaxFuel, 0.15, 0.75) * 1.333;
}

simulated event PostNetReceive()
{
    Super.PostNetReceive();

    if (bIgnited)
        Ignite(None);
}

simulated function Ignite(Pawn EventInstigator)
{
    local Weapon_RX22AFlamer_CloudBang Bang;

    bIgnited = true;

    if (Level.NetMode != NM_DedicatedServer)
    {
        Bang = Spawn(class'Weapon_RX22AFlamer_CloudBang',,,Location);

        Bang.InitCloudBang(Fuel / MaxFuel);
        PlaySound(IgniteSound,, 0.8,, 112);
    }

    if (Role == ROLE_Authority)
    {
        Ignitioneer = EventInstigator;
        HurtRadius(25 + Fuel * 5, 128 + Fuel * 3, class'Weapon_RX22AFlamer_DTCloudBomb', 10000, Location);
    }
}

simulated function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
    local Actor Victims;
    local float DamageScale, Dist;
    local vector Dir;
    local Pawn InstigatedBy;

    if (bHurtEntry)
        return;

    bHurtEntry = true;

    foreach VisibleCollidingActors(class'Actor', Victims, DamageRadius, HitLocation)
    {
        // Avoid applying blast damage to fluid surfaces.
        if ((Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')))
        {
            if (Ignitioneer != None && (Victims == Instigator || Instigator == None))
                InstigatedBy = Ignitioneer;
            else
                InstigatedBy = Instigator;

            Dir = Victims.Location - HitLocation;
            Dist = FMax(1, VSize(Dir));
            Dir = Dir / Dist;

            DamageScale = 1 - FMax(0, (Dist - Victims.CollisionRadius) / DamageRadius);

            Victims.TakeDamage
            (
                DamageScale * DamageAmount,
                InstigatedBy,
                Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,
                DamageScale * Momentum * Dir,
                DamageType
            );

            if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
                Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
        }
    }

    bHurtEntry = false;
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    if (bIgnited)
        return;

    if (class<BallisticDamageType>(DamageType) != None && !class<BallisticDamageType>(DamageType).default.bIgniteFires)
        return;

    bIgnited = true;
    SetTimer(0.2, false);
    Ignite(EventInstigator);
}

simulated event PostBeginPlay()
{
    SetTimer(0.5, true);

    Super.PostBeginPlay();

    if (Instigator == None && Owner != None)
        Instigator = Pawn(Owner);
}

simulated event Timer()
{
    local int i;

    if (bIgnited)
    {
        Destroy();
        return;
    }

    for (i = 0; i < Touching.Length; i++)
    {
        if (Touching[i] == None || Pawn(Touching[i]) == None)
            continue;

        if (GasControl != None)
            GasControl.SpraySoak(Touching[i], Instigator);

        Fuel -= 1;
    }

    Super.Timer();
}

simulated function Destroyed()
{
    if (GasControl != None)
        GasControl.PatchRemove(self);

    Super.Destroyed();
}

defaultproperties
{
    IgniteSound=Sound'BWKF_RX22A_SN.RX22A.RX22A-IgniteFire'
    Extent=128

    Begin Object Class=SpriteEmitter Name=SpriteEmitter6
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=5.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.800000,Max=0.800000))
        Opacity=0.620000
        FadeOutStartTime=1.220000
        FadeInEndTime=0.580000
        MaxParticles=2
        StartLocationOffset=(X=10.000000)
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        DrawStyle=PTDS_Darken
        Texture=Texture'BWKF_Core_T.Particles.Smoke1'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
    End Object
    Emitters(0)=SpriteEmitter'Weapon_RX22AFlamer_GasCloud.SpriteEmitter6'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter7
        ProjectionNormal=(X=1.000000,Z=0.000000)
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=5.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.800000,Max=0.800000))
        Opacity=0.560000
        FadeOutStartTime=1.740000
        FadeInEndTime=1.080000
        CoordinateSystem=PTCS_Relative
        MaxParticles=4
        StartLocationOffset=(X=4.000000)
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=40.000000,Max=40.000000)
        SpinsPerSecondRange=(X=(Max=0.050000))
        StartSpinRange=(X=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=70.000000,Max=90.000000),Y=(Min=70.000000,Max=90.000000),Z=(Min=70.000000,Max=90.000000))
        DrawStyle=PTDS_Darken
        Texture=Texture'BWKF_Core_T.Particles.Smoke5'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRadialRange=(Min=15.000000,Max=15.000000)
        GetVelocityDirectionFrom=PTVD_AddRadial
    End Object
    Emitters(1)=SpriteEmitter'Weapon_RX22AFlamer_GasCloud.SpriteEmitter7'

    RemoteRole=ROLE_SimulatedProxy
    bCanBeDamaged=True
    CollisionRadius=128.000000
    CollisionHeight=128.000000
    bCollideActors=True
    bUseCylinderCollision=True
}