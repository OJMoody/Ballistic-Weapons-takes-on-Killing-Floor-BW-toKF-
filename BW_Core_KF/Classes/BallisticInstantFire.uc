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

var() class<Actor> HitEffectClass;

var() bool bAltFire;

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

simulated function ResetBurst()
{
	BurstCount = 0;
	bBurstComplete = false;
	bWaitForRelease = true;
	bNowWaiting = false;
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

	Log("=== BIF TRACE: PlayFiring START ===");
	Log("BIF TRACE: FireCount=" $ FireCount $
		" bAimingRifle=" $ KFWeap.bAimingRifle $
		" bDualWeapon=" $ (BW != None && BW.bDualWeapon) $
		" bDualFireLeft=" $ bDualFireLeft $
		" bLastDualFireLeft=" $ bLastDualFireLeft);

	if (BW != None && BW.bDualWeapon)
	{
		bLastDualFireLeft = bDualFireLeft;
		DualFireAnim = BW.GetDualFireAnim(bDualFireLeft);

		Log("BIF TRACE: Dual weapon");
		Log("BIF TRACE: bLastDualFireLeft=" $ bLastDualFireLeft);
		Log("BIF TRACE: DualFireAnim=" $ DualFireAnim);
		Log("BIF TRACE: DualSightFireAnim=" $ BW.GetDualSightFireAnim(bLastDualFireLeft));
	}
	else
	{
		DualFireAnim = FireAnim;

		Log("BIF TRACE: Standard weapon");
		Log("BIF TRACE: FireAnim=" $ FireAnim);
	}

	Log("BIF TRACE: FireLoopAnim=" $ FireLoopAnim $
		" HasAnim=" $ Weapon.HasAnim(FireLoopAnim));

	Log("BIF TRACE: FireLoopAimedAnim=" $ FireLoopAimedAnim $
		" HasAnim=" $ Weapon.HasAnim(FireLoopAimedAnim));

	Log("BIF TRACE: FireAimedAnim=" $ FireAimedAnim $
		" HasAnim=" $ Weapon.HasAnim(FireAimedAnim));

	Log("BIF TRACE: FireAnimRate=" $ FireAnimRate $
		" FireLoopAnimRate=" $ FireLoopAnimRate $
		" TweenTime=" $ TweenTime);

	if (Weapon.Mesh != None && (BW == None || (!BW.bIsReloading && !BW.bBallisticReload)))
	{
		if (FireCount > 0)
		{
			Log("BIF TRACE: FIRECOUNT > 0");

			if (KFWeap.bAimingRifle)
			{
				Log("BIF TRACE: Aimed fire path");

				if (BW != None && BW.bDualWeapon)
				{
					Log("BIF TRACE: PLAY DualSightFireAnim=" $ BW.GetDualSightFireAnim(bLastDualFireLeft));
					Weapon.PlayAnim(BW.GetDualSightFireAnim(bLastDualFireLeft), FireAnimRate, TweenTime);
				}
				else if (Weapon.HasAnim(FireLoopAimedAnim))
				{
					Log("BIF TRACE: PLAY FireLoopAimedAnim=" $ FireLoopAimedAnim $
						" Rate=" $ FireLoopAnimRate $
						" Tween=" $ 0.0);
					Weapon.PlayAnim(FireLoopAimedAnim, FireLoopAnimRate, 0.0);
				}
				else if (Weapon.HasAnim(FireAimedAnim))
				{
					Log("BIF TRACE: PLAY FireAimedAnim=" $ FireAimedAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
				}
				else
				{
					Log("BIF TRACE: PLAY FALLBACK FireAnim=" $ FireAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
				}
			}
			else
			{
				Log("BIF TRACE: Hip fire path");

				if (BW != None && BW.bDualWeapon)
				{
					Log("BIF TRACE: PLAY DualFireAnim=" $ DualFireAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(DualFireAnim, FireAnimRate, TweenTime);
				}
				else if (Weapon.HasAnim(FireLoopAnim))
				{
					Log("BIF TRACE: PLAY FireLoopAnim=" $ FireLoopAnim $
						" Rate=" $ FireLoopAnimRate $
						" Tween=" $ 0.0);
					Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
				}
				else
				{
					Log("BIF TRACE: PLAY FireAnim=" $ FireAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
				}
			}
		}
		else
		{
			Log("BIF TRACE: FIRST SHOT / FireCount == 0");

			if (KFWeap.bAimingRifle)
			{
				Log("BIF TRACE: First-shot aimed fire path");

				if (BW != None && BW.bDualWeapon)
				{
					Log("BIF TRACE: PLAY DualSightFireAnim=" $ BW.GetDualSightFireAnim(bLastDualFireLeft));
					Weapon.PlayAnim(BW.GetDualSightFireAnim(bLastDualFireLeft), FireAnimRate, TweenTime);
				}
				else if (Weapon.HasAnim(FireAimedAnim))
				{
					Log("BIF TRACE: PLAY FireAimedAnim=" $ FireAimedAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
				}
				else
				{
					Log("BIF TRACE: PLAY FALLBACK FireAnim=" $ FireAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
				}
			}
			else
			{
				Log("BIF TRACE: First-shot hip fire path");

				if (BW != None && BW.bDualWeapon)
				{
					Log("BIF TRACE: PLAY DualFireAnim=" $ DualFireAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(DualFireAnim, FireAnimRate, TweenTime);
				}
				else
				{
					Log("BIF TRACE: PLAY FireAnim=" $ FireAnim $
						" Rate=" $ FireAnimRate $
						" Tween=" $ TweenTime);
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
				}
			}
		}
	}
	else
	{
		Log("BIF TRACE: Weapon.Mesh == None - NO ANIMATION PLAYED");
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

	Log("BIF TRACE: FireCount AFTER increment=" $ FireCount);

	if (BW != None && BW.bDualWeapon)
	{
		bDualFireLeft = !bDualFireLeft;
		Log("BIF TRACE: bDualFireLeft AFTER toggle=" $ bDualFireLeft);
	}

	Log("=== BIF TRACE: PlayFiring END ===");
}


//=============================================================================
// FIRE
//=============================================================================

//=============================================================================
// TRACE
//=============================================================================

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local KFWeaponAttachment WeapAttach;
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
		WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

		if (!Other.bWorldGeometry)
		{
			if (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') && !Other.IsA('ExtendedZCollision'))
			{
				if (WeapAttach != None)
				{
					if (BallisticAttachment(WeapAttach) != None)
						BallisticAttachment(WeapAttach).BallisticHitEffectClass = HitEffectClass;

					WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
				}
			}

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

			if (WeapAttach != None)
			{
				if (BallisticAttachment(WeapAttach) != None)
					BallisticAttachment(WeapAttach).BallisticHitEffectClass = HitEffectClass;

				WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
			}
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
}

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

	if (BallisticMeleeFire(self) == None)
	{
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
	}

	if (BallisticMeleeFire(self) != None)
	{
		bFiringDoesntAffectMovement = true;
		Super.ModeDoFire();
		bFiringDoesntAffectMovement = default.bFiringDoesntAffectMovement;
	}
	else
	{
		Super.ModeDoFire();
	}

	if (Instigator.IsLocallyControlled())
	{
		if (bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client)
			DoClientOnlyFireEffect();
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

simulated function InitEffects()
{
	local BallisticWeapon BW;
	local name FlashBoneRight;
	local name FlashBoneLeft;

	Super.InitEffects();

	BW = BallisticWeapon(Weapon);

	if (BW == None)
		return;

	FlashBoneRight = BW.FlashBoneRight;
	FlashBoneLeft = BW.FlashBoneLeft;

	if (bAltFire)
	{
		FlashBoneRight = BW.AltFlashBoneRight;
		FlashBoneLeft = BW.AltFlashBoneLeft;
	}

	if (BW.bDualWeapon)
	{
		if (FlashEmitterLeft == None && FlashEmitterClass != None)
		{
			FlashEmitterLeft = Weapon.Spawn(FlashEmitterClass);
			Weapon.AttachToBone(FlashEmitterLeft, FlashBoneLeft);
		}

		if (FlashEmitter != None)
			Weapon.AttachToBone(FlashEmitter, FlashBoneRight);
	}
	else if (FlashEmitter != None)
	{
		Weapon.AttachToBone(FlashEmitter, FlashBoneRight);
	}
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
	HitEffectClass=class'BW_Core_KF.BallisticWeaponHitEffects'
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