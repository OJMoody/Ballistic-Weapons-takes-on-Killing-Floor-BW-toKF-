class Weapon_M763Shotgun_PrimaryFire extends BallisticShotgunFire;

function PlayFiring()
{
    if (Weapon.Level.NetMode == NM_Client)
        bSkipFireAnimation = true;

    Super.PlayFiring();

    bSkipFireAnimation = false;
}

simulated event ModeDoFire()
{
    local BallisticWeapon BW;
    local name M763FireAnim;

    BW = BallisticWeapon(Weapon);

    // Do not interfere with gas-shell firing.
    if (bAltFire || (BW != None && BW.bAltLoaded && BW.bAltFirePlaying))
    {
        Super.ModeDoFire();
        return;
    }

    if (BW != None && BW.Role == ROLE_Authority
        && BW.Level.NetMode != NM_Standalone && AllowFire())
    {
        // Final round: select the empty firing animation.
        if (BW.MagAmmoRemaining == 1 && LastShotAnim != '')
            M763FireAnim = LastShotAnim;
        else if (KFWeap != None && KFWeap.bAimingRifle
            && Weapon.HasAnim(FireAimedAnim))
            M763FireAnim = FireAimedAnim;
        else
            M763FireAnim = FireAnim;

        Log("M763 SERVER: Ammo="$BW.MagAmmoRemaining
            $" Selected animation="$M763FireAnim);

        BW.ClientPlayFireAnimation(M763FireAnim, FireAnimRate, TweenTime, 0);
    }

    Super.ModeDoFire();
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_M763Shotgun_Ammo'
    ProjectileClass=Class'BW_Core_KF.BallisticShotgunProj'
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_M763Shotgun_FlashEmitter'
	
    KickMomentum=(X=-45.000000,Z=10.000000)
    ProjPerFire=7
    AmmoPerFire=1
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSoundRef="BWKF_M763_SN.M763.M763Fire1"
    StereoFireSoundRef="BWKF_M763_SN.M763.M763Fire1"
    NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
    FireRate=0.7
    FireAnimRate=1.0
    BotRefireRate=0.200000
    aimerror=1.000000
    Spread=1125.0
    maxVerticalRecoilAngle=1500
    maxHorizontalRecoilAngle=900
	
	LastShotAnim=FireEmpty
    LastShotAnimRate=1.0

    //** View shake **//
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=3.0
    ShakeRotMag=(X=50.0,Y=50.0,Z=400.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=5.0
    bWaitForRelease=True
    bRandomPitchFireSound=false
	
	BrassClass=Class'BW_Core_KF.Brass_Shotgun'
	bBrassOnCock=True
}