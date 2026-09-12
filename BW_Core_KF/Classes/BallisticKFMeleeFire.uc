//=============================================================================
// BallisticKFMeleeFire
//
// KF1-specific melee implementation built on BallisticMeleeFire.
//=============================================================================
class BallisticKFMeleeFire extends BallisticMeleeFire;


//=============================================================================
// IMPACT SHAKE
//=============================================================================

var() Vector ImpactShakeRotMag;
var() Vector ImpactShakeRotRate;
var() float ImpactShakeRotTime;
var() Vector ImpactShakeOffsetMag;
var() Vector ImpactShakeOffsetRate;
var() float ImpactShakeOffsetTime;


//=============================================================================
// WIDE DAMAGE
//=============================================================================

var() float WideDamageMinHitAngle;
var array<Actor> MeleeStrikeVictims;


//=============================================================================
// IMPACT SHAKE
//=============================================================================

function ImpactShakeView()
{
	local PlayerController PC;

	PC = PlayerController(Instigator.Controller);

	if (PC != None)
	{
		PC.WeaponShakeView(
			ImpactShakeRotMag,
			ImpactShakeRotRate,
			ImpactShakeRotTime,
			ImpactShakeOffsetMag,
			ImpactShakeOffsetRate,
			ImpactShakeOffsetTime
		);
	}
}


//=============================================================================
// DAMAGE APPLICATION
//=============================================================================

function ApplyMeleeDamage(Actor Victim, Vector HitLocation, Vector TraceStart, Vector HitDir)
{
	local KFPawn HitPawn;
	local KFMonster HitMonster;
	local KFWeaponAttachment WeapAttach;
	local float Damage;
	local float DamageFactor;
	local array<int> HitPoints;
	local bool bBackStabbed;

	if (Victim == None || Victim == Instigator)
		return;
		
	if (Weapon.Role == ROLE_Authority)
	{
		if (MeleeStrikeVictims.Length == 0 || MeleeStrikeVictims[MeleeStrikeVictims.Length - 1] != Victim)
		{
			MeleeStrikeVictims.Length = MeleeStrikeVictims.Length + 1;
			MeleeStrikeVictims[MeleeStrikeVictims.Length - 1] = Victim;
		}
	}	

	//-------------------------------------------------------------------------
	// Damage factor
	//-------------------------------------------------------------------------

	DamageFactor = GetDamageFactor(
		Victim,
		TraceStart,
		HitLocation
	);

	Damage = MeleeDamageMax * DamageFactor;

	//-------------------------------------------------------------------------
	// Resolve KF pawn / monster
	//-------------------------------------------------------------------------

	HitPawn = KFPawn(Victim);
	HitMonster = KFMonster(Victim);

	if (HitPawn != None)
	{
		if (HitPawn.bDeleteMe)
			return;

		// Determine whether this was a rear attack using the same
		// directional calculation as GetDamageFactor().
		if (bCanBackstab)
		{
			if (Vector(Victim.Rotation) Dot Normal(HitLocation - TraceStart) > 0.6)
				bBackStabbed = true;
		}

		if (HitMonster != None)
			HitMonster.bBackstabbed = bBackStabbed;

		HitPawn.ProcessLocationalDamage(
			Damage,
			Instigator,
			HitLocation,
			Momentum * HitDir,
			DamageType,
			HitPoints
		);

		//-------------------------------------------------------------------------
		// Monster-specific melee behaviour
		//-------------------------------------------------------------------------

		if (HitMonster != None)
		{
			if (VSize(Instigator.Velocity) > 300 &&
				HitMonster.Mass <= Instigator.Mass)
			{
				HitMonster.FlipOver();
			}
		}

		ImpactShakeView();
	}
	else
	{
		Victim.TakeDamage(
			Damage,
			Instigator,
			HitLocation,
			Momentum * HitDir,
			DamageType
		);
	}

	//-------------------------------------------------------------------------
	// Blood / hit attachment
	//-------------------------------------------------------------------------

	if ((HitMonster != None || HitPawn != None) &&
		KFMeleeGun(Weapon) != None &&
		KFMeleeGun(Weapon).BloodyMaterial != None)
	{
		Weapon.Skins[KFMeleeGun(Weapon).BloodSkinSwitchArray] =
			KFMeleeGun(Weapon).BloodyMaterial;

		Weapon.Texture = Weapon.Default.Texture;
	}

	WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

	if (WeapAttach != None)
	{
		WeapAttach.UpdateHit(
			Victim,
			HitLocation,
			Normal(HitLocation - TraceStart)
		);
	}
}


