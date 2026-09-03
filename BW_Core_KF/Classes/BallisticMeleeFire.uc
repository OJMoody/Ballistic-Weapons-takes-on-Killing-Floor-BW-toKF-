//=============================================================================
// BallisticMeleeFire
//
// Fire class for charged swipe-type melee attacks.
//
// Based on Ballistic Weapons 2K4 BallisticMeleeFire,
// adapted for Killing Floor 1.
//=============================================================================
class BallisticMeleeFire extends BallisticInstantFire
    abstract;

var() float MeleeDamageMin;
var() float MeleeDamageMax;
var bool bMeleeStrikeAnimationPlayed;

//=============================================================================
// SWIPE DATA
//=============================================================================

struct SwipePoint
{
	var() int Weight;
	var() Rotator Offset;
};

struct SwipeHit
{
	var() int Weight;
	var() Actor Victim;
	var() Vector HitLoc;
	var() Vector HitDir;
};

var() array<SwipePoint> SwipePoints;
var() int WallHitPoint;
var() int NumSwipePoints;

var array<SwipeHit> SwipeHits;

var() Vector TraceExtent;


//=============================================================================
// CHARGE
//=============================================================================

var float HoldStartTime;
var bool bMeleeHolding;

var() float MaxBonusHoldTime;
var() float ChargeDamageBonusFactor;


//=============================================================================
// MELEE FATIGUE
//=============================================================================

var() float FatiguePerStrike;


//=============================================================================
// BACKSTAB
//=============================================================================

var() bool bCanBackstab;
var() float FlankDamageMult;
var() float BackDamageMult;


//=============================================================================
// ALLOW FIRE
//=============================================================================

simulated function bool AllowFire()
{
	if (KFWeapon(Weapon) == none)
		return false;

	if (KFWeapon(Weapon).bIsReloading)
		return false;

	if (KFPawn(Instigator) != none)
	{
		if (KFPawn(Instigator).SecondaryItem != none)
			return false;

		if (KFPawn(Instigator).bThrowingNade)
			return false;
	}

	return true;
}


//=============================================================================
// MELEE RANGE
//=============================================================================

function float MaxRange()
{
	return default.TraceRange;
}


//=============================================================================
// DAMAGE FACTORS
//=============================================================================

function float GetDamageFactor(Actor Victim, Vector TraceStart, Vector HitLocation)
{
	local float DamageFactor;
	local float ChargeAlpha;
	local Vector TestDir;

	DamageFactor = 1.0;

	//-------------------------------------------------------------------------
	// Charge damage
	//-------------------------------------------------------------------------

	if (MaxBonusHoldTime > 0.0)
	{
		if (HoldTime > 0.0)
		{
			ChargeAlpha = FClamp(HoldTime / MaxBonusHoldTime, 0.0, 1.0);
			DamageFactor *= 1.0 + ChargeDamageBonusFactor * ChargeAlpha;
		}
		else if (HoldStartTime != 0.0)
		{
			ChargeAlpha = FClamp((Level.TimeSeconds - HoldStartTime) / MaxBonusHoldTime, 0.0, 1.0);
			DamageFactor *= 1.0 + ChargeDamageBonusFactor * ChargeAlpha;
			HoldStartTime = 0.0;
		}
	}

	//-------------------------------------------------------------------------
	// Backstab / flank
	//-------------------------------------------------------------------------

	if (bCanBackstab && Victim != none)
	{
		TestDir = Normal(HitLocation - TraceStart);
		TestDir.Z = 0.0;

		if (Vector(Victim.Rotation) Dot TestDir > 0.6)
		{
			DamageFactor *= BackDamageMult;
		}
		else if (Vector(Victim.Rotation) Dot TestDir > 0.25)
		{
			DamageFactor *= FlankDamageMult;
		}
	}

	return FMin(3.0, DamageFactor);
}


//=============================================================================
// FIRE EFFECT
//=============================================================================

