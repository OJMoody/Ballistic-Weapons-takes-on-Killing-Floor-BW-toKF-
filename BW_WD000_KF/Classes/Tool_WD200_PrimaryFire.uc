class Tool_WD200_PrimaryFire extends BallisticInstantFire;

var Actor LastHitActor;
var localized string NoWeldTargetMessage;
var localized string CantWeldTargetMessage;
var float FailTime;
var int MaxAdditionalDamage;
var float WeldDamageDelay;
var bool bPreFiring;
var float PreFireDelay;

simulated event ModeDoFire()
{
	if( !AllowFire() )
		return;

	if( !bPreFiring && FireCount == 0 )
	{
		bPreFiring = true;

		if( Weapon.Mesh != None )
			Weapon.PlayAnim(PreFireAnim, PreFireAnimRate, 0.0);

		NextFireTime = Level.TimeSeconds + PreFireDelay;
		return;
	}

	if( bPreFiring )
	{
		bPreFiring = false;
	}

	Super.ModeDoFire();
}

function KFDoorMover GetDoor()
{
	local Actor A;
	local vector Dummy, End, Start;

	if( AIController(Instigator.Controller) != None )
	{
		return KFDoorMover(Instigator.Controller.Target);
	}

	Start = Instigator.Location + Instigator.EyePosition();
	End = Start + vector(Instigator.GetViewRotation()) * 100.0;

	Instigator.bBlockHitPointTraces = false;
	A = Instigator.Trace(Dummy, Dummy, End, Start, true);
	Instigator.bBlockHitPointTraces = Instigator.default.bBlockHitPointTraces;

	return KFDoorMover(A);
}

simulated function bool AllowFire()
{
	local KFDoorMover WeldTarget;

	WeldTarget = GetDoor();

	if( WeldTarget == None )
	{
		if( KFPlayerController(Instigator.Controller) != None )
		{
			KFPlayerController(Instigator.Controller).CheckForHint(54);

			if( FailTime + 0.5 < Level.TimeSeconds )
			{
				PlayerController(Instigator.Controller).ClientMessage(NoWeldTargetMessage, 'CriticalEvent');
				FailTime = Level.TimeSeconds;
			}
		}

		return false;
	}

	if( WeldTarget.bDisallowWeld )
	{
		if( PlayerController(Instigator.Controller) != None )
			PlayerController(Instigator.Controller).ClientMessage(CantWeldTargetMessage, 'CriticalEvent');

		return false;
	}

	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

defaultproperties
{
	DamageMin=10
	DamageMax=10
	MaxAdditionalDamage=0
	DamageType=Class'KFMod.DamTypeWelder'
	TransientSoundVolume=1.8
	FireRate=0.200000
	AmmoClass=Class'KFMod.WelderAmmo'
	AmmoPerFire=20
	FireSound=Sound'PatchSounds.WelderFire'
	PreFireAnim="PreFire"
	PreFireAnimRate=1.000000
	PreFireDelay=0.312500
	FireAnim="Fire"
	FireLoopAnim="Fire"
	FireLoopAnimRate=1.000000
	bWaitForRelease=False
	NoWeldTargetMessage="You must be near a weldable door to use the welder."
	CantWeldTargetMessage="You cannot weld this door."
	
	RecoilRate=0
	maxVerticalRecoilAngle=0
	maxHorizontalRecoilAngle=0
	ShellEjectClass=None
	ShellEjectBoneName=welder
	WeldDamageDelay=0.1
}