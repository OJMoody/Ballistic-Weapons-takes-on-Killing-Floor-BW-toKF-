class Weapon_XK2SMG_PrimaryFire extends BallisticInstantFire;

var() Sound IceFireSound;

function PlayFiring()
{
    Super.PlayFiring();

    if (Weapon_XK2SMG_Main(Weapon) != None
        && Weapon_XK2SMG_Main(Weapon).bAmpAttached
		&& !Weapon_XK2SMG_Main(Weapon).bAMPDepleted)
    {
        Weapon.Instigator.PlaySound(IceFireSound, SLOT_None, 1.0, false, 24.0);
    }
}

function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator R, Aim;
    local Weapon_XK2SMG_PrimaryIceProjectile IceProjectile;

    // Normal instant bullets when the AMP is detached.
    if (Weapon_XK2SMG_Main(Weapon) == None
		|| !Weapon_XK2SMG_Main(Weapon).bAmpAttached
		|| Weapon_XK2SMG_Main(Weapon).bAMPDepleted)
    {
        Super.DoFireEffect();
        return;
    }

    // Projectile firing when the AMP is attached.
    Instigator.MakeNoise(1.0);

    if (BallisticWeapon(Weapon).bBWThirdPersonCamera)
		StartTrace = Weapon.ThirdPersonActor.GetBoneCoords('TP_tip').Origin;
	else
		StartTrace = Instigator.Location + Instigator.EyePosition();

    Aim = AdjustAim(StartTrace, AimError);
    R = Rotator(Vector(Aim) + VRand() * FRand() * Spread);

    IceProjectile = Spawn(
		class'Weapon_XK2SMG_PrimaryIceProjectile',
		,
		,
		StartTrace,
		R
	);

    if (IceProjectile != None)
    {
        IceProjectile.Instigator = Instigator;

        Weapon_XK2SMG_Main(Weapon).StartAMPDrain();
    }
}

defaultproperties
{
    DamageType=Class'KFMod.DamTypeM7A3M'
    DamageMin=25
    DamageMax=35
    Momentum=10000.000000
    bPawnRapidFireAnim=True
    bAttachSmokeEmitter=True
    TransientSoundVolume=1.8
	IceFireSound=Sound'BWKF_XK2_SN.XK2.XK2-IceFire'
    FireSound=Sound'BWKF_XK2_SN.XK2.XK2-Fire'
    StereoFireSoundRef="BWKF_XK2_SN.XK2.XK2-Fire"
    NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
    FireForce="AssaultRifleFire"
    FireRate=0.08
    RecoilRate=0.02
    maxVerticalRecoilAngle=300
    maxHorizontalRecoilAngle=50
    TweenTime=0.025
    AmmoClass=Class'BW_WD001_KF.Weapon_XK2SMG_Ammo'
    AmmoPerFire=1
    BotRefireRate=0.350000
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_XK2SMG_FlashEmitter'
    aimerror=30.000000
    Spread=0.015000
    SpreadStyle=SS_Random
    bWaitForRelease=false
    ShakeOffsetMag=(X=6.0,Y=3.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=2.0
    ShakeRotMag=(X=75.0,Y=75.0,Z=250.0)
    ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
    ShakeRotTime=3.0
    bRandomPitchFireSound=false
	
	BrassClass=Class'BW_WD001_KF.Weapon_XK2SMG_Brass'
}