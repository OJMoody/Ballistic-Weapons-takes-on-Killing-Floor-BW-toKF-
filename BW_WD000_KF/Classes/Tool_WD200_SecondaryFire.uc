class Tool_WD200_SecondaryFire extends BallisticInstantFire;

var Actor LastHitActor;
var localized string NoWeldTargetMessage;
var float FailTime;
var int MaxAdditionalDamage;

function PlayFiring()
{
	PlayerController(Instigator.Controller).ClientMessage("WD200 SECONDARY PLAYFIRING", 'CriticalEvent');

	Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
	Weapon.PlayOwnedSound(FireSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius, Default.FireAnimRate / FireRate, false);
	ClientPlayForceFeedback(FireForce);
	FireCount++;
}

simulated function Timer()
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal, AdjustedLocation;
	local rotator PointRot;
	local int MyDamage;

	if( !KFWeapon(Weapon).bNoHit )
	{

		if( MaxAdditionalDamage > 0 )
			MyDamage += Rand(MaxAdditionalDamage);

		PointRot = Instigator.GetViewRotation();
		StartTrace = Instigator.Location + Instigator.EyePosition();

		if( AIController(Instigator.Controller) != None && Instigator.Controller.Target != None )
		{
			EndTrace = StartTrace + vector(PointRot) * 100.0;
			Weapon.bBlockHitPointTraces = false;
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;

			if( HitActor == None )
			{
				EndTrace = Instigator.Controller.Target.Location;
				Weapon.bBlockHitPointTraces = false;
				HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
				Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;
			}

			if( HitActor == None )
			{
				HitLocation = Instigator.Controller.Target.Location;
				HitActor = Instigator.Controller.Target;
			}
		}
		else
		{
			EndTrace = StartTrace + vector(PointRot) * 100.0;
			Weapon.bBlockHitPointTraces = false;
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
			Weapon.bBlockHitPointTraces = Weapon.default.bBlockHitPointTraces;
		}

		LastHitActor = HitActor;

		if( LastHitActor != None && Level.NetMode != NM_Client )
		{
			AdjustedLocation = HitLocation;
			AdjustedLocation.Z = HitLocation.Z - (0.15 * Instigator.CollisionHeight);
			HitActor.TakeDamage(MyDamage, Instigator, HitLocation, vector(PointRot), class'DamTypeUnWeld');
			Spawn(class'KFWelderHitEffect',,, AdjustedLocation, rotator(HitLocation - StartTrace));
		}
	}
}

function KFDoorMover GetDoor()
{
	local Actor A;
	local vector Dummy, End, Start;

	if( AIController(Instigator.Controller) != None )
		return KFDoorMover(Instigator.Controller.Target);

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

	if( WeldTarget.WeldStrength <= 0 )
		return false;

	return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

defaultproperties
{
	DamageMin=10
	DamageMax=10
	MaxAdditionalDamage=0
	DamageType=Class'KFMod.DamTypeUnWeld'
	TransientSoundVolume=1.8
	FireRate=0.200000
	AmmoClass=Class'KFMod.WelderAmmo'
	AmmoPerFire=15
	FireSound=Sound'PatchSounds.WelderFire'
	PreFireAnim="PreFire"
	FireAnim="Fire"
	//EndFireAnim="EndFire"
	NoWeldTargetMessage="You must be near a weldable door to use the unweld function."
	
	RecoilRate=0
	maxVerticalRecoilAngle=0
	maxHorizontalRecoilAngle=0
	ShellEjectClass=None
	ShellEjectBoneName=welder
}