class Weapon_BOGPistol_PrimaryFire extends BallisticShotgunFire;

var() class<Projectile> GrenadeProjectileClass;
var() class<Projectile> FlareProjectileClass;
var() class<Projectile> MedicalProjectileClass;

simulated function bool AllowFire()
{
	local BallisticWeapon BW;
	local Weapon_BOGPistol_Main BOGP;

	BW = BallisticWeapon(Weapon);
	BOGP = Weapon_BOGPistol_Main(Weapon);

	if (BW != None && BW.IsHoldingMelee())
		return false;

	if (BW != None && BW.IsActionLocked())
		return false;

	if (BOGP != None && BOGP.bIsReloading)
		return false;

	if (BOGP != None && BOGP.bChangingFireMode)
		return false;

	if (BOGP != None &&
		(BOGP.MeleeState == MS_Held ||
		 BOGP.MeleeState == MS_Pending ||
		 BOGP.MeleeState == MS_Strike ||
		 BOGP.MeleeState == MS_StrikePending))
		return false;

	if (BW != None && BW.MagAmmoRemaining < AmmoPerFire)
		return false;

	if (Weapon.AmmoAmount(ThisModeNum) < AmmoPerFire)
		return false;

	return true;
}

function PlayFiring()
{
	local Weapon_BOGPistol_Main BOGP;

	BOGP = Weapon_BOGPistol_Main(Weapon);

	if (BOGP != None)
		BOGP.bFireAnimPlaying = true;

	Super.PlayFiring();
}

function float MaxRange()
{
    return 2500;
}

function DoFireEffect()
{
	local Weapon_BOGPistol_Main BOGP;

	BOGP = Weapon_BOGPistol_Main(Weapon);

	if (BOGP != None)
	{
		switch (BOGP.CurrentWeaponMode)
		{
		case 0:
			ProjectileClass = GrenadeProjectileClass;
			break;

		case 1:
			ProjectileClass = FlareProjectileClass;
			break;

		case 2:
			ProjectileClass = MedicalProjectileClass;
			break;

		default:
			ProjectileClass = GrenadeProjectileClass;
			break;
		}
	}

	Super(KFShotgunFire).DoFireEffect();
}

defaultproperties
{
     GrenadeProjectileClass=Class'BW_WD001_KF.Weapon_BOGPistol_GrenadeProj'
	 FlareProjectileClass=Class'BW_WD001_KF.Weapon_BOGPistol_FlameProj'
	 MedicalProjectileClass=Class'BW_WD001_KF.Weapon_BOGPistol_MedicProj'
	 
	 KickMomentum=(X=0,y=0,Z=0)
     ProjPerFire=1
     TransientSoundVolume=1.8
     FireSoundRef="BWKF_BOGP_SN.BOGP.BOGP_Fire"
     StereoFireSoundRef="BWKF_BOGP_SN.BOGP.BOGP_Fire"
     NoAmmoSoundRef="KF_M79Snd.M79_DryFire"
     FireForce="AssaultRifleFire"
     FireRate=0.1
     AmmoClass=Class'BW_WD001_KF.Weapon_BOGPistol_GrenadeAmmo'
     ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ProjectileClass=Class'BW_WD001_KF.Weapon_BOGPistol_GrenadeProj'
     BotRefireRate=1.800000
     aimerror=42.000000
     Spread=0.015//0.0085
     SpreadStyle=SS_Random
     ProjSpawnOffset=(X=50,Y=10,Z=-6)
     FlashEmitterClass=Class'BW_WD001_KF.Weapon_BOGPistol_FlashEmitter'

     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=50
     bWaitForRelease=false
}
