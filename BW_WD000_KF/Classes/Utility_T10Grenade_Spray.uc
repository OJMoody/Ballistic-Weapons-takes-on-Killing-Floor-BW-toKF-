class Utility_T10Grenade_Spray extends BallisticEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        Acceleration=(Z=40.0)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.4,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.0,Color=(B=64,G=64,R=64,A=64))
        Opacity=0.49
        FadeOutStartTime=0.26
        FadeInEndTime=0.26
        MaxParticles=80
        SpinsPerSecondRange=(X=(Max=0.1))
        StartSpinRange=(X=(Max=1.0))
        SizeScale(0)=(RelativeSize=0.1)
        SizeScale(1)=(RelativeTime=0.28,RelativeSize=0.2)
        SizeScale(2)=(RelativeTime=1.0,RelativeSize=2.0)
        StartSizeRange=(X=(Min=15.0,Max=25.0),Y=(Min=15.0,Max=25.0),Z=(Min=15.0,Max=25.0))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'BWKF_Core_T.Effects.Smoke7'
        LifetimeRange=(Min=1.0,Max=2.0)
        StartVelocityRange=(X=(Min=80.0,Max=120.0),Y=(Min=-15.0,Max=15.0),Z=(Min=-15.0,Max=15.0))
        VelocityLossRange=(X=(Min=1.0,Max=1.0),Y=(Min=1.0,Max=1.0),Z=(Min=1.0,Max=1.0))
    End Object
    Emitters(0)=SpriteEmitter'BW_WD000_KF.Utility_T10Grenade_Spray.SpriteEmitter0'

    AutoDestroy=True
    bHardAttach=True
}