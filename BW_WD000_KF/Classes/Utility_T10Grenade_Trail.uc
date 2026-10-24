class Utility_T10Grenade_Trail extends BallisticEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.0,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.9,Max=1.0),Y=(Min=0.8,Max=0.9),Z=(Min=0.5,Max=0.7))
        Opacity=0.35
        FadeOutStartTime=1.0
        MaxParticles=8
        StartSizeRange=(X=(Min=35.0,Max=50.0),Y=(Min=35.0,Max=50.0),Z=(Min=35.0,Max=50.0))
        InitialParticlesPerSecond=5.0
        Texture=Texture'BWKF_Core_T.Effects.Smoke7'
        LifetimeRange=(Min=1.0,Max=2.0)
        StartVelocityRange=(X=(Min=-5.0,Max=5.0),Y=(Min=-5.0,Max=5.0),Z=(Min=-5.0,Max=5.0))
    End Object
    Emitters(0)=SpriteEmitter'BW_WD000_KF.Utility_T10Grenade_Trail.SpriteEmitter0'

    AutoDestroy=True
}