//=============================================================================
// M806SightLEDs.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class Weapon_Wilson41_SightLEDs extends BallisticEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=1.00000,Max=1.000000),Y=(Min=1.00000,Max=1.000000),Z=(Min=0.400000,Max=0.400000))
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationOffset=(X=15.300000,Y=-0.005000,Z=5.320000)
         StartSizeRange=(X=(Min=0.050000,Max=0.050000),Y=(Min=0.050000,Max=0.050000),Z=(Min=0.050000,Max=0.050000))
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'BWKF_Core_T.Particles.HotFlareA1'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=SpriteEmitter'BW_WD001_KF.Weapon_Wilson41_SightLEDs.SpriteEmitter0'

     bHidden=False
}