//=============================================================================
// POST STRIKE
//=============================================================================

function PostMeleeStrike()
{
	DoWideDamage();
	ApplyChopSlow();
	MeleeStrikeVictims.Length = 0;
}


//=============================================================================
// WIDE DAMAGE
//=============================================================================

function DoWideDamage()
{
	local Pawn Victim;
	local Vector StartTrace;
	local Vector LookDir;
	local Vector Dir;
	local float DiffAngle;
	local float VictimDist;
	local float Damage;

	if (Weapon.Role != ROLE_Authority)
		return;

	if (KFWeapon(Weapon) != none && KFWeapon(Weapon).bNoHit)
		return;

	if (WideDamageMinHitAngle <= 0.0)
		return;

	if (Instigator == None)
		return;

	StartTrace = Instigator.Location;
	LookDir = Normal(Vector(Instigator.GetViewRotation()));

	foreach Weapon.VisibleCollidingActors(class'Pawn', Victim, MaxRange() * 2.0, StartTrace)
	{
		if (Victim == None || Victim == Instigator)
			continue;

		if (Victim.Health <= 0)
			continue;

		// Don't hit actors already struck by the normal swipe traces.
		if (IsMeleeStrikeVictim(Victim))
			continue;

		VictimDist = VSizeSquared(Instigator.Location - Victim.Location);

		if (VictimDist > ((MaxRange() * 1.1) * (MaxRange() * 1.1)) + (Victim.CollisionRadius * Victim.CollisionRadius))
			continue;

		Dir = Normal(Victim.Location - Instigator.Location);

		DiffAngle = LookDir Dot Dir;

		if (DiffAngle > WideDamageMinHitAngle)
		{
			Damage = MeleeDamageMax * DiffAngle;

			Victim.TakeDamage(
				Damage,
				Instigator,
				Victim.Location + Victim.CollisionHeight * vect(0,0,0.7),
				LookDir * Momentum,
				DamageType
			);

			if (MeleeHitSounds.Length > 0)
			{
				Victim.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.Length)],SLOT_None,MeleeHitVolume,,,,false);
			}
		}
	}
}

function bool IsMeleeStrikeVictim(Actor Victim)
{
	local int i;

	for (i = 0; i < MeleeStrikeVictims.Length; i++)
	{
		if (MeleeStrikeVictims[i] == Victim)
			return true;
	}

	return false;
}


//=============================================================================
// MELEE MOVEMENT SLOW
//=============================================================================

function ApplyChopSlow()
{
	if (Weapon.Owner != None && Weapon.Owner.Physics != PHYS_Falling)
	{
		if (KFMeleeGun(Weapon) != None)
		{
			Weapon.Owner.Velocity.X *= KFMeleeGun(Weapon).ChopSlowRate;
			Weapon.Owner.Velocity.Y *= KFMeleeGun(Weapon).ChopSlowRate;
		}
	}
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	ImpactShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
	ImpactShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
	ImpactShakeRotTime=2.000000
	ImpactShakeOffsetMag=(X=10.000000,Y=10.000000,Z=10.000000)
	ImpactShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
	ImpactShakeOffsetTime=2.000000
	WideDamageMinHitAngle=0.000000
	
	FireSound=None
    StereoFireSoundRef="None"
	FlashEmitterClass=None
	
}