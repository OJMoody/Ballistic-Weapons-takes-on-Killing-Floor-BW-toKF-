class Weapon_M806Pistol_MeleeFire extends BallisticMeleeFire;


//=============================================================================
// AMMO
//=============================================================================

simulated function bool HasAmmo()
{
	return true;
}


//=============================================================================
// PRE-FIRE
//=============================================================================

function PlayPreFire()
{
	if (Weapon_M806Pistol_Main(Weapon) != none)
	{
		if (Weapon_M806Pistol_Main(Weapon).IsChamberOpen())
		{
			PreFireAnim = 'MeleePrepOpen';
			FireAnim = 'MeleeFireOpen';
		}
		else
		{
			PreFireAnim = 'MeleePrep';
			FireAnim = 'MeleeFire';
		}
	}

	Super.PlayPreFire();
}


//=============================================================================
// STRIKE
//=============================================================================

function PlayFiring()
{
	if (Weapon_M806Pistol_Main(Weapon) != none)
	{
		if (Weapon_M806Pistol_Main(Weapon).IsChamberOpen())
		{
			PreFireAnim = 'MeleePrepOpen';
			FireAnim = 'MeleeFireOpen';
		}
		else
		{
			PreFireAnim = 'MeleePrep';
			FireAnim = 'MeleeFire';
		}
	}

	Super.PlayFiring();
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	SwipePoints(0)=(Weight=3,Offset=(Pitch=2048,Yaw=2048))
	SwipePoints(1)=(Weight=1,Offset=(Pitch=1000,Yaw=1000))
	SwipePoints(2)=(Weight=2)
	SwipePoints(3)=(Weight=1,Offset=(Pitch=-1000,Yaw=-1000))
	SwipePoints(4)=(Weight=3,Offset=(Pitch=-2048,Yaw=-2048))

	WallHitPoint=2
	NumSwipePoints=5

	TraceExtent=(X=0.000000,Y=15.000000,Z=15.000000)
	TraceRange=140.000000

	DamageMin=35.000000
	DamageMax=35.000000
	Momentum=100.000000

	MaxBonusHoldTime=1.500000
	ChargeDamageBonusFactor=1.000000

	bCanBackstab=True
	FlankDamageMult=1.150000
	BackDamageMult=1.300000

	FireSound=Sound'BWKF_M806_SN.M806.M806MeleeFire'
	StereoFireSoundRef="BWKF_M806_SN.M806.M806MeleeFire"

	bFireOnRelease=True
	bWaitForRelease=True
	bModeExclusive=True

	FireRate=0.450000
	AmmoPerFire=0

	PreFireAnim="MeleePrep"
	FireAnim="MeleeFire"
	FireAnimRate=1.000000
	TweenTime=0.100000
}