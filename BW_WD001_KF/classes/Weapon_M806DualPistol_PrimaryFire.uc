//=============================================================================
// M806A2 Primary Fire
//=============================================================================
class Weapon_M806DualPistol_PrimaryFire extends BallisticInstantFire;

function PlayFiring()
{
    if (Weapon.Level.NetMode == NM_Client)
        bSkipFireAnimation = true;

    Super.PlayFiring();

    bSkipFireAnimation = false;
}

event ModeDoFire()
{
    local Weapon_M806DualPistol_Main M806;
    local name M806FireAnim;
    local int FireChannel;

    M806 = Weapon_M806DualPistol_Main(Weapon);

    if (M806 != None && AllowFire())
    {
        if (M806.Role == ROLE_Authority && M806.Level.NetMode != NM_Standalone)
        {
            // SELECT PISTOL FROM REMAINING AMMO
            if ((M806.MagAmmoRemaining % 2) == 0)
            {
                // EVEN AMMO = RIGHT PISTOL
                FireChannel = 2;

                if (M806.bAimingRifle)
                    M806FireAnim = M806.GetDualSightFireAnim(false);
                else
                    M806FireAnim = M806.GetDualFireAnim(false);
            }
            else
            {
                // ODD AMMO = LEFT PISTOL
                FireChannel = 1;

                if (M806.bAimingRifle)
                    M806FireAnim = M806.GetDualSightFireAnim(true);
                else
                    M806FireAnim = M806.GetDualFireAnim(true);
            }

            M806.ClientPlayFireAnimation(M806FireAnim, FireAnimRate, TweenTime, FireChannel);
        }
    }

    Super.ModeDoFire();
}

defaultproperties
{
    DamageType=Class'KFMod.DamTypeDualies'
    DamageMin=35
    DamageMax=45
    Momentum=10000.000000
    bPawnRapidFireAnim=True
    bAttachSmokeEmitter=True
    TransientSoundVolume=1.8
    FireSound=Sound'BWKF_M806_SN.M806Fire'
    StereoFireSoundRef="BWKF_M806_SN.M806Fire"
    NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
    FireForce="AssaultRifleFire"
    FireRate=0.125
    RecoilRate=0.1
    maxVerticalRecoilAngle=300
    maxHorizontalRecoilAngle=50
    TweenTime=0.025
    AmmoClass=Class'BW_WD001_KF.Weapon_M806DualPistol_Ammo'
    AmmoPerFire=1
    BotRefireRate=0.350000
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_M806Pistol_FlashEmitter'
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
    bRandomPitchFireSound=false
	
	BrassClass=Class'BW_WD001_KF.Weapon_M806Pistol_Brass'
}