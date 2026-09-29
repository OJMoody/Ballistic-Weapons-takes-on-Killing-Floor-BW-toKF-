class Tool_WD200_SecondaryFire extends Tool_WD200_PrimaryFire;

simulated function bool AllowFire()
{
	local KFDoorMover WeldTarget;

	WeldTarget = GetDoor();

	if( WeldTarget == None )
		return false;

	if( WeldTarget.WeldStrength <= 0 )
		return false;

	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

defaultproperties
{
	DamageMin=10
	DamageMax=10
	DamageType=Class'KFMod.DamTypeUnWeld'
	AmmoPerFire=15
	FireSound=Sound'PatchSounds.WelderFire'
	bWaitForRelease=False
}