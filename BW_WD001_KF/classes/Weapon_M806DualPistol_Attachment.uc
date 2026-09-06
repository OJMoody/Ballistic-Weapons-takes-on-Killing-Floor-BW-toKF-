class Weapon_M806DualPistol_Attachment extends BallisticAttachment;

#exec OBJ LOAD FILE="BWKF_M806_A.ukx"

//=============================================================================
// LASER
//=============================================================================

var bool bLaserOn;
var bool bOldLaserOn;

var BallisticLaserActor_TPStandard Laser;
var Rotator LaserRot;

var Weapon_M806DualPistol_Main myWeap;
var bool bIsOffHand;


//=============================================================================
// REPLICATION
//=============================================================================

replication
{
    reliable if (Role == ROLE_Authority)
        bLaserOn;

    unreliable if (Role == ROLE_Authority)
        LaserRot;
}


//=============================================================================
// INITIALIZATION
//=============================================================================

function InitFor(Inventory I)
{
    Super.InitFor(I);

    if (Weapon_M806DualPistol_Main(I) != None)
        myWeap = Weapon_M806DualPistol_Main(I);
}

//=============================================================================
// THIRD PERSON FIRE
//=============================================================================

simulated function ThirdPersonEffects()
{
    if (myWeap != None && myWeap.WasLastDualFireLeft())
    {
        myWeap.PlayAltThirdPersonFire();
        myWeap.PlayAltThirdPersonFlash();
        return;
    }

    Super.ThirdPersonEffects();
    PlayThirdPersonFire();
}

simulated function SetDualMesh(bool bOffHand)
{
    bIsOffHand = bOffHand;

    if (bIsOffHand)
    {
        LinkMesh(Mesh'BWKF_M806_A.M806Dual_TP_Mesh');
        Log("M806 TP: LEFT attachment SetDualMesh called");
    }
    else
    {
        LinkMesh(Mesh'BWKF_M806_A.M806_TP_Mesh');
        Log("M806 TP: RIGHT attachment SetDualMesh called");
    }
}

//=============================================================================
// LASER
//=============================================================================

simulated function Tick(float DT)
{
    local Vector HitLocation;
    local Vector Start;
    local Vector End;
    local Vector HitNormal;
    local Vector Scale3D;
    local Vector Loc;

    local Rotator X;
    local Actor Other;

    Super.Tick(DT);

    //=========================================================================
    // SERVER AIM DIRECTION
    //=========================================================================

    if (bLaserOn &&
        Role == ROLE_Authority &&
        Instigator != None)
    {
        LaserRot =
            Instigator.GetViewRotation();
    }

    //=========================================================================
    // DEDICATED SERVER
    //=========================================================================

    if (Level.NetMode == NM_DedicatedServer)
        return;

    //=========================================================================
    // CREATE LASER
    //=========================================================================

    if (Laser == None)
    {
        Laser = Spawn(
            class'BallisticLaserActor_TPStandard',
            ,
            ,
            Location
        );
    }

    if (bLaserOn != bOldLaserOn)
        bOldLaserOn = bLaserOn;

    //=========================================================================
    // HIDE LASER WHEN NOT REQUIRED
    //=========================================================================

    if (!bLaserOn ||
        Instigator == None ||
        Instigator.IsFirstPerson() ||
        Instigator.DrivenVehicle != None)
    {
        if (Laser != None)
            Laser.bHidden = true;

        return;
    }

    if (Laser.bHidden)
        Laser.bHidden = false;

    //=========================================================================
    // TRACE START
    //=========================================================================

    if (Instigator != None)
    {
        Start =
            Instigator.Location +
            Instigator.EyePosition();
    }
    else
    {
        Start = Location;
    }

    X = LaserRot;

    //=========================================================================
    // LASER ORIGIN
    //=========================================================================

    Loc =
        GetBoneCoords('laserPoint').Origin;

    //=========================================================================
    // TRACE END
    //=========================================================================

    End =
        Start +
        Vector(X) *
        5000;

    //=========================================================================
    // TRACE
    //=========================================================================

    Other = Trace(
        HitLocation,
        HitNormal,
        End,
        Start,
        true
    );

    if (Other == None)
        HitLocation = End;

    //=========================================================================
    // DRAW LASER
    //=========================================================================

    Laser.SetLocation(Loc);

    Laser.SetRotation(
        Rotator(HitLocation - Loc)
    );

    Scale3D.X =
        VSize(HitLocation - Loc) /
        128;

    Scale3D.Y = 1.000000;
    Scale3D.Z = 1.000000;

    Laser.SetDrawScale3D(Scale3D);
}


//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (Laser != None)
        Laser.Destroy();

    Super.Destroyed();
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    Mesh=SkeletalMesh'BWKF_M806_A.M806_TP_Mesh'

    mMuzFlashClass=Class'BW_WD001_KF.Weapon_M806Pistol_FlashEmitter'
    mMuzFlashScale=0.500000

    mTracerClass=Class'KFMod.KFNewTracer'
    mShellCaseEmitterClass=Class'KFMod.KFShellSpewer'
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