class Weapon_XK2SMG_Attachment extends BallisticAttachment;

#exec OBJ LOAD FILE=BWKF_Core_T.utx
#exec OBJ LOAD FILE=BWKF_XK2_T.utx

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

var class<Emitter> mMuzFlashClassSecondary;
var Emitter mMuzFlash3rdSecondary;

simulated function UpdateAMPVisuals()
{
    local Weapon_XK2SMG_Main XK2;
    local class<Emitter> NewFlashClass;

    if (Instigator == None)
        return;

    XK2 = Weapon_XK2SMG_Main(Instigator.Weapon);

    if (XK2 == None)
        return;
		
	// Update third-person AMP materials.
	if (XK2.bAmpAttached)
	{
		if (XK2.bAMPDepleted)
		{
			Skins[0] = Shader'BWKF_XK2_T.XK2.XK2_Main-Shiney';
			Skins[2] = Texture'BWKF_Core_T.Misc.Invisible';
			Skins[1] = Texture'BWKF_Core_T.AMP.Amp-BaseDepleted';
		}
		else
		{
			Skins[0] = Shader'BWKF_XK2_T.XK2.XK2_Main-Shiney';
			Skins[1] = Shader'BWKF_Core_T.AMP.Amp-FinalCyan';
			Skins[2] = Shader'BWKF_Core_T.AMP.Amp-GlowCyanShader';
		}
	}

    // Select the correct third-person muzzle flash.
    if (XK2.bAmpAttached)
    {
        NewFlashClass = class'BW_Core_KF.IceDartMuzzleFlash';
        mTracerClass = None;
    }
    else
    {
        NewFlashClass = class'BW_WD001_KF.Weapon_XK2SMG_FlashEmitter';
        mTracerClass = class'BW_Core_KF.TraceEmitter_Default';
    }

    // Replace the existing muzzle flash if the class has changed.
    if (mMuzFlashClass != NewFlashClass)
    {
        if (mMuzFlash3rd != None)
        {
            mMuzFlash3rd.Destroy();
            mMuzFlash3rd = None;
        }

        mMuzFlashClass = NewFlashClass;
    }
}

simulated function vector GetTracerStart()
{
    local Pawn P;

    P = Instigator;

    if (P != None && BallisticWeapon(P.Weapon) != None)
    {
        if (BallisticWeapon(P.Weapon).bBWThirdPersonCamera)
            return GetBoneCoords('TP_tip').Origin;

        return P.Weapon.GetEffectStart();
    }

    return GetBoneCoords('TP_tip').Origin;
}

simulated function SpawnTracer()
{
    if (mTracerClass == None)
        return;

    Super.SpawnTracer();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 0.0, 'AMP');
}

defaultproperties
{
    Mesh=SkeletalMesh'BWKF_XK2_A.XK2_TP_Mesh'

    mMuzFlashClass=Class'BW_WD001_KF.Weapon_XK2SMG_FlashEmitter'
	mMuzFlashScale=0.400000

    mTracerClass=Class'BW_Core_KF.TraceEmitter_Default'
    mShellCaseEmitterClass=Class'BW_WD001_KF.Weapon_XK2SMG_Brass'
    SplashEffect=Class'BulletSplashEmitter'

    LightType=LT_Pulse
    LightRadius=0.000000
    CullDistance=5000.000000

    //=======================================================================
    // THIRD PERSON ANIMATIONS
    //=======================================================================

    MovementAnims(0)=JogF_AK47
    MovementAnims(1)=JogB_AK47
    MovementAnims(2)=JogL_AK47
    MovementAnims(3)=JogR_AK47
    CrouchAnims(0)=CHwalkF_AK47
    CrouchAnims(1)=CHwalkB_AK47
    CrouchAnims(2)=CHwalkL_AK47
    CrouchAnims(3)=CHwalkR_AK47
    WalkAnims(0)=WalkF_AK47
    WalkAnims(1)=WalkB_AK47
    WalkAnims(2)=WalkL_AK47
    WalkAnims(3)=WalkR_AK47
    AirStillAnim=JumpF_Mid
    AirAnims(0)=JumpF_Mid
    AirAnims(1)=JumpF_Mid
    AirAnims(2)=JumpL_Mid
    AirAnims(3)=JumpR_Mid
    TakeoffStillAnim=JumpF_Takeoff
    TakeoffAnims(0)=JumpF_Takeoff
    TakeoffAnims(1)=JumpF_Takeoff
    TakeoffAnims(2)=JumpL_Takeoff
    TakeoffAnims(3)=JumpR_Takeoff
    LandAnims(0)=JumpF_Land
    LandAnims(1)=JumpF_Land
    LandAnims(2)=JumpL_Land
    LandAnims(3)=JumpR_Land
    TurnRightAnim=TurnR_AK47
    TurnLeftAnim=TurnL_AK47
    CrouchTurnRightAnim=CH_TurnR_AK47
    CrouchTurnLeftAnim=CH_TurnL_AK47
    IdleRestAnim=Idle_AK47//Idle_Rest
    IdleCrouchAnim=CHIdle_AK47
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_AK47//Idle_Rifle
    IdleHeavyAnim=Idle_AK47//Idle_Biggun
    IdleRifleAnim=Idle_AK47//Idle_Rifle
    IdleChatAnim=Idle_AK47
    FireAnims(0)=Fire_AK47
    FireAnims(1)=Fire_AK47
    FireAnims(2)=Fire_AK47
    FireAnims(3)=Fire_AK47
    FireAltAnims(0)=Fire_AK47
    FireAltAnims(1)=Fire_AK47
    FireAltAnims(2)=Fire_AK47
    FireAltAnims(3)=Fire_AK47
    FireCrouchAnims(0)=CHFire_AK47
    FireCrouchAnims(1)=CHFire_AK47
    FireCrouchAnims(2)=CHFire_AK47
    FireCrouchAnims(3)=CHFire_AK47
    FireCrouchAltAnims(0)=CHFire_AK47
    FireCrouchAltAnims(1)=CHFire_AK47
    FireCrouchAltAnims(2)=CHFire_AK47
    FireCrouchAltAnims(3)=CHFire_AK47
    HitAnims(0)=HitF_AK47
    HitAnims(1)=HitB_AK47
    HitAnims(2)=HitL_AK47
    HitAnims(3)=HitR_AK47
    PostFireBlendStandAnim=Blend_AK47
    PostFireBlendCrouchAnim=CHBlend_AK47
}