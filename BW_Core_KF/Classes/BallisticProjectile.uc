//=============================================================================
// BallisticProjectile.
//
// Extended projectile base for Ballistic Weapons.
//
// KF1 port based on the Ballistic Weapons BallisticProjectile implementation.
//
// Features:
// - Delayed start
// - Trail spawning
// - Projectile acceleration
// - Random starting rotation
// - Projectile penetration
// - Radius damage
// - Positional damage
// - Surface checking
// - View shake
// - Net tear-off support
//
//=============================================================================

class BallisticProjectile extends ROBallisticProjectile
	abstract;


//=============================================================================
// IMPACT / EFFECTS
//=============================================================================

// These are intentionally left as Actor classes for now.
// The full BCImpactManager system can be added later without changing the
// projectile architecture.

var() class<BCImpactManager> ImpactManager;
var() class<BCImpactManager> PenetrateManager;

var() bool bCheckHitSurface;


//=============================================================================
// PENETRATION
//=============================================================================

var() bool bPenetrate;
var() bool bCoverPenetrator;


//=============================================================================
// STARTUP / MOVEMENT
//=============================================================================

var() bool bRandomStartRotaion;
var() float AccelSpeed;
var() float StartDelay;


//=============================================================================
// TRAIL
//=============================================================================

var() class<Actor> TrailClass;
var Actor Trail;
var() Vector TrailOffset;


//=============================================================================
// DAMAGE
//=============================================================================

var() class<DamageType> MyRadiusDamageType;

var Actor HitActor;

var bool bCanHitOwner;
var bool bExploded;

var() bool bTearOnExplode;
var() float NetTrappedDelay;


//=============================================================================
// POSITIONAL DAMAGE
//=============================================================================

var() bool bUsePositionalDamage;

var() int DamageHead;
var() int DamageLimb;

var() globalconfig float DamageModHead;
var() globalconfig float DamageModLimb;

var() class<DamageType> DamageTypeHead;
var() class<DamageType> DamageTypeLimb;

var() float Deviance;


//=============================================================================
// VIEW EFFECTS
//=============================================================================

var() float ShakeRadius;

var() float MotionBlurRadius;
var() float MotionBlurFactor;
var() float MotionBlurTime;


//=============================================================================
// CAMERA SHAKE
//=============================================================================

var() vector ShakeRotMag;
var() vector ShakeRotRate;
var() float ShakeRotTime;

var() vector ShakeOffsetMag;
var() vector ShakeOffsetRate;
var() float ShakeOffsetTime;


//=============================================================================
// NETWORKING
//=============================================================================

var Vector TearOffHitNormal;


replication
{
	reliable if (bTearOff && Role == ROLE_Authority)
		TearOffHitNormal;
}


//=============================================================================
// TORN OFF
//=============================================================================

simulated event TornOff()
{
	Explode(Location, TearOffHitNormal);
}


//=============================================================================
// PRE BEGIN PLAY
//=============================================================================

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if (Physics == PHYS_Falling && (MaxSpeed > 3500 || Speed > 3500))
		bIgnoreTerminalVelocity = True;
}


//=============================================================================
// POST BEGIN PLAY
//=============================================================================

simulated function PostBeginPlay()
{
	local Rotator R;

	Super.PostBeginPlay();

	Velocity = Vector(Rotation);
	Velocity *= Speed;

	if (bRandomStartRotaion)
	{
		R = Rotation;
		R.Roll = Rand(65536);
		SetRotation(R);
	}
}


//=============================================================================
// POST NET BEGIN PLAY
//=============================================================================

simulated function PostNetBeginPlay()
{
	Acceleration = Normal(Velocity) * AccelSpeed;

	if (StartDelay > 0)
	{
		if (Role == ROLE_Authority || bNetOwner || bAlwaysRelevant)
		{
			SetPhysics(PHYS_None);
			bHidden = True;
			SetTimer(StartDelay, False);
			bDynamicLight = False;
			return;
		}
		else
			StartDelay = 0;
	}

	InitProjectile();

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (Level.bDropDetail || Level.DetailMode == DM_Low)
	{
		bDynamicLight = False;
		LightType = LT_None;
	}
	else
	{
		if (Level.GetLocalPlayerController() == None)
		{
			bDynamicLight = False;
			LightType = LT_None;
		}
	}
}


//=============================================================================
// EFFECT CLEANUP
//=============================================================================

simulated function DestroyEffects()
{
	if (Trail != None)
	{
		if (Emitter(Trail) != None)
			Emitter(Trail).Kill();
		else
			Trail.Destroy();
	}

	Trail = None;
}


simulated function Destroyed()
{
	DestroyEffects();

	Super.Destroyed();
}


//=============================================================================
// EFFECT INITIALIZATION
//=============================================================================

simulated function InitEffects()
{
	local Vector X;
	local Vector Y;
	local Vector Z;

	if (Level.NetMode != NM_DedicatedServer)
	{
		if (TrailClass != None && Trail == None)
		{
			GetAxes(Rotation, X, Y, Z);

			Trail = Spawn
			(
				TrailClass,
				self,
				,
				Location +
				X * TrailOffset.X +
				Y * TrailOffset.Y +
				Z * TrailOffset.Z,
				Rotation
			);

			if (Trail != None)
				Trail.SetBase(self);
		}
	}
}


//=============================================================================
// PROJECTILE INITIALIZATION
//=============================================================================

simulated function InitProjectile()
{
	InitEffects();
}


//=============================================================================
// START DELAY TIMER
//=============================================================================

simulated function Timer()
{
	if (StartDelay > 0)
	{
		StartDelay = 0;

		SetPhysics(default.Physics);

		bDynamicLight = default.bDynamicLight;
		bHidden = False;

		InitProjectile();

		return;
	}
}


//=============================================================================
// SPLASH
//=============================================================================

simulated function bool CanSplash()
{
	return False;
}


simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	local Actor A;
	local Vector HitLoc;
	local Vector HitNorm;
	local Vector Start;
	local Vector End;

	if
	(
		bReadyToSplash &&
		NewVolume != None &&
		NewVolume.bWaterVolume
	)
	{
		Start = Location - Velocity * (Level.TimeSeconds - LastRenderTime);
		End = Location;

		bTraceWater = True;

		A = Trace
		(
			HitLoc,
			HitNorm,
			End,
			Start,
			True
		);

		bTraceWater = False;

		if (A != NewVolume)
			HitLoc = Start;
	}
}


//=============================================================================
// SURFACE CHECK
//=============================================================================

simulated function CheckSurface
(
	Vector StartLocation,
	Vector StartNormal,
	out int Surf,
	optional out Actor Wall
)
{
	local Vector HitLoc;
	local Vector HitNorm;
	local Material HitMaterial;

	Wall = Trace
	(
		HitLoc,
		HitNorm,
		StartLocation - StartNormal * 4,
		StartLocation + StartNormal * 4,
		False,
		,
		HitMaterial
	);

	if (Wall == None)
		return;

	if (Vehicle(Wall) != None)
		Surf = 3;
	else if (HitMaterial != None)
		Surf = int(HitMaterial.SurfaceType);
	else
		Surf = int(Wall.SurfaceType);
}


//=============================================================================
// VIEW SHAKE
//=============================================================================

simulated function ShakeView(Vector HitLocation)
{
	local PlayerController PC;
	local float Dist;
	local float ScaleFactor;

	PC = Level.GetLocalPlayerController();

	if (PC == None || PC.ViewTarget == None)
		return;

	Dist = VSize(HitLocation - PC.ViewTarget.Location);

	if (ShakeRadius > 0 && Dist < ShakeRadius)
	{
		if (Dist < ShakeRadius / 3)
			ScaleFactor = 1.0;
		else
			ScaleFactor = (ShakeRadius - Dist) / ShakeRadius;

		PC.ShakeView
		(
			ShakeRotMag * ScaleFactor,
			ShakeRotRate,
			ShakeRotTime,
			ShakeOffsetMag * ScaleFactor,
			ShakeOffsetRate,
			ShakeOffsetTime
		);
	}
}


//=============================================================================
// SURFACE PENETRATION SCALE
//=============================================================================

function float SurfaceScale(int Surf, out byte bHard)
{
	switch (Surf)
	{
		Case 0:
			bHard = 1;
			return 0.5;

		Case 1:
			bHard = 1;
			return 0.5;

		Case 2:
			return 0.35;

		Case 3:
			bHard = 1;
			return 0.25;

		Case 4:
			return 0.55;

		Case 5:
			return 0.5;

		Case 6:
			return 1.0;

		Case 7:
			bHard = 1;
			return 0.75;

		Case 8:
			return 1.0;

		Case 9:
			return 1.0;

		Case 10:
			return 1.0;

		default:
			bHard = 1;
			return 0.5;
	}
}


//=============================================================================
// EXPLODE
//=============================================================================

simulated function Explode(Vector HitLocation, Vector HitNormal)
{
	local int Surf;
	local Actor Wall;

	if (bExploded)
		return;

	if (ShakeRadius > 0)
		ShakeView(HitLocation);

	if (bCheckHitSurface)
		CheckSurface(HitLocation, HitNormal, Surf, Wall);

	if (ImpactManager != None && bCheckHitSurface)
		ImpactManager.static.StartSpawn(HitLocation, HitNormal, Surf, self);

	BlowUp(HitLocation);

	bExploded = True;

	if
	(
		!bNetTemporary &&
		bTearOnExplode &&
		(
			Level.NetMode == NM_DedicatedServer ||
			Level.NetMode == NM_ListenServer
		)
	)
	{
		Velocity = vect(0,0,0);
		SetCollision(False, False, False);

		TearOffHitNormal = HitNormal;
		bTearOff = True;

		GoToState('NetTrapped');
	}
	else
		Destroy();
}


//=============================================================================
// HIDE PROJECTILE
//=============================================================================

function HideProjectile()
{
	SetPhysics(PHYS_None);

	bAlwaysRelevant = True;

	bHidden = True;

	SetTimer(StartDelay, False);

	bDynamicLight = False;

	AmbientSound = None;
}


//=============================================================================
// NET TRAPPED
//=============================================================================

state NetTrapped
{
	function BeginState()
	{
		HideProjectile();

		SetTimer(NetTrappedDelay, False);
	}


	event Timer()
	{
		Destroy();
	}


	simulated function Explode
	(
		Vector HitLocation,
		Vector HitNormal
	)
	{
	}
}


//=============================================================================
// RADIUS DAMAGE
//=============================================================================

function BlowUp(Vector HitLocation)
{
	if (Role < ROLE_Authority)
		return;

	if (DamageRadius > 0)
	{
		HurtRadius
		(
			Damage,
			DamageRadius,
			MyRadiusDamageType,
			MomentumTransfer,
			HitLocation
		);
	}

	MakeNoise(1.0);
}


//=============================================================================
// TOUCH
//=============================================================================

simulated function ProcessTouch
(
	Actor Other,
	Vector HitLocation
)
{
	local Vector X;

	if (Other == None)
		return;

	if (!bCanHitOwner && (Other == Instigator || Other == Owner))
		return;

	if (Role == ROLE_Authority && HitActor != Other)
		DoDamage(Other, HitLocation);

	if (CanPenetrate(Other) && Other != HitActor)
	{
		HitActor = Other;

		X = Normal(Velocity);

		SetLocation
		(
			HitLocation +
			X *
			(
				Other.CollisionHeight * 2 * X.Z +
				Other.CollisionRadius * 2 * (1 - X.Z)
			) *
			1.2
		);

		if (EffectIsRelevant(Location, False) && PenetrateManager != None)
			PenetrateManager.static.StartSpawn(HitLocation, Other.Location - HitLocation, Other.SurfaceType, Owner, 4);
		return;
	}

	if (Role == ROLE_Authority)
	{
		HitActor = Other;
		Explode(HitLocation, vect(0,0,1));
	}
}


//=============================================================================
// DIRECT DAMAGE
//=============================================================================

simulated function DoDamage
(
	Actor Other,
	Vector HitLocation
)
{
	local float Dmg;
	local class<DamageType> DT;

	if (Other == None)
		return;

	GetDamageVictim
	(
		Other,
		HitLocation,
		Normal(Velocity),
		Dmg,
		DT
	);

	if (Instigator == None || Instigator.Controller == None)
		Other.SetDelayedDamageInstigatorController(InstigatorController);

	Other.TakeDamage
	(
		Dmg,
		Instigator,
		HitLocation,
		MomentumTransfer * Normal(Velocity),
		DT
	);
}


//=============================================================================
// PENETRATION
//=============================================================================

simulated function bool CanPenetrate(Actor Other)
{
	if
	(
		!bPenetrate ||
		Other == None ||
		Other.bWorldGeometry ||
		Mover(Other) != None ||
		Vehicle(Other) != None
	)
	{
		return False;
	}

	return True;
}


//=============================================================================
// DAMAGE VICTIM
//=============================================================================

simulated function Actor GetDamageVictim
(
	Actor Other,
	Vector HitLocation,
	Vector Dir,
	out float Dmg,
	optional out class<DamageType> DT
)
{
	local Vector HitLocationMatchZ;

	Dmg = Damage;
	DT = MyDamageType;

	if (!bUsePositionalDamage)
	{
		if (Deviance > 0)
			Dmg *= 1 - Deviance + FRand() * Deviance * 2;

		return Other;
	}

	if (Pawn(Other) != None)
	{
		HitLocationMatchZ = HitLocation;
		HitLocationMatchZ.Z = Other.Location.Z;

		// Check for head shot.
		if (CheckHeadshot(Pawn(Other), HitLocation, Dir))
		{
			if (DamageHead > 0)
				Dmg = DamageHead;
			else
				Dmg *= DamageModHead;

			if (DamageTypeHead != None)
				DT = DamageTypeHead;
		}

		// Limb shots.
		else if
		(
			HitLocation.Z < Other.Location.Z - (Other.CollisionHeight / 6) ||
			VSize(HitLocationMatchZ - Other.Location) >= 20
		)
		{
			if (DamageLimb > 0)
				Dmg = DamageLimb;
			else
				Dmg *= DamageModLimb;

			if (DamageTypeLimb != None)
				DT = DamageTypeLimb;
		}
	}

	if (Deviance > 0)
		Dmg *= 1 - Deviance + FRand() * Deviance * 2;

	return Other;
}


//=============================================================================
// HEADSHOT CHECK
//=============================================================================

simulated function bool CheckHeadshot
(
	Pawn P,
	Vector HitLocation,
	Vector Dir
)
{
	if (P == None)
		return False;

	return P.IsHeadShot(HitLocation, Dir, 1.0);
}


//=============================================================================
// COVER PENETRATION
//=============================================================================

function float GetCoverReductionFor(Vector TargetLoc)
{
	local Vector HitLocation;
	local Vector HitLocationTwo;
	local Vector HitNormal;
	local Material HitMat;
	local float MatScale;
	local float Dist;
	local byte bHard;

	Trace
	(
		HitLocation,
		HitNormal,
		TargetLoc,
		Location,
		False,
		,
		HitMat
	);

	Trace
	(
		HitLocationTwo,
		HitNormal,
		Location,
		TargetLoc,
		False
	);

	if (HitMat != None)
		MatScale = SurfaceScale(int(HitMat.SurfaceType), bHard);
	else
		MatScale = SurfaceScale(0, bHard);

	Dist = VSize(HitLocation - HitLocationTwo);

	if (bHard == 0)
		return Dist / MatScale;

	if (Dist / MatScale > DamageRadius)
		return 0;

	return 1;
}


//=============================================================================
// TARGETED RADIUS DAMAGE
//=============================================================================

simulated function TargetedHurtRadius
(
	float DamageAmount,
	float DamageRadius,
	class<DamageType> DamageType,
	float Momentum,
	Vector HitLocation,
	optional Actor Victim
)
{
	local Actor Victims;
	local float DamageScale;
	local float DamageRadiusScale;
	local float Dist;
	local Vector Dir;

	if (bHurtEntry)
		return;

	bHurtEntry = True;

	foreach CollidingActors(class'Actor', Victims, DamageRadius, HitLocation)
	{
		if
		(
			Victims != self &&
			Victims.Role == ROLE_Authority &&
			!Victims.IsA('FluidSurfaceInfo') &&
			Victims != Victim &&
			Victims != HurtWall
		)
		{
			if (!FastTrace(Victims.Location, Location))
			{
				if (!bCoverPenetrator)
					continue;

				DamageRadiusScale =
					(DamageRadius - GetCoverReductionFor(Victims.Location)) /
					DamageRadius;

				if (DamageRadius * DamageRadiusScale < 16)
					continue;
			}
			else
				DamageRadiusScale = 1;

			Dir = Victims.Location - HitLocation;
			Dist = FMax(1, VSize(Dir));

			if
			(
				bCoverPenetrator &&
				DamageRadiusScale < 1 &&
				VSize(Dir) > DamageRadius * DamageRadiusScale
			)
				continue;

			Dir = Dir / Dist;

			DamageScale =
				1 -
				FMax
				(
					0,
					(Dist - Victims.CollisionRadius) /
					(DamageRadius * DamageRadiusScale)
				);

			if (Instigator == None || Instigator.Controller == None)
				Victims.SetDelayedDamageInstigatorController(InstigatorController);

			Victims.TakeDamage
			(
				DamageScale * DamageAmount,
				Instigator,
				Victims.Location -
					0.5 *
					(Victims.CollisionHeight + Victims.CollisionRadius) *
					Dir,
				DamageScale * Momentum * Dir,
				DamageType
			);
		}
	}

	bHurtEntry = False;
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	bRandomStartRotaion=True
	bTearOnExplode=True
	NetTrappedDelay=0.150000

	DamageModHead=1.500000
	DamageModLimb=0.750000

	Deviance=0.200000

	ShakeRadius=-1.000000

	MotionBlurRadius=-1.000000
	MotionBlurFactor=4.000000
	MotionBlurTime=5.000000

	ShakeRotMag=(X=256.000000,Y=256.000000,Z=256.000000)
	ShakeRotRate=(X=2500.000000,Y=2500.000000,Z=2500.000000)
	ShakeRotTime=6.000000

	ShakeOffsetMag=(X=10.000000,Y=10.000000,Z=20.000000)
	ShakeOffsetRate=(X=200.000000,Y=200.000000,Z=200.000000)
	ShakeOffsetTime=6.000000

	MaxSpeed=0.000000
	DamageRadius=0.000000

	DrawType=DT_StaticMesh
}