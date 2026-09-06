//=============================================================================
// BallisticShotgunFire
//=============================================================================
class BallisticShotgunFire extends KFShotgunFire;

var bool bDualFireLeft;
var bool bLastDualFireLeft;

var Emitter FlashEmitterLeft;

var bool bBerserk;

//=============================================================================
// BURST
//=============================================================================

var int BurstCount;
var int MaxBurst;
var bool bBurstMode;
var bool bBurstComplete;
var float BurstFireRateFactor;


//=============================================================================
// BALLISTIC ACCURACY
//=============================================================================

var float LastFireTime;
var int NumShotsInBurst;
var() float MaxSpread;
var() bool bAccuracyBonusForSemiAuto;


//=============================================================================
// BERSERK
//=============================================================================

function StartBerserk()
{
	bBerserk = true;
}

function StopBerserk()
{
	bBerserk = false;
}

function StartSuperBerserk()
{
}

function PostSpawnProjectile(Projectile P)
{
	Super.PostSpawnProjectile(P);

	if (bBerserk && P != None)
		P.Damage *= 1.33;
}


//=============================================================================
// FIRE MODE
//=============================================================================

simulated function SwitchWeaponMode(byte NewMode)
{
	local BallisticWeapon BW;

	BurstCount = 0;
	bBurstComplete = false;

	BW = BallisticWeapon(Weapon);

	if (BW == None || NewMode >= BW.WeaponModes.Length)
		return;

	if (BW.WeaponModes[NewMode].ModeID ~= "WM_Burst" || BW.WeaponModes[NewMode].ModeID ~= "WM_BigBurst")
	{
		bBurstMode = true;
		MaxBurst = int(BW.WeaponModes[NewMode].Value);
		bWaitForRelease = false;
		bNowWaiting = false;
	}
	else if (BW.WeaponModes[NewMode].ModeID ~= "WM_FullAuto")
	{
		bBurstMode = false;
		MaxBurst = 0;
		bBurstComplete = false;
		bWaitForRelease = false;
		bNowWaiting = false;
	}
	else
	{
		bBurstMode = false;
		MaxBurst = 0;
		bBurstComplete = false;
		bWaitForRelease = true;
		bNowWaiting = false;
	}
}

simulated function ResetBurst()
{
	BurstCount = 0;
	bBurstComplete = false;
	bWaitForRelease = true;
	bNowWaiting = false;
}


//=============================================================================
// SPREAD
//=============================================================================

simulated function float GetSpread()
{
	local float NewSpread;
	local float AccuracyMod;

	AccuracyMod = 1.0;

	if (KFWeap == None)
		KFWeap = KFWeapon(Weapon);

	if (KFWeap != None && KFWeap.bAimingRifle)
		AccuracyMod *= 0.5;

	if (Instigator != None && Instigator.bIsCrouched)
		AccuracyMod *= 0.85;

	if (bAccuracyBonusForSemiAuto && bWaitForRelease)
		AccuracyMod *= 0.85;

	NumShotsInBurst += 1;

	if (Level.TimeSeconds - LastFireTime > 0.5)
	{
		NewSpread = Default.Spread;
		NumShotsInBurst = 0;
	}
	else
	{
		if (MaxSpread > 0)
			NewSpread = FMin(Default.Spread + (NumShotsInBurst * (MaxSpread / 6.0)), MaxSpread);
		else
			NewSpread = Default.Spread;
	}

	NewSpread *= AccuracyMod;

	return NewSpread;
}


//=============================================================================
// ALLOW FIRE
//=============================================================================

simulated function bool AllowFire()
{
	local BallisticWeapon BW;

	BW = BallisticWeapon(Weapon);

	if (BW != None && (BW.IsHoldingMelee() || BW.IsActionLocked()))
		return false;

	if (bBurstMode && bBurstComplete)
		return false;

	return Super.AllowFire();
}

function PlayFiring()
{
	local float RandPitch;
	local BallisticWeapon BW;
	local name DualFireAnim;

	BW = BallisticWeapon(Weapon);

	if (BW != None && BW.bDualWeapon)
	{
		bLastDualFireLeft = bDualFireLeft;
		DualFireAnim = BW.GetDualFireAnim(bDualFireLeft);
	}
	else
	{
		DualFireAnim = FireAnim;
	}

	if (Weapon.Mesh != None)
	{
		if (FireCount > 0)
		{
			if (KFWeap.bAimingRifle)
			{
				if (BW != None && BW.bDualWeapon)
				{
					Weapon.PlayAnim(BW.GetDualSightFireAnim(bLastDualFireLeft), FireAnimRate, TweenTime);
				}
				else if (Weapon.HasAnim(FireLoopAimedAnim))
				{
					Weapon.PlayAnim(FireLoopAimedAnim, FireLoopAnimRate, 0.0);
				}
				else if (Weapon.HasAnim(FireAimedAnim))
				{
					Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
				}
				else
				{
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
				}
			}
			else
			{
				if (BW != None && BW.bDualWeapon)
					Weapon.PlayAnim(DualFireAnim, FireAnimRate, TweenTime);
				else if (Weapon.HasAnim(FireLoopAnim))
					Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
				else
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
			}
		}
		else
		{
			if (KFWeap.bAimingRifle)
			{
				if (BW != None && BW.bDualWeapon)
				{
					Weapon.PlayAnim(BW.GetDualSightFireAnim(bLastDualFireLeft), FireAnimRate, TweenTime);
				}
				else if (Weapon.HasAnim(FireAimedAnim))
					Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
				else
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
			}
			else
			{
				if (BW != None && BW.bDualWeapon)
					Weapon.PlayAnim(DualFireAnim, FireAnimRate, TweenTime);
				else
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
			}
		}
	}

	if (Weapon.Instigator != None && Weapon.Instigator.IsLocallyControlled() && Weapon.Instigator.IsFirstPerson() && StereoFireSound != None)
	{
		if (bRandomPitchFireSound)
		{
			RandPitch = FRand() * RandomPitchAdjustAmt;

			if (FRand() < 0.5)
				RandPitch *= -1.0;
		}

		Weapon.PlayOwnedSound(StereoFireSound, SLOT_Interact, TransientSoundVolume * 0.85,, TransientSoundRadius, (1.0 + RandPitch), false);
	}
	else
	{
		if (bRandomPitchFireSound)
		{
			RandPitch = FRand() * RandomPitchAdjustAmt;

			if (FRand() < 0.5)
				RandPitch *= -1.0;
		}

		Weapon.PlayOwnedSound(FireSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius, (1.0 + RandPitch), false);
	}

	ClientPlayForceFeedback(FireForce);

	FireCount++;

	if (BW != None && BW.bDualWeapon)
		bDualFireLeft = !bDualFireLeft;
}


//=============================================================================
// FIRE
//=============================================================================

simulated event ModeDoFire()
{
	local float Rec;
	local float BurstRate;

	if (!AllowFire())
		return;

	if (bBurstMode && BurstCount == 0)
	{
		bWaitForRelease = false;
		bNowWaiting = false;
		bBurstComplete = false;
	}

	if (Instigator == None || Instigator.Controller == None)
		return;

	Spread = GetSpread();

	Rec = GetFireSpeed();

	FireRate = default.FireRate / Rec;
	FireAnimRate = default.FireAnimRate * Rec;

	LastFireTime = Level.TimeSeconds;

	Rec = 1;

	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != None && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != None)
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	if (Weapon.Owner != None && AllowFire() && !bFiringDoesntAffectMovement && Weapon.Owner.Physics != PHYS_Falling)
	{
		if (FireRate > 0.25)
		{
			Weapon.Owner.Velocity.X *= 0.1;
			Weapon.Owner.Velocity.Y *= 0.1;
		}
		else
		{
			Weapon.Owner.Velocity.X *= 0.5;
			Weapon.Owner.Velocity.Y *= 0.5;
		}
	}

	Super.ModeDoFire();

	if (Instigator.IsLocallyControlled())
		HandleRecoil(Rec);

	if (bBurstMode)
	{
		BurstCount++;

		if (BurstCount >= MaxBurst)
		{
			bBurstComplete = true;

			NextFireTime = Level.TimeSeconds + FireRate;

			bWaitForRelease = true;
			bNowWaiting = true;
		}
		else
		{
			BurstRate = FireRate * BurstFireRateFactor;
			NextFireTime = Level.TimeSeconds + BurstRate;
		}
	}

	Load = AmmoPerFire;
	HoldTime = 0;

	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
	{
		bIsFiring = false;
		Weapon.PutDown();
	}
}

simulated function InitEffects()
{
	local BallisticWeapon BW;

	Super.InitEffects();

	BW = BallisticWeapon(Weapon);

	if (BW == None || !BW.bDualWeapon)
		return;

	if (FlashEmitterLeft == None && FlashEmitterClass != None)
	{
		FlashEmitterLeft = Weapon.Spawn(FlashEmitterClass);
		Weapon.AttachToBone(FlashEmitterLeft, BW.FlashBoneLeft);
	}

	if (FlashEmitter != None)
		Weapon.AttachToBone(FlashEmitter, BW.FlashBoneRight);
}

function FlashMuzzleFlash()
{
	local BallisticWeapon BW;

	BW = BallisticWeapon(Weapon);

	if (BW == None)
	{
		Super.FlashMuzzleFlash();
		return;
	}

	if (!BW.bDualWeapon)
	{
		Super.FlashMuzzleFlash();
		return;
	}

	if (bLastDualFireLeft)
	{
		if (FlashEmitterLeft != None)
			FlashEmitterLeft.Trigger(Weapon, Instigator);
	}
	else
	{
		if (FlashEmitter != None)
			FlashEmitter.Trigger(Weapon, Instigator);
	}
}

simulated function DestroyEffects()
{
	Super.DestroyEffects();

	if (FlashEmitterLeft != None)
	{
		FlashEmitterLeft.Destroy();
		FlashEmitterLeft = None;
	}
}

simulated function ResetDualFire()
{
	bDualFireLeft = false;
	bLastDualFireLeft = false;
}

//=============================================================================
// STOP FIRING
//=============================================================================

simulated function StopFiring()
{
	Super.StopFiring();

	if (bBurstMode)
	{
		BurstCount = 0;
		bBurstComplete = false;
		bWaitForRelease = true;
		bNowWaiting = true;
		NextFireTime = Level.TimeSeconds + FireRate;
	}
	else
	{
		BurstCount = 0;
		bBurstComplete = false;
	}
}


//=============================================================================
// RESET ACCURACY
//=============================================================================

simulated function ResetAccuracy()
{
	NumShotsInBurst = 0;
	LastFireTime = 0;
}


//=============================================================================
// DEFAULTS
//=============================================================================

defaultproperties
{
	BurstFireRateFactor=0.75
	MaxSpread=0.12
}