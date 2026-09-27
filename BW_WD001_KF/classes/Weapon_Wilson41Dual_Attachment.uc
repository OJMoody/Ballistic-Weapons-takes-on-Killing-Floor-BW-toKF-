class Weapon_Wilson41Dual_Attachment extends BallisticAttachment;

#exec OBJ LOAD FILE="BWKF_Wilson_A.ukx"

var Weapon_Wilson41Dual_Main myWeap;
var bool bIsOffHand;

//=============================================================================
// INITIALIZATION
//=============================================================================

function InitFor(Inventory I)
{
    Super.InitFor(I);

    if (Weapon_Wilson41Dual_Main(I) != None)
        myWeap = Weapon_Wilson41Dual_Main(I);
}

//=============================================================================
// THIRD PERSON FIRE
//=============================================================================

simulated function ThirdPersonEffects()
{
    local BallisticAttachment AltAttachment;

    if (myWeap != None)
    {
        if (myWeap.WasLastDualFireLeft())
        {
            if (FlashCount <= 0)
                return;

            if (KFPawn(Instigator) != None)
                KFPawn(Instigator).StartFiringX(true, bRapidFire);

            if (bDoFiringEffects)
            {
                if (myWeap.AltThirdPersonActor != None)
                {
                    AltAttachment = BallisticAttachment(myWeap.AltThirdPersonActor);

                    if (AltAttachment != None)
                    {
                        AltAttachment.WeaponLight();
                        AltAttachment.DoFlashEmitter();

                        if ((AltAttachment.mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail)
                        {
                            AltAttachment.mShellCaseEmitter = AltAttachment.Spawn(AltAttachment.mShellCaseEmitterClass);

                            if (AltAttachment.mShellCaseEmitter != None)
                                AltAttachment.AttachToBone(AltAttachment.mShellCaseEmitter, AltAttachment.ShellEjectBoneName);
                        }

                        if (AltAttachment.mShellCaseEmitter != None)
                            AltAttachment.mShellCaseEmitter.mStartParticles++;
                    }
                }
            }

            return;
        }

        if (bIsOffHand)
            return;
    }

    Super.ThirdPersonEffects();
}

simulated function SetDualMesh(bool bOffHand)
{
    bIsOffHand = bOffHand;

    if (bIsOffHand)
    {
        LinkMesh(Mesh'BWKF_Wilson_A.Wilson_TP_Mesh');
    }
    else
    {
        LinkMesh(Mesh'BWKF_Wilson_A.Wilson_TP_Mesh');
    }
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    Mesh=SkeletalMesh'BWKF_Wilson_A.Wilson_TP_Mesh'

    mMuzFlashClass=Class'BW_WD001_KF.Weapon_Wilson41_FlashEmitter'
    mMuzFlashScale=0.500000

    mTracerClass=Class'KFMod.KFNewTracer'
    mShellCaseEmitterClass=none
    SplashEffect=Class'BulletSplashEmitter'

    LightType=LT_Pulse
    LightRadius=0.000000
    CullDistance=5000.000000

    //=======================================================================
    // THIRD PERSON ANIMATIONS
    //=======================================================================

    MovementAnims(0)=JogF_Dual9mm
    MovementAnims(1)=JogB_Dual9mm
    MovementAnims(2)=JogL_Dual9mm
    MovementAnims(3)=JogR_Dual9mm
    CrouchAnims(0)=CHwalkF_Dual9mm
    CrouchAnims(1)=CHwalkB_Dual9mm
    CrouchAnims(2)=CHwalkL_Dual9mm
    CrouchAnims(3)=CHwalkR_Dual9mm
    WalkAnims(0)=WalkF_Dual9mm
    WalkAnims(1)=WalkB_Dual9mm
    WalkAnims(2)=WalkL_Dual9mm
    WalkAnims(3)=WalkR_Dual9mm
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
    TurnRightAnim=TurnR_Dual9mm
    TurnLeftAnim=TurnL_Dual9mm
    CrouchTurnRightAnim=CH_TurnR_Dual9mm
    CrouchTurnLeftAnim=CH_TurnL_Dual9mm
    IdleRestAnim=Idle_Dual9mm//Idle_Rest
    IdleCrouchAnim=CHIdle_Dual9mm
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_Dual9mm//Idle_Rifle
    IdleHeavyAnim=Idle_Dual9mm//Idle_Biggun
    IdleRifleAnim=Idle_Dual9mm//Idle_Rifle
    IdleChatAnim=Idle_Dual9mm
    FireAnims(0)=DualiesAttackRight
    FireAnims(1)=DualiesAttackRight
    FireAnims(2)=DualiesAttackRight
    FireAnims(3)=DualiesAttackRight
    FireAltAnims(0)=DualiesAttackLeft
    FireAltAnims(1)=DualiesAttackLeft
    FireAltAnims(2)=DualiesAttackLeft
    FireAltAnims(3)=DualiesAttackLeft
    FireCrouchAnims(0)=CHDualiesAttackRight
    FireCrouchAnims(1)=CHDualiesAttackRight
    FireCrouchAnims(2)=CHDualiesAttackRight
    FireCrouchAnims(3)=CHDualiesAttackRight
    FireCrouchAltAnims(0)=CHDualiesAttackLeft
    FireCrouchAltAnims(1)=CHDualiesAttackLeft
    FireCrouchAltAnims(2)=CHDualiesAttackLeft
    FireCrouchAltAnims(3)=CHDualiesAttackLeft
    HitAnims(0)=HitF_Dual9mmm
    HitAnims(1)=HitB_Dual9mm
    HitAnims(2)=HitL_Dual9mm
    HitAnims(3)=HitR_Dual9mm
    PostFireBlendStandAnim=Blend_Dual9mm
    PostFireBlendCrouchAnim=CHBlend_Dual9mm
}