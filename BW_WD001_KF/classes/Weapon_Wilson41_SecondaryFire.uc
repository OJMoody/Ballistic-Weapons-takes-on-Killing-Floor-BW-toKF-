class Weapon_Wilson41_SecondaryFire extends BallisticShotgunFire;


//=============================================================================
// FIRE
//=============================================================================

simulated event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

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

	FireAnim = 'FireAlt';
	Load = AmmoPerFire;

	if (Weapon.Role == ROLE_Authority)
	{
		DoFireEffect();
		BallisticWeapon(Weapon).AltAmmoLoaded = 0;

		HoldTime = 0;

		if (Instigator == None || Instigator.Controller == None)
			return;

		if (AIController(Instigator.Controller) != None)
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

		Instigator.DeactivateSpawnProtection();
	}

	if (Instigator.IsLocallyControlled())
	{
		HandleRecoil(Rec);
		ShakeView();
		PlayFiring();
		FlashMuzzleFlash();
		StartMuzzleSmoke();
	}
	else
	{
		ServerPlayFiring();
	}

	Weapon.IncrementFlashCount(ThisModeNum);

	NextFireTime += FireRate;
	NextFireTime = FMax(NextFireTime, Level.TimeSeconds);

	Load = AmmoPerFire;
	HoldTime = 0;

	if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
	{
		bIsFiring = false;
		Weapon.PutDown();
	}
}


//=============================================================================
// ALLOW FIRE
//=============================================================================

simulated function bool AllowFire()
{
	local BallisticWeapon BW;

	if (Instigator == None)
		return false;

	if (Instigator.IsProneTransitioning())
		return false;

	BW = BallisticWeapon(Weapon);

	if (BW == None)
		return false;

	if (BW.IsHoldingMelee() || BW.IsActionLocked())
		return false;

	if (BW.AltAmmoLoaded <= 0)
	{
		if (BW.AllowAltReload())
			BW.ReloadAlt();

		return false;
	}

	if (bBurstMode && bBurstComplete)
		return false;

	return true;
}


defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_Wilson41_SecondaryAmmo'
    ProjectileClass=Class'BW_Core_KF.BallisticShotgunProj'
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_Wilson41_FlashEmitterAlt'

    KickMomentum=(X=-45.000000,Z=10.000000)
    ProjPerFire=5
    AmmoPerFire=1
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSoundRef="BWKF_Wilson_SN.Wilson.LM-SecFire"
    StereoFireSoundRef="BWKF_Wilson_SN.Wilson.LM-SecFire"
    NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
    FireRate=0.65
    FireAnim='FireAlt'
    FireAnimRate=1.0
	bAltFire=True
    BotRefireRate=0.200000
    aimerror=1.000000
    Spread=1125.0
    maxVerticalRecoilAngle=1500
    maxHorizontalRecoilAngle=900
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=3.0
    ShakeRotMag=(X=50.0,Y=50.0,Z=400.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=5.0
    bWaitForRelease=True
    bRandomPitchFireSound=True
}