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

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local array<int> HitPoints;
	local KFPawn HitPawn;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);

	if (Weapon.WeaponCentered())
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	else
		ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y + Weapon.EffectOffset.Z * Z);

	X = Vector(Dir);
	End = Start + TraceRange * X;
	Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);

	if (Other != None && Other != Instigator && Other.Base != Instigator)
	{
		if (!Other.bWorldGeometry)
		{
			HitPawn = KFPawn(Other);

			if (HitPawn != None)
			{
				if (!HitPawn.bDeleteMe)
					HitPawn.ProcessLocationalDamage(DamageMax, Instigator, HitLocation, Momentum * X, DamageType, HitPoints);
			}
			else
			{
				Other.TakeDamage(DamageMax, Instigator, HitLocation, Momentum * X, DamageType);
			}
		}
		else
		{
			HitLocation = HitLocation + 2.0 * HitNormal;
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
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

simulated function FlashMuzzleFlash()
{
	local Emitter WeldEmitter;

	WeldEmitter = Weapon.Spawn(Class'KFMod.WelderHitEmitter');

	if (WeldEmitter != None)
		Weapon.AttachToBone(WeldEmitter, BallisticWeapon(Weapon).FlashBoneRight);
}

defaultproperties
{
	ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0.0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0.0
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