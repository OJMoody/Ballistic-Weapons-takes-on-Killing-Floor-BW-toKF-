//=============================================================================
// Brass_Uzi.
//
// A pistol shell casing that flies out left
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
//=============================================================================
class Weapon_59MachinePistol_Brass extends BWBrass_Default;

defaultproperties
{
     RandomDir=(Pitch=0,Yaw=0,Roll=0)
     bAddOwnerVelocity=False
	 StartVelocity=(X=-15.00000,Y=-150.000000,Z=40.000000)
     StaticMesh=StaticMesh'BWKF_Core_SM.Brass.EmptyPistolRound'
	 DrawScale=0.200000
}