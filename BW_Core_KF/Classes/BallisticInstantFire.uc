//=============================================================================
// BallisticInstantFire
//=============================================================================
class BallisticInstantFire extends KFFire;

var bool bDualFireLeft;
var bool bLastDualFireLeft;

var Emitter FlashEmitterLeft;

var int BurstCount;
var int MaxBurst;
var bool bBurstMode;
var bool bBurstComplete;
var float BurstFireRateFactor;

//=============================================================================
// BERSERK
//=============================================================================

function StartBerserk()
{
	DamageMin = default.DamageMin * 1.33;
	DamageMax = default.DamageMax * 1.33;
}

function StopBerserk()
{
	DamageMin = default.DamageMin;
	DamageMax = default.DamageMax;
}

function StartSuperBerserk()
{
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

	ShakeView();

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
	ReloadAnimRate = default.ReloadAnimRate * Rec;

	Rec = 1;

	if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != None && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != None)
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	LastFireTime = Level.TimeSeconds;

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
	{
		if (bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client)
			DoClientOnlyFireEffect();

		HandleRecoil(Rec);
	}

	if (bBurstMode)
	{
		BurstCount++;

		if (BurstCount >= MaxBurst)
		{
			bBurstComplete = true;

			// The third shot uses the normal FireRate before the
			// firing system gets a chance to continue.
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

simulated function StopFiring()
{
	Super.StopFiring();

	if (bBurstMode)
	{
		if (BurstCount < MaxBurst)
		{
			bWaitForRelease = true;
			bNowWaiting = true;
		}
		else
		{
			BurstCount = 0;
			bBurstComplete = false;
			bWaitForRelease = true;
			bNowWaiting = true;
		}
	}
	else
	{
		BurstCount = 0;
		bBurstComplete = false;
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

	if (BW == None || !BW.bDualWeapon)
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

	if (ShellEjectEmitter != None)
		ShellEjectEmitter.Trigger(Weapon, Instigator);
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
// DEFAULTS
//=============================================================================

defaultproperties
{
	DamageType=Class'KFMod.DamTypeDualies'
	DamageMin=25
	DamageMax=35
	Momentum=10000.000000
	bPawnRapidFireAnim=True
	bAttachSmokeEmitter=True
	TransientSoundVolume=1.8
	FireSound=Sound'KF_9MMSnd.9mm_Fire'
	StereoFireSoundRef="KF_9MMSnd.9mm_FireST"
	NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
	FireForce="AssaultRifleFire"
	FireRate=0.175
	BurstFireRateFactor=0.75
	RecoilRate=0.07
	maxVerticalRecoilAngle=300
	maxHorizontalRecoilAngle=50
	FireAnimRate=1.0
	TweenTime=0.025
	AmmoClass=Class'KFMod.SingleAmmo'
	AmmoPerFire=1
	BotRefireRate=0.350000
	FlashEmitterClass=Class'ROEffects.MuzzleFlash1stMP'
	aimerror=30.000000
	Spread=0.015000
	SpreadStyle=SS_Random
	bWaitForRelease=true
	ShakeOffsetMag=(X=6.0,Y=3.0,Z=10.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.0
	ShakeRotMag=(X=75.0,Y=75.0,Z=250.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=3.0
	ShellEjectClass=class'ROEffects.KFShellEject9mm'
	ShellEjectBoneName=ejector
	bRandomPitchFireSound=false
	FireAimedAnim=SightFire
}