//=============================================================================
// M806SightLEDs.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class Weapon_M806Pistol_SightLEDs extends BallisticEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.400000,Max=0.400000),Z=(Min=0.400000,Max=0.400000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=-26.200000,Y=-0.070000,Z=2.900000)
         StartSizeRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.100000,Max=0.100000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'BWKF_Core_T.Particles.HotFlareA1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'BW_WD001_KF.Weapon_M806Pistol_SightLEDs.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.400000,Max=0.400000),Z=(Min=0.400000,Max=0.400000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=1.400000,Y=-0.350000,Z=2.6700000)
         StartSizeRange=(X=(Min=0.080000,Max=0.080000),Y=(Min=0.080000,Max=0.080000),Z=(Min=0.080000,Max=0.080000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'BWKF_Core_T.Particles.HotFlareA1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'BW_WD001_KF.Weapon_M806Pistol_SightLEDs.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.400000,Max=0.400000),Z=(Min=0.400000,Max=0.400000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=1.400000,Y=0.420000,Z=2.6700000)
         StartSizeRange=(X=(Min=0.080000,Max=0.080000),Y=(Min=0.080000,Max=0.080000),Z=(Min=0.080000,Max=0.080000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'BWKF_Core_T.Particles.HotFlareA1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(2)=SpriteEmitter'BW_WD001_KF.Weapon_M806Pistol_SightLEDs.SpriteEmitter2'

     bHidden=False
}
