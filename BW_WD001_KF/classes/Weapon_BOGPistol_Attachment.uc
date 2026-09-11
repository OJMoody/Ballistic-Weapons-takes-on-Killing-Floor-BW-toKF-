class Weapon_BOGPistol_Attachment extends BallisticAttachment;


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    Mesh=SkeletalMesh'BWKF_BOGP_A.BOGP_TP_Mesh'

    mMuzFlashClass=Class'BW_WD001_KF.Weapon_BOGPistol_FlashEmitter'
    mMuzFlashScale=1.000000

    mTracerClass=Class'KFMod.KFNewTracer'
    mShellCaseEmitterClass=None
    SplashEffect=Class'BulletSplashEmitter'

    LightType=LT_Pulse
    LightRadius=0.000000
    CullDistance=5000.000000

    //=======================================================================
    // THIRD PERSON ANIMATIONS
    //=======================================================================

    MovementAnims(0)=JogF_M79
    MovementAnims(1)=JogB_M79
    MovementAnims(2)=JogL_M79
    MovementAnims(3)=JogR_M79
    CrouchAnims(0)=CHwalkF_M79
    CrouchAnims(1)=CHwalkB_M79
    CrouchAnims(2)=CHwalkL_M79
    CrouchAnims(3)=CHwalkR_M79
    WalkAnims(0)=WalkF_M79
    WalkAnims(1)=WalkB_M79
    WalkAnims(2)=WalkL_M79
    WalkAnims(3)=WalkR_M79
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
    TurnRightAnim=TurnR_M79
    TurnLeftAnim=TurnL_M79
    CrouchTurnRightAnim=CH_TurnR_M79
    CrouchTurnLeftAnim=CH_TurnL_M79
    IdleRestAnim=Idle_M79//Idle_Rest
    IdleCrouchAnim=CHIdle_M79
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_M79//Idle_Rifle
    IdleHeavyAnim=Idle_M79//Idle_Biggun
    IdleRifleAnim=Idle_M79//Idle_Rifle
    IdleChatAnim=Idle_M79
    FireAnims(0)=Fire_M79
    FireAnims(1)=Fire_M79
    FireAnims(2)=Fire_M79
    FireAnims(3)=Fire_M79
    FireAltAnims(0)=Fire_M79
    FireAltAnims(1)=Fire_M79
    FireAltAnims(2)=Fire_M79
    FireAltAnims(3)=Fire_M79
    FireCrouchAnims(0)=CHFire_M79
    FireCrouchAnims(1)=CHFire_M79
    FireCrouchAnims(2)=CHFire_M79
    FireCrouchAnims(3)=CHFire_M79
    FireCrouchAltAnims(0)=CHFire_M79
    FireCrouchAltAnims(1)=CHFire_M79
    FireCrouchAltAnims(2)=CHFire_M79
    FireCrouchAltAnims(3)=CHFire_M79
    HitAnims(0)=HitF_M79
    HitAnims(1)=HitB_M79
    HitAnims(2)=HitL_M79
    HitAnims(3)=HitR_M79
    PostFireBlendStandAnim=Blend_M79
    PostFireBlendCrouchAnim=CHBlend_M79
}