function DoFireEffect()
{
	local Vector StartTrace;
	local Rotator Aim;
	local Rotator PointAim;
	local int i;

	log("BALLISTIC MELEE: DoFireEffect() called");
	log("BALLISTIC MELEE: Instigator="$Instigator);
	log("BALLISTIC MELEE: Weapon="$Weapon);

	if (Instigator == none)
	{
		log("BALLISTIC MELEE: ERROR - Instigator is none");
		return;
	}

	StartTrace = Instigator.Location + Instigator.EyePosition();

	Aim = AdjustAim(StartTrace, AimError);

	log("BALLISTIC MELEE: StartTrace="$StartTrace);
	log("BALLISTIC MELEE: Aim="$Aim);
	log("BALLISTIC MELEE: NumSwipePoints="$NumSwipePoints);

	for (i = 0; i < NumSwipePoints; i++)
	{
		if (SwipePoints[i].Weight < 0)
			continue;

		PointAim = Rotator(Vector(SwipePoints[i].Offset) >> Aim);

		MeleeDoTrace(
			StartTrace,
			PointAim,
			i == WallHitPoint,
			SwipePoints[i].Weight
		);
	}

	log("BALLISTIC MELEE: SwipeHits="$SwipeHits.Length);

	for (i = 0; i < SwipeHits.Length; i++)
	{
		log("BALLISTIC MELEE: Hit "$i$" Victim="$SwipeHits[i].Victim$" Weight="$SwipeHits[i].Weight$" HitLoc="$SwipeHits[i].HitLoc);

		ApplyMeleeDamage(
			SwipeHits[i].Victim,
			SwipeHits[i].HitLoc,
			StartTrace,
			SwipeHits[i].HitDir
		);

		SwipeHits[i].Victim = none;
	}

	SwipeHits.Length = 0;
}


//=============================================================================
// MELEE TRACE
//=============================================================================

function MeleeDoTrace(Vector InitialStart, Rotator Dir, bool bWallHitter, int Weight)
{
	local int i;
	local Vector End;
	local Vector X;
	local Vector HitLocation;
	local Vector HitNormal;
	local Vector Start;
	local Vector WaterHitLocation;
	local Vector LastHitLocation;
	local float Dist;
	local Actor Other;
	local Actor LastOther;
	local Material HitMaterial;

	log("BALLISTIC MELEE: MeleeDoTrace() Weight="$Weight$" Start="$InitialStart$" Dir="$Dir);

	Dist = MaxRange();
	
	Start = InitialStart;
	X = Normal(Vector(Dir));
	End = Start + X * Dist;

	LastHitLocation = End;

	Weapon.bTraceWater = true;

	while (Dist > 0)
	{
		Other = Trace(
			HitLocation,
			HitNormal,
			End,
			Start,
			true,
			TraceExtent,
			HitMaterial
		);

		if (Other == none)
			break;

		Dist -= VSize(HitLocation - Start);

		if (Dist < 0)
			Dist = 0;

		LastHitLocation = HitLocation;

		//-------------------------------------------------------------------------
		// Ignore client-only actors when appropriate.
		//-------------------------------------------------------------------------

		if (Level.NetMode == NM_Client)
		{
			if (Other.Role != ROLE_Authority && !Other.bWorldGeometry)
				break;
		}

		//-------------------------------------------------------------------------
		// Water handling.
		//-------------------------------------------------------------------------

		if (bWallHitter &&
			(FluidSurfaceInfo(Other) != none ||
			(PhysicsVolume(Other) != none && PhysicsVolume(Other).bWaterVolume)))
		{
			if (VSize(HitLocation - Start) > 1.0)
				WaterHitLocation = HitLocation;

			Start = HitLocation;
			End = Start + X * Dist;

			Weapon.bTraceWater = false;
			continue;
		}

		//-------------------------------------------------------------------------
		// Actor hit.
		//-------------------------------------------------------------------------

		if (!Other.bWorldGeometry && Other != LastOther)
		{
			for (i = 0; i < SwipeHits.Length; i++)
			{
				if (SwipeHits[i].Victim == Other)
				{
					if (SwipeHits[i].Weight < Weight)
					{
						SwipeHits.Remove(i, 1);
						i--;
					}
					else
					{
						break;
					}
				}
			}

			if (i >= SwipeHits.Length)
			{
				SwipeHits.Length = SwipeHits.Length + 1;

				SwipeHits[SwipeHits.Length - 1].Victim = Other;
				SwipeHits[SwipeHits.Length - 1].Weight = Weight;
				SwipeHits[SwipeHits.Length - 1].HitLoc = HitLocation;
				SwipeHits[SwipeHits.Length - 1].HitDir = X;

				LastOther = Other;
			}

			if (Mover(Other) == none)
				break;
		}

		//-------------------------------------------------------------------------
		// World geometry / movers.
		//-------------------------------------------------------------------------

		if (Other.bWorldGeometry || Mover(Other) != none)
		{
			break;
		}

		//-------------------------------------------------------------------------
		// Still inside the same actor.
		//-------------------------------------------------------------------------

		if (Other == Instigator || Other == LastOther)
		{
			Start = HitLocation + X * Other.CollisionRadius * 2;
			End = Start + X * Dist;
			continue;
		}

		break;
	}

	Weapon.bTraceWater = false;
}

//=============================================================================
// MELEE HOLD ANIMATION
//=============================================================================

simulated function PlayMeleeHold()
{
	if (Weapon == none)
		return;

	bMeleeHolding = true;
	bMeleeStrikeAnimationPlayed = false;

	if (Weapon.Mesh != none && PreFireAnim != '' && Weapon.HasAnim(PreFireAnim))
	{
		Weapon.PlayAnim(PreFireAnim, 1.0, 0.0);
	}
}


//=============================================================================
// DAMAGE APPLICATION
//=============================================================================

function ApplyMeleeDamage(
	Actor Victim,
	Vector HitLocation,
	Vector TraceStart,
	Vector HitDir
)
{
	local KFPawn HitPawn;
	local KFWeaponAttachment WeapAttach;
	local float Damage;
	local float DamageFactor;
	local array<int> HitPoints;

	log("BALLISTIC MELEE: ApplyMeleeDamage() Victim="$Victim$" HitLocation="$HitLocation);

	if (Victim == none || Victim == Instigator)
	{
		log("BALLISTIC MELEE: Damage rejected - invalid victim or instigator");
		return;
	}

	DamageFactor = GetDamageFactor(
		Victim,
		TraceStart,
		HitLocation
	);

	Damage = MeleeDamageMax * DamageFactor;

	HitPawn = KFPawn(Victim);

	//-------------------------------------------------------------------------
	// Pawn damage.
	//-------------------------------------------------------------------------

	if (HitPawn != none)
	{
		if (HitPawn.bDeleteMe)
			return;

		HitPawn.ProcessLocationalDamage(
			Damage,
			Instigator,
			HitLocation,
			Momentum * HitDir,
			DamageType,
			HitPoints
		);
	}
	else
	{
		//-------------------------------------------------------------------------
		// Non-pawn damage.
		//-------------------------------------------------------------------------

		Victim.TakeDamage(
			Damage,
			Instigator,
			HitLocation,
			Momentum * HitDir,
			DamageType
		);
	}

	//-------------------------------------------------------------------------
	// KF hit effect.
	//-------------------------------------------------------------------------

	WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

	if (WeapAttach != none)
	{
		WeapAttach.UpdateHit(
			Victim,
			HitLocation,
			Normal(HitLocation - TraceStart)
		);
	}
}


//=============================================================================
// RELEASE / STRIKE
//=============================================================================

simulated event ModeDoFire()
{
	if (!AllowFire())
		return;

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	//-------------------------------------------------------------------------
	// Server performs the actual melee trace and damage.
	//-------------------------------------------------------------------------

	if (Weapon.Role == ROLE_Authority)
	{
		DoFireEffect();

		if (Instigator == none || Instigator.Controller == none)
			return;

		Instigator.DeactivateSpawnProtection();
	}

	//-------------------------------------------------------------------------
	// Play the strike animation.
	//-------------------------------------------------------------------------

	if (Instigator.IsLocallyControlled())
	{
		if (!bMeleeStrikeAnimationPlayed)
			PlayFiring();
	}
	else
	{
		ServerPlayFiring();
	}

	Weapon.IncrementFlashCount(ThisModeNum);

	NextFireTime += FireRate;
	NextFireTime = FMax(NextFireTime, Level.TimeSeconds);

	Load = AmmoPerFire;
	HoldTime = 0.0;

	//-------------------------------------------------------------------------
	// Return weapon to its normal length.
	//-------------------------------------------------------------------------

	if (BallisticWeapon(Weapon) != none)
	{
		BallisticWeapon(Weapon).SetDefaultGunLength();
	}

	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != none)
	{
		bIsFiring = false;
		Weapon.PutDown();
	}
}


//=============================================================================
// CHARGE / HOLD
//=============================================================================

simulated event ModeHoldFire()
{
	if (!AllowFire())
		return;

	if (HoldStartTime == 0.0)
		HoldStartTime = Level.TimeSeconds;

	if (BallisticWeapon(Weapon) != none)
	{
		BallisticWeapon(Weapon).SetMeleeGunLength();
	}
}


//=============================================================================
// STRIKE ANIMATION
//=============================================================================

function PlayFiring()
{
	log("BALLISTIC MELEE: PlayFiring() called");
	log("BALLISTIC MELEE: Weapon="$Weapon);
	log("BALLISTIC MELEE: bMeleeHolding="$bMeleeHolding);
	log("BALLISTIC MELEE: HoldTime="$HoldTime);
	log("BALLISTIC MELEE: MeleeState="$BallisticWeapon(Weapon).MeleeState);

	bMeleeHolding = false;
	bMeleeStrikeAnimationPlayed = true;

	if (Weapon.Mesh != none)
	{
		log("BALLISTIC MELEE: Weapon mesh valid");

		if (FireAnim != '' && Weapon.HasAnim(FireAnim))
		{
			log("BALLISTIC MELEE: Playing "$FireAnim);
			Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
		}
		else
		{
			log("BALLISTIC MELEE: ERROR - Melee fire animation not found: "$FireAnim);
		}
	}

	if (FireSound != none)
		Weapon.PlaySound(FireSound, SLOT_Interact, TransientSoundVolume);

	ClientPlayForceFeedback(FireForce);

	FireCount++;
}


//=============================================================================
// SERVER STRIKE ANIMATION
//=============================================================================

function ServerPlayFiring()
{
	if (Weapon.Mesh != none && FireAnim != '' && Weapon.HasAnim(FireAnim))
	{
		Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
	}
}


//=============================================================================
// BERSERKER
//=============================================================================

function StartBerserk()
{
	MeleeDamageMin = default.MeleeDamageMin * 1.33;
	MeleeDamageMax = default.MeleeDamageMax * 1.33;

	FireRate = default.FireRate * 0.75;
	FireAnimRate = default.FireAnimRate / 0.75;
}

function StopBerserk()
{
	MeleeDamageMin = default.MeleeDamageMin;
	MeleeDamageMax = default.MeleeDamageMax;

	FireRate = default.FireRate;
	FireAnimRate = default.FireAnimRate;
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	SwipePoints(0)=(Weight=3,Offset=(Yaw=2560))
	SwipePoints(1)=(Weight=5,Offset=(Yaw=1280))
	SwipePoints(2)=(Weight=6)
	SwipePoints(3)=(Weight=4,Offset=(Yaw=-1280))
	SwipePoints(4)=(Weight=2,Offset=(Yaw=-2560))

	FireSound=Sound'BWKF_M806_SN.M806.M806MeleeFire'
    StereoFireSoundRef="BWKF_M806_SN.M806.M806MeleeFire"

	WallHitPoint=2
	NumSwipePoints=5

	TraceExtent=(X=0.000000,Y=15.000000,Z=15.000000)

	MaxBonusHoldTime=1.500000

	bCanBackstab=True

	TraceRange=145.000000

	MeleeDamageMin=50.000000
	MeleeDamageMax=100.000000

	ChargeDamageBonusFactor=1.000000

	FlankDamageMult=1.150000
	BackDamageMult=1.300000

	TweenTime=0.100000
	FireRate=0.800000

	//HitDamageClass=Class'KFMod.DamTypeMelee'
	//HitEffectClass=class'KFMeleeHitEffect'
	
	bFireOnRelease=True
	bWaitForRelease=True
	bModeExclusive=True

	AmmoPerFire=0
}