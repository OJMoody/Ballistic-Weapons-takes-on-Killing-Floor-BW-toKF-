class Weapon_MRT6Shotgun_Attachment extends BallisticAttachment;

var Emitter FlashEmitterLeft;
var Emitter FlashEmitterRight;

simulated function DoFlashEmitter()
{
    local Weapon_MRT6Shotgun_Main MRT6;

    MRT6 = Weapon_MRT6Shotgun_Main(Instigator.Weapon);

    if (FlashEmitterLeft == None)
    {
        FlashEmitterLeft = Spawn(mMuzFlashClass);

        if (FlashEmitterLeft != None)
        {
            AttachToBone(FlashEmitterLeft, 'TipL');
            FlashEmitterLeft.SetRelativeRotation(Rot(0, 32768, 0));
        }
    }

    if (FlashEmitterRight == None)
    {
        FlashEmitterRight = Spawn(mMuzFlashClass);

        if (FlashEmitterRight != None)
        {
            AttachToBone(FlashEmitterRight, 'TipR');
            FlashEmitterRight.SetRelativeRotation(Rot(0, 32768, 0));
        }
    }

    if (MRT6 == None)
        return;

    if (MRT6.ThirdPersonFireBarrel == 0)
    {
        if (FlashEmitterLeft != None)
            FlashEmitterLeft.SpawnParticle(1);

        if (FlashEmitterRight != None)
            FlashEmitterRight.SpawnParticle(1);
    }
    else if (MRT6.ThirdPersonFireBarrel == 1)
    {
        if (FlashEmitterLeft != None)
            FlashEmitterLeft.SpawnParticle(1);
    }
    else if (MRT6.ThirdPersonFireBarrel == 2)
    {
        if (FlashEmitterRight != None)
            FlashEmitterRight.SpawnParticle(1);
    }
}

simulated function Destroyed()
{
    if (FlashEmitterLeft != None)
    {
        FlashEmitterLeft.Destroy();
        FlashEmitterLeft = None;
    }

    if (FlashEmitterRight != None)
    {
        FlashEmitterRight.Destroy();
        FlashEmitterRight = None;
    }

    Super.Destroyed();
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    Mesh=SkeletalMesh'BWKF_MRT6_A.MRT6_TP_Mesh'

    mMuzFlashClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_FlashEmitter'
    mMuzFlashScale=1.000000

    mTracerClass=Class'KFMod.KFNewTracer'
    mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
    SplashEffect=Class'BulletSplashEmitter'

    LightType=LT_Pulse
    LightRadius=0.000000
    CullDistance=5000.000000

    //=======================================================================
    // THIRD PERSON ANIMATIONS
    //=======================================================================

    MovementAnims(0)=JogF_Single9mm
    MovementAnims(1)=JogB_Single9mm
    MovementAnims(2)=JogL_Single9mm
    MovementAnims(3)=JogR_Single9mm
    CrouchAnims(0)=CHwalkF_Single9mm
    CrouchAnims(1)=CHwalkB_Single9mm
    CrouchAnims(2)=CHwalkL_Single9mm
    CrouchAnims(3)=CHwalkR_Single9mm
    WalkAnims(0)=WalkF_Single9mm
    WalkAnims(1)=WalkB_Single9mm
    WalkAnims(2)=WalkL_Single9mm
    WalkAnims(3)=WalkR_Single9mm
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
    TurnRightAnim=TurnR_Single9mm
    TurnLeftAnim=TurnL_Single9mm
    CrouchTurnRightAnim=CH_TurnR_Single9mm
    CrouchTurnLeftAnim=CH_TurnL_Single9mm
    IdleRestAnim=Idle_Single9mm
    IdleCrouchAnim=CHIdle_Single9mm
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_Single9mm
    IdleHeavyAnim=Idle_Single9mm
    IdleRifleAnim=Idle_Single9mm
    IdleChatAnim=Idle_Single9mm
    FireAnims(0)=Fire_Single9mm
    FireAnims(1)=Fire_Single9mm
    FireAnims(2)=Fire_Single9mm
    FireAnims(3)=Fire_Single9mm
    FireAltAnims(0)=Fire_Single9mm
    FireAltAnims(1)=Fire_Single9mm
    FireAltAnims(2)=Fire_Single9mm
    FireAltAnims(3)=Fire_Single9mm
    FireCrouchAnims(0)=CHFire_Single9mm
    FireCrouchAnims(1)=CHFire_Single9mm
    FireCrouchAnims(2)=CHFire_Single9mm
    FireCrouchAnims(3)=CHFire_Single9mm
    FireCrouchAltAnims(0)=CHFire_Single9mm
    FireCrouchAltAnims(1)=CHFire_Single9mm
    FireCrouchAltAnims(2)=CHFire_Single9mm
    FireCrouchAltAnims(3)=CHFire_Single9mm
    HitAnims(0)=HitF_Single9mm
    HitAnims(1)=HitB_Single9mm
    HitAnims(2)=HitL_Single9mm
    HitAnims(3)=HitR_Single9mm
    PostFireBlendStandAnim=Blend_Single9mm
    PostFireBlendCrouchAnim=CHBlend_Single9mm
}