class Weapon_M50Rifle_Attachment extends BallisticAttachment;

//=============================================================================
// LASER
//=============================================================================

var bool bLaserOn;
var bool bOldLaserOn;

var BallisticLaserActor_TPStandard Laser;
var Rotator LaserRot;

var class<Emitter> mMuzFlashClassSecondary;
var Emitter mMuzFlash3rdSecondary;

//=============================================================================
// LASER REPLICATION
//=============================================================================

replication
{
    reliable if (Role == ROLE_Authority)
        bLaserOn;

    unreliable if (Role == ROLE_Authority)
        LaserRot;
}


//=============================================================================
// THIRD PERSON LASER
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

    // Server maintains the player's aim direction.
    if (bLaserOn &&
        Role == ROLE_Authority &&
        Instigator != None)
    {
        LaserRot = Instigator.GetViewRotation();
    }

    if (Level.NetMode == NM_DedicatedServer)
        return;

    // Create the third-person laser actor.
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

    // Hide the beam when it should not be visible.
    if (!bLaserOn || Instigator == None || (Instigator.IsFirstPerson() && (BallisticWeapon(Instigator.Weapon) == None || !BallisticWeapon(Instigator.Weapon).bBWThirdPersonCamera)) || Instigator.DrivenVehicle != None)
    {
        if (Laser != None)
            Laser.bHidden = true;

        return;
    }

    if (Laser == None)
        return;

    if (Laser.bHidden)
        Laser.bHidden = false;

    // Trace direction follows the player's view.
    Start = Instigator.Location + Instigator.EyePosition();
    X = LaserRot;

    // Laser origin on the M50 third-person mesh.
    Loc = GetBoneCoords('lasertip').Origin;

    End = Start + Vector(X) * 5000;

    Other = Trace(
        HitLocation,
        HitNormal,
        End,
        Start,
        true
    );

    if (Other == None)
        HitLocation = End;

    // Position and scale the third-person beam.
    Laser.SetLocation(Loc);
    Laser.SetRotation(Rotator(HitLocation - Loc));

    Scale3D.X = VSize(HitLocation - Loc) / 128;
    Scale3D.Y = 1.0;
    Scale3D.Z = 1.0;

    Laser.SetDrawScale3D(Scale3D);
}

simulated function DoFlashEmitter()
{
	if (FiringMode == 1)
    {
        if (mMuzFlash3rdSecondary == None)
        {
            mMuzFlash3rdSecondary = Spawn(mMuzFlashClassSecondary);

            if (mMuzFlash3rdSecondary != None)
            {
                AttachToBone(mMuzFlash3rdSecondary, 'GrenMuzzle');

                if (mMuzFlashScale != 1.0 && BallisticEmitter(mMuzFlash3rdSecondary) != None)
                    BallisticEmitter(mMuzFlash3rdSecondary).ScaleEmitter(mMuzFlash3rdSecondary, mMuzFlashScale);
            }
        }

        if (mMuzFlash3rdSecondary != None)
            mMuzFlash3rdSecondary.SpawnParticle(1);

        return;
    }

    Super.DoFlashEmitter();
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

defaultproperties
{
    Mesh=SkeletalMesh'BWKF_M50_A.M50_TP_Mesh'
	DrawScale=0.500000

    mMuzFlashClass=Class'BW_WD001_KF.Weapon_M50Rifle_PrimaryFlashEmitter'
	mMuzFlashClassSecondary=Class'BW_WD001_KF.Weapon_M50Rifle_SecondaryFlashEmitter'
	mMuzFlashScale=0.500000

    mTracerClass=Class'BW_Core_KF.TraceEmitter_Default'
    mShellCaseEmitterClass=Class'BW_WD001_KF.Weapon_M50Rifle_Brass'
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