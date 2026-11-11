class Weapon_XK2SMG_IceFlashEmitter extends ROMuzzleFlash1st;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
    local int i;
    
    for ( i=0; i<Emitters.length; ++i ) {
        Emitters[i].SpawnParticle(1);
    }
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=3.000000,Max=300.000000)
         RotatingSheets=1
         LowFrequencyNoiseRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=60.000000,Max=60.000000),Z=(Min=60.000000,Max=60.000000))
         LowFrequencyPoints=8
         HighFrequencyNoiseRange=(X=(Min=-3.000000,Max=3.000000),Y=(Min=-3.000000,Max=3.000000),Z=(Min=-3.000000,Max=3.000000))
         HighFrequencyPoints=3
         UseLowFrequencyScale=True
         UseBranching=True
         BranchProbability=(Min=1.000000,Max=1.000000)
         BranchEmitter=1
         BranchSpawnAmountRange=(Min=1.000000,Max=2.000000)
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.250000
         FadeOutStartTime=1.120000
         MaxParticles=8
         RotationNormal=(X=40.000000,Y=40.000000,Z=40.000000)
         StartSizeRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.700000,Max=0.700000))
         Texture=Texture'BWKF_Core_T.fx.Streak'
         InitialTimeRange=(Max=0.250000)
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-60.000000,Max=60.000000))
     End Object
     Emitters(0)=BeamEmitter'Weapon_XK2SMG_IceFlashEmitter.BeamEmitter0'

     Begin Object Class=SparkEmitter Name=SparkEmitter0
         LineSegmentsRange=(Min=0.000000,Max=0.000000)
         TimeBetweenSegmentsRange=(Min=0.150000,Max=0.150000)
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=150,G=150,R=150,A=32))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=150,G=150,R=150,A=32))
         Opacity=0.110000
         FadeOutStartTime=0.250000
         FadeInEndTime=0.250000
         MaxParticles=3
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         Texture=Texture'Effects_Tex.BulletHits.sparkfinal2'
         LifetimeRange=(Min=0.200000,Max=0.200000)
         StartVelocityRange=(X=(Min=200.000000,Max=350.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
     End Object
     Emitters(1)=SparkEmitter'Weapon_XK2SMG_IceFlashEmitter.SparkEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.150000
         FadeOutStartTime=0.640000
         MaxParticles=1
         StartLocationRange=(X=(Min=10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=45.000000),Y=(Min=45.000000),Z=(Min=45.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'BWKF_Core_T.fx.Dart_Muzzle-1'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(Z=(Min=-25.000000,Max=-15.000000))
     End Object
     Emitters(2)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=200,G=150,R=64,A=60))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=200,G=150,R=64,A=60))
         Opacity=0.200000
         FadeOutStartTime=0.028000
         FadeInEndTime=0.006000
         MaxParticles=1
         StartSizeRange=(X=(Min=30.000000,Max=60.000000),Y=(Min=30.000000,Max=60.000000),Z=(Min=30.000000,Max=60.000000))
         Texture=Texture'Effects_Tex.Smoke.MuzzleCorona1stP'
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(3)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.350000
         FadeOutStartTime=0.132000
         FadeInEndTime=0.015000
         MaxParticles=1
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
         SizeScale(0)=(RelativeSize=0.600000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.250000)
         StartSizeRange=(X=(Min=15.000000,Max=35.000000),Y=(Min=15.000000,Max=35.000000),Z=(Min=15.000000,Max=35.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.LightSmoke_8Frame'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.300000,Max=0.300000)
         StartVelocityRange=(X=(Min=60.000000,Max=150.000000),Z=(Min=-50.000000,Max=-15.000000))
     End Object
     Emitters(4)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.350000
         FadeOutStartTime=0.296000
         FadeInEndTime=0.016000
         MaxParticles=8
         StartLocationRange=(X=(Min=20.000000,Max=20.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
         SizeScale(0)=(RelativeSize=0.600000)
         SizeScale(1)=(RelativeTime=0.680000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=50.000000),Y=(Min=5.000000,Max=50.000000),Z=(Min=5.000000,Max=50.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_2'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Max=150.000000),Z=(Min=-50.000000,Max=-25.000000))
     End Object
     Emitters(5)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseCollision=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(X=150.000000,Z=-1000.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.250000,Max=0.250000),Y=(Min=0.250000,Max=0.250000),Z=(Min=0.250000,Max=0.250000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.600000
         FadeOutStartTime=0.500000
         UseRotationFrom=PTRS_Actor
         StartSizeRange=(X=(Min=0.700000,Max=1.700000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.snowchunksfinal'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=1.400000,Max=1.400000)
         StartVelocityRange=(X=(Min=500.000000,Max=800.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-300.000000,Max=300.000000))
     End Object
     Emitters(6)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter4'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter5
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-15.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.400000
         FadeOutStartTime=0.045000
         MaxParticles=1
         StartLocationRange=(X=(Min=10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.900000)
         StartSizeRange=(X=(Min=4.000000,Max=45.000000),Y=(Min=4.000000,Max=45.000000),Z=(Min=4.000000,Max=45.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.Smoke.grenadesmoke_fill'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(7)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter5'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter6
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.400000
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=0.050000,Max=0.050000))
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.300000)
         StartSizeRange=(X=(Min=15.000000,Max=20.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.BulletHits.snowfinal2'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=1.300000,Max=1.300000)
         StartVelocityRange=(X=(Min=50.000000,Max=250.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-50.000000,Max=-25.000000))
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.475000,RelativeVelocity=(X=0.100000,Y=0.200000,Z=0.200000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(8)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter6'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter7
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.650000
         FadeOutStartTime=0.175000
         MaxParticles=3
         StartLocationRange=(X=(Min=10.000000,Max=10.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.200000))
         StartSpinRange=(X=(Min=-0.300000,Max=0.300000))
         SizeScale(0)=(RelativeSize=0.400000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=35.000000,Max=60.000000),Y=(Min=35.000000,Max=60.000000),Z=(Min=35.000000,Max=60.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
         TextureUSubdivisions=8
         TextureVSubdivisions=8
         LifetimeRange=(Min=0.450000,Max=0.450000)
         StartVelocityRange=(Z=(Min=-20.000000,Max=-15.000000))
     End Object
     Emitters(9)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter7'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter8
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         UseVelocityScale=True
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.450000
         MaxParticles=6
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Min=-0.250000,Max=0.250000))
         SizeScale(0)=(RelativeSize=0.600000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.700000)
         StartSizeRange=(X=(Min=20.000000,Max=27.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'Effects_Tex.explosions.DSmoke_2'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=120.000000,Max=220.000000),Y=(Min=-75.000000,Max=75.000000),Z=(Min=-75.000000,Max=75.000000))
         VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
         VelocityScale(1)=(RelativeTime=0.475000,RelativeVelocity=(X=0.100000,Y=0.200000,Z=0.200000))
         VelocityScale(2)=(RelativeTime=1.000000)
     End Object
     Emitters(10)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter8'
	 
	 Begin Object Class=MeshEmitter Name=MeshEmitter3
         StaticMesh=StaticMesh'BWKF_XK2_SM.MuzzleFlash.XK2MuzzleFlash'
         UseMeshBlendMode=False
         RenderTwoSided=True
         UseParticleColor=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         Opacity=0.370000
         FadeOutStartTime=0.015000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSpinRange=(Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeSize=1.200000)
         StartSizeRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.150000,Max=0.150000),Z=(Min=0.150000,Max=0.150000))
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.250000,Max=0.250000)
         SpawnOnTriggerRange=(Min=1.000000,Max=1.000000)
         SpawnOnTriggerPPS=500000.000000
         StartVelocityRange=(X=(Min=30.000000,Max=30.000000))
     End Object
     Emitters(11)=MeshEmitter'Weapon_XK2SMG_IceFlashEmitter.MeshEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter9
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(Y=(Min=0.900000,Max=0.900000),Z=(Min=0.800000,Max=0.800000))
         Opacity=0.590000
         FadeOutStartTime=0.014000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=20.000000)
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         Texture=Texture'BWKF_Core_T.Particles.Smoke3'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.200000,Max=0.200000)
         SpawnOnTriggerRange=(Min=1.000000,Max=1.000000)
         SpawnOnTriggerPPS=500000.000000
     End Object
     Emitters(12)=SpriteEmitter'Weapon_XK2SMG_IceFlashEmitter.SpriteEmitter9'

}
