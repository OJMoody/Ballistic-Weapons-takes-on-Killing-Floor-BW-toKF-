class Weapon_RX22AFlamer_MuzzleFlame extends BallisticEmitter;

simulated event PostBeginPlay()
{
    local int i;

    Super.PostBeginPlay();

    for (i = 0; i < Emitters.Length; i++)
        Emitters[i].ZTest = true;
}

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        StaticMesh=StaticMesh'BWKF_RX22A_SM.MuzzleFlash.RX22AMuzzleFlash1'
        UseMeshBlendMode=False
        RenderTwoSided=True
        UseParticleColor=True
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        Acceleration=(X=400.000000)
        ColorScale(0)=(Color=(B=255,G=64,A=255))
        ColorScale(1)=(RelativeTime=0.442857,Color=(B=255,G=64,R=64,A=255))
        ColorScale(2)=(RelativeTime=0.896429,Color=(G=128,R=255,A=255))
        ColorScale(3)=(RelativeTime=1.000000,Color=(A=255))
        FadeOutFactor=(X=0.950000)
        FadeOutStartTime=0.040000
        FadeInEndTime=0.010000
        CoordinateSystem=PTCS_Relative
        MaxParticles=8
        StartLocationOffset=(X=-9.000000)
        SpinsPerSecondRange=(Z=(Max=4.000000))
        StartSpinRange=(Z=(Max=1.000000))
        SizeScale(0)=(RelativeSize=0.400000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=0.350000,Max=0.400000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        LifetimeRange=(Min=0.300000,Max=0.500000)
    End Object
    Emitters(0)=MeshEmitter'BW_WD001_KF.Weapon_RX22AFlamer_MuzzleFlame.MeshEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        SpinParticles=True
        UniformSize=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(Y=(Min=0.900000,Max=0.900000),Z=(Min=0.500000,Max=0.500000))
        FadeOutStartTime=0.080000
        CoordinateSystem=PTCS_Relative
        MaxParticles=15
        StartLocationOffset=(X=-9.000000)
        SpinsPerSecondRange=(X=(Max=2.000000))
        StartSpinRange=(X=(Max=1.000000))
        StartSizeRange=(X=(Min=1.000000,Max=2.000000),Y=(Min=1.000000,Max=2.000000),Z=(Min=1.000000,Max=2.000000))
        Texture=Texture'BWKF_Core_T.Particles.BlazingSubdivide'
        TextureUSubdivisions=4
        TextureVSubdivisions=2
        LifetimeRange=(Min=0.500000,Max=0.500000)
        StartVelocityRange=(X=(Min=400.000000,Max=800.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-40.000000,Max=40.000000))
    End Object
    Emitters(1)=SpriteEmitter'BW_WD001_KF.Weapon_RX22AFlamer_MuzzleFlame.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        ZTest=False
        UniformSize=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.700000,Max=0.700000))
        Opacity=0.560000
        FadeOutStartTime=0.560000
        FadeInEndTime=0.370000
        CoordinateSystem=PTCS_Relative
        MaxParticles=2
        StartLocationOffset=(X=7.000000)
        StartLocationRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
        StartSizeRange=(X=(Min=20.000000,Max=24.000000),Y=(Min=20.000000,Max=24.000000),Z=(Min=20.000000,Max=24.000000))
        Texture=Texture'BWKF_Core_T.Particles.FlareB2'
        LifetimeRange=(Min=1.000000,Max=1.000000)
    End Object
    Emitters(2)=SpriteEmitter'BW_WD001_KF.Weapon_RX22AFlamer_MuzzleFlame.SpriteEmitter1'
}