class Weapon_M806Pistol_Attachment extends BallisticAttachment;


//=============================================================================
// LASER
//=============================================================================

var bool bLaserOn;
var bool bOldLaserOn;

var BallisticLaserActor_TPStandard Laser;
var Rotator LaserRot;

var Weapon_M806Pistol_Main myWeap;


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

    if (Weapon_M806Pistol_Main(I) != None)
        myWeap = Weapon_M806Pistol_Main(I);
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