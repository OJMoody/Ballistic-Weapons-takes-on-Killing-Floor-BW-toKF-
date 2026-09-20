class Weapon_MRT6Shotgun_PrimaryFire extends BallisticShotgunFire;

simulated function InitEffects()
{
    Super.InitEffects();

    if (FlashEmitterLeft == None && FlashEmitterClass != None)
        FlashEmitterLeft = Weapon.Spawn(FlashEmitterClass);

    if (FlashEmitterLeft != None)
    {
        Weapon.AttachToBone(FlashEmitterLeft, 'TipL');
        FlashEmitterLeft.SetRelativeRotation(Rot(0, 32768, 0));
    }

    if (FlashEmitter != None)
    {
        Weapon.AttachToBone(FlashEmitter, 'TipR');
        FlashEmitter.SetRelativeRotation(Rot(0, 32768, 0));
    }
}

function FlashMuzzleFlash()
{
    if (FlashEmitterLeft != None)
        FlashEmitterLeft.Trigger(Weapon, Instigator);

    if (FlashEmitter != None)
        FlashEmitter.Trigger(Weapon, Instigator);
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

simulated event ModeDoFire()
{
    local BallisticWeapon BW;
    local Weapon_MRT6Shotgun_Main MRT6;
    local Sound OldFireSound;
    local Sound OldStereoFireSound;
    local int OldProjPerFire;

    BW = BallisticWeapon(Weapon);
    MRT6 = Weapon_MRT6Shotgun_Main(BW);

    if (BW == None || MRT6 == None)
        return;

    // Primary normally fires both barrels.
    MRT6.ThirdPersonFireBarrel = 0;

    if (MRT6.bOneBarrelFired || BW.MagAmmoRemaining == 1)
    {
        OldProjPerFire = ProjPerFire;
        ProjPerFire = MRT6.GetSecondaryProjPerFire();

        if (MRT6.bOneBarrelFired)
        {
            // Follow-up shot fires the right barrel.
            FireAnim = MRT6.GetSecondaryFireAnim();

            if (BW.MagAmmoRemaining <= 2)
                FireAnim = 'FireRightNoCock';

            MRT6.ThirdPersonFireBarrel = 2;

            OldFireSound = FireSound;
            OldStereoFireSound = StereoFireSound;

            FireSound = MRT6.GetSecondaryFireSound();
            StereoFireSound = MRT6.GetSecondaryStereoFireSound();

            Super.ModeDoFire();

            FireSound = OldFireSound;
            StereoFireSound = OldStereoFireSound;

            MRT6.bOneBarrelFired = false;
            MRT6.ResetSecondaryFireAnim();
            FireAnim = 'Fire';
        }
        else
        {
            // Only one shell remains, so fire the left barrel.
            FireAnim = 'FireLeft';

            if (BW.MagAmmoRemaining <= 1)
                FireAnim = 'FireNoCock';

            MRT6.ThirdPersonFireBarrel = 1;

            OldFireSound = FireSound;
            OldStereoFireSound = StereoFireSound;

            FireSound = MRT6.GetSecondaryFireSound();
            StereoFireSound = MRT6.GetSecondaryStereoFireSound();

            Super.ModeDoFire();

            FireSound = OldFireSound;
            StereoFireSound = OldStereoFireSound;

            FireAnim = 'Fire';
        }

        ProjPerFire = OldProjPerFire;
        return;
    }

    // Normal primary fire: both barrels.
    FireAnim = 'Fire';

    if (BW.MagAmmoRemaining <= 2)
        FireAnim = 'FireNoCock';

    MRT6.ThirdPersonFireBarrel = 0;

    Super.ModeDoFire();

    FireAnim = 'Fire';
}

simulated function bool AllowFire()
{
    local BallisticWeapon BW;
    local name AnimName;
    local float AnimFrame;
    local float AnimRate;

    BW = BallisticWeapon(Weapon);

    if (BW == None)
        return false;

    if (BW.IsHoldingMelee() || BW.IsActionLocked())
        return false;

    if (bBurstMode && bBurstComplete)
        return false;

    if (Weapon_MRT6Shotgun_Main(BW).bOneBarrelFired || BW.MagAmmoRemaining == 1)
    {
        if (BW.MagAmmoRemaining < Weapon_MRT6Shotgun_Main(BW).GetSecondaryAmmoPerFire())
            return false;
    }
    else
    {
        if (BW.MagAmmoRemaining < AmmoPerFire)
            return false;
    }

    if (Weapon != None)
    {
        Weapon.GetAnimParams(0, AnimName, AnimFrame, AnimRate);

        if (AnimName == 'Fire')
            return false;
    }

    return Super(WeaponFire).AllowFire();
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X, Y, Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X*ProjSpawnOffset.X;

    if (!Weapon.WeaponCentered() && !KFWeap.bAimingRifle)
        StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if (Other != None)
        StartProj = HitLocation;

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire);

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;

    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;

    default:
        SpawnProjectile(StartProj, Aim);
    }

    if (Instigator != None)
    {
        if (Instigator.Physics != PHYS_Falling)
        {
            Instigator.AddVelocity(KickMomentum >> Instigator.GetViewRotation());
        }
        else if (Instigator.Physics == PHYS_Falling && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
        {
            Instigator.AddVelocity((KickMomentum * LowGravKickMomentumScale) >> Instigator.GetViewRotation());
        }
    }
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Ammo'
    ProjectileClass=Class'BW_Core_KF.BallisticShotgunProj'
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_FlashEmitter'
	
    KickMomentum=(X=-45.000000,Z=10.000000)
    ProjPerFire=10
    AmmoPerFire=2
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSoundRef="BWKF_MRT6_SN.MRT6.MRT6Fire"
    StereoFireSoundRef="BWKF_MRT6_SN.MRT6.MRT6Fire"
    NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
    FireRate=0.2
    FireAnimRate=1.0
    BotRefireRate=0.200000
    aimerror=1.000000
    Spread=1125.0
    maxVerticalRecoilAngle=1500
    maxHorizontalRecoilAngle=900

    //** View shake **//
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=3.0
    ShakeRotMag=(X=50.0,Y=50.0,Z=400.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=5.0
    bWaitForRelease=false
    bRandomPitchFireSound=false
}