class BW_KFPlayerController extends KFPlayerController;

//=============================================================================
// THIRD-PERSON CAMERA
//=============================================================================

enum EThirdPersonCameraMode
{
    TPCM_FirstPerson,
    TPCM_RightShoulder,
    TPCM_LeftShoulder
};

var EThirdPersonCameraMode ThirdPersonCameraMode;

var() config float ThirdPersonDistance;
var() config float ThirdPersonHeight;
var() config float ThirdPersonShoulderOffset;
var() config float ThirdPersonCameraCollisionRadius;
var Pawn ThirdPersonVisibilityPawn;
var bool bOriginalOwnerNoSee;
var bool bHasSavedOwnerNoSee;

//=============================================================================
// BUY MENU
//=============================================================================

function ShowBuyMenu(string wlTag, float maxweight)
{
    StopForceFeedback();

    ClientOpenMenu("BW_Muts_KF.BW_GUIBuyMenu",,wlTag,string(maxweight));
}

//=============================================================================
// CAMERA MODE CYCLING
//=============================================================================

exec function ToggleBehindView()
{
    CycleThirdPersonCamera();
}

function CycleThirdPersonCamera()
{
    local BallisticWeapon BW;

    if (ThirdPersonCameraMode == TPCM_FirstPerson)
        ThirdPersonCameraMode = TPCM_RightShoulder;
    else if (ThirdPersonCameraMode == TPCM_RightShoulder)
        ThirdPersonCameraMode = TPCM_LeftShoulder;
    else
        ThirdPersonCameraMode = TPCM_FirstPerson;

    UpdateThirdPersonPawnVisibility();

    // Update player FOV if already aiming with a model scope.
    if (Pawn == None)
    {
        LastPlayerCalcView = -1.0;
        return;
    }

    BW = BallisticWeapon(Pawn.Weapon);

    if (BW != None && BW.bAimingRifle && BW.UsesModelScope())
    {
        if (ThirdPersonCameraMode == TPCM_FirstPerson)
			TransitionFOV(DefaultFOV, BW.ZoomTime);
		else
			TransitionFOV(BW.PlayerIronSightFOV, BW.ZoomTime);
    }

    LastPlayerCalcView = -1.0;
}

//=============================================================================
// THIRD-PERSON CAMERA CALCULATION
//=============================================================================

function CalcBWThirdPersonView(out vector CameraLocation, out rotator CameraRotation)
{
    local vector X;
    local vector Y;
    local vector Z;
    local vector DesiredLocation;
    local vector HitLocation;
    local vector HitNormal;
    local float ShoulderOffset;

    CameraRotation.Roll = 0;

    GetAxes(CameraRotation, X, Y, Z);

    if (ThirdPersonCameraMode == TPCM_RightShoulder)
        ShoulderOffset = ThirdPersonShoulderOffset;
    else
        ShoulderOffset = -ThirdPersonShoulderOffset;

    DesiredLocation = CameraLocation
        - X * ThirdPersonDistance
        + Y * ShoulderOffset
        + Z * ThirdPersonHeight;

    if (Trace(
        HitLocation,
        HitNormal,
        DesiredLocation,
        CameraLocation,
        false,
        vect(10,10,10)) != None)
    {
        CameraLocation = HitLocation + HitNormal * ThirdPersonCameraCollisionRadius;
    }
    else
    {
        CameraLocation = DesiredLocation;
    }
}


//=============================================================================
// THIRD-PERSON PAWN VISIBILITY
//=============================================================================

function UpdateThirdPersonPawnVisibility()
{
    local Pawn P;
    local BallisticWeapon BW;

    P = Pawn;

    // Restore the previous pawn if possession has changed.
    if (ThirdPersonVisibilityPawn != P)
    {
        if (ThirdPersonVisibilityPawn != None && bHasSavedOwnerNoSee)
            ThirdPersonVisibilityPawn.bOwnerNoSee = bOriginalOwnerNoSee;

        ThirdPersonVisibilityPawn = P;
        bHasSavedOwnerNoSee = false;
    }

    if (P == None)
        return;

    // Remember the pawn's original visibility setting.
    if (!bHasSavedOwnerNoSee)
    {
        bOriginalOwnerNoSee = P.bOwnerNoSee;
        bHasSavedOwnerNoSee = true;
    }

    if (ThirdPersonCameraMode == TPCM_FirstPerson)
    {
        P.bOwnerNoSee = bOriginalOwnerNoSee;
    }
    else
    {
        P.bOwnerNoSee = false;
    }

    // Synchronise the equipped Ballistic weapon's first-person rendering.
    BW = BallisticWeapon(P.Weapon);

    if (BW != None)
        BW.bBWThirdPersonCamera = (ThirdPersonCameraMode != TPCM_FirstPerson);

    // Release the saved visibility state after restoring first person.
    if (ThirdPersonCameraMode == TPCM_FirstPerson)
        bHasSavedOwnerNoSee = false;
}


//=============================================================================
// PLAYER CAMERA
//=============================================================================

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
    // Dedicated server does not need a rendered camera.
    if (Level.NetMode == NM_DedicatedServer)
    {
        Global.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
        return;
    }

    UpdateThirdPersonPawnVisibility();

    // Reuse the cached camera result when it is still valid.
    if (LastPlayerCalcView == Level.TimeSeconds &&
        CalcViewActor != None &&
        CalcViewActor.Location == CalcViewActorLocation)
    {
        ViewActor = CalcViewActor;
        CameraLocation = CalcViewLocation;
        CameraRotation = CalcViewRotation;
        return;
    }

    // Preserve pawn-specific camera behaviour.
    if (Pawn(ViewTarget) != None && Pawn(ViewTarget).bSpecialCalcView)
    {
        if (Pawn(ViewTarget).SpecialCalcView(ViewActor, CameraLocation, CameraRotation))
        {
            CacheCalcView(ViewActor, CameraLocation, CameraRotation);
            return;
        }
    }

    // Let the engine handle invalid or non-pawn view targets.
    if (ViewTarget == None || ViewTarget.bDeleteMe || ViewTarget != Pawn)
    {
        Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
        return;
    }

    // First-person mode uses the normal KF camera calculation.
    ViewActor = ViewTarget;
    CameraLocation = ViewTarget.Location;

    CalcFirstPersonView(CameraLocation, CameraRotation);

    // Replace the normal camera position with our shoulder camera.
    if (ThirdPersonCameraMode != TPCM_FirstPerson)
        CalcBWThirdPersonView(CameraLocation, CameraRotation);

    CacheCalcView(ViewActor, CameraLocation, CameraRotation);
}

function bool IsBWThirdPersonCameraActive()
{
    return ThirdPersonCameraMode != TPCM_FirstPerson;
}

//=============================================================================

defaultproperties
{
    ThirdPersonCameraMode=TPCM_FirstPerson

    ThirdPersonDistance=180.000000
    ThirdPersonHeight=12.000000
    ThirdPersonShoulderOffset=35.000000
    ThirdPersonCameraCollisionRadius=6.000000
}