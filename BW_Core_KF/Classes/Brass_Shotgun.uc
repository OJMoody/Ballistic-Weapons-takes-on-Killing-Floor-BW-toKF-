//=============================================================================
// Brass_Shotgun.
//
// A Shotgun shell casing
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Brass_Shotgun extends BWBrass_Default;

var Emitter Trail;

// Initialize velocity and spin
simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2)
		Trail = Spawn(class'ShotgunBrassTrail',,, Location + vector(Rotation) * 19 * DrawScale);
	if (Trail != None)
	{
		class'BallisticEmitter'.static.ScaleEmitter(Trail, DrawScale);
		Trail.SetBase(self);
	}
}

simulated function Destroyed()
{
	if (Trail != None)
		Trail.Destroy();

	super.Destroyed();
}

defaultproperties
{
     HitSounds(0)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(1)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(2)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(3)=SoundGroup'BWKF_Core_SN.Brass.ShellMetal'
     HitSounds(4)=SoundGroup'BWKF_Core_SN.Brass.ShellWood'
     HitSounds(5)=SoundGroup'BWKF_Core_SN.Brass.ShellWood'
     HitSounds(6)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(7)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(8)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(9)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     HitSounds(10)=SoundGroup'BWKF_Core_SN.Brass.ShellConcrete'
     StaticMesh=StaticMesh'BWKF_Core_SM.Brass.EmptyShell'
     DrawScale=0.110000
}