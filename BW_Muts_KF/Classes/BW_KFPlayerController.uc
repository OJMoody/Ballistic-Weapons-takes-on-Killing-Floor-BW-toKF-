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
var byte CameraPerspective;

var() config float ThirdPersonDistance;
var() config float ThirdPersonHeight;
var() config float ThirdPersonShoulderOffset;
var() config float ThirdPersonCameraCollisionRadius;
var() config float ThirdPersonTransitionTime;

var Pawn ThirdPersonVisibilityPawn;
var bool bOriginalOwnerNoSee;
var bool bHasSavedOwnerNoSee;

// Camera transition
var bool bThirdPersonCameraTransitioning;
var float ThirdPersonTransitionStartTime;
var vector ThirdPersonTransitionStartLocation;
var bool bKeepThirdPersonVisualsDuringTransition;
var() config float ThirdPersonTransitionInvisiblePercent;
var float ThirdPersonTransitionInvisibleTime;
var bool bHideThirdPersonAtEndOfTransition;

replication
{
    reliable if (bNetOwner && Role == ROLE_Authority)
        CameraPerspective;
}

function SetPawnClass(string inClass, string inCharacter)
{
    PawnClass = class'BW_KFPawn';

    inCharacter = class'KFGameType'.Static.GetValidCharacter(inCharacter);
    PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
    PlayerReplicationInfo.SetCharacterName(inCharacter);
}

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
    local bool bWasThirdPerson;

    // First Person Only: prevent all perspective switching.
    if (CameraPerspective == 0)
        return;

    bWasThirdPerson = (ThirdPersonCameraMode != TPCM_FirstPerson);

    // Capture the current camera position before changing modes.
    if (Pawn != None && CalcViewActor != None)
    {
        ThirdPersonTransitionStartLocation = CalcViewLocation;
        ThirdPersonTransitionStartTime = Level.TimeSeconds;
        bThirdPersonCameraTransitioning = true;

        ThirdPersonTransitionInvisibleTime =
            ThirdPersonTransitionTime *
            (ThirdPersonTransitionInvisiblePercent / 100.0);
    }

    // Third Person Only: alternate between left and right shoulder.
    if (CameraPerspective == 1)
    {
        if (ThirdPersonCameraMode == TPCM_RightShoulder)
            ThirdPersonCameraMode = TPCM_LeftShoulder;
        else
            ThirdPersonCameraMode = TPCM_RightShoulder;
    }
    // First and Third Person: retain the original camera cycle.
    else
    {
        if (ThirdPersonCameraMode == TPCM_FirstPerson)
            ThirdPersonCameraMode = TPCM_RightShoulder;
        else if (ThirdPersonCameraMode == TPCM_RightShoulder)
            ThirdPersonCameraMode = TPCM_LeftShoulder;
        else
            ThirdPersonCameraMode = TPCM_FirstPerson;
    }

    // Only apply the invisible period when crossing between FP and TP.
    if (!bWasThirdPerson && ThirdPersonCameraMode != TPCM_FirstPerson)
    {
        bHideThirdPersonAtEndOfTransition = false;
    }
    else if (bWasThirdPerson && ThirdPersonCameraMode == TPCM_FirstPerson)
    {
        bHideThirdPersonAtEndOfTransition = true;
    }
    else
    {
        ThirdPersonTransitionInvisibleTime = 0.0;
        bHideThirdPersonAtEndOfTransition = false;
    }

    bKeepThirdPersonVisualsDuringTransition =
        bWasThirdPerson && ThirdPersonCameraMode == TPCM_FirstPerson;

    UpdateThirdPersonPawnVisibility();

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

function SetCameraPerspective(byte NewPerspective)
{
    if (Role != ROLE_Authority)
        return;

    CameraPerspective = Min(NewPerspective, 2);

    ApplyCameraPerspective();
}

simulated function ApplyCameraPerspective()
{
    if (CameraPerspective == 1)
        ThirdPersonCameraMode = TPCM_RightShoulder;
    else
        ThirdPersonCameraMode = TPCM_FirstPerson;

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
    local float TransitionElapsed;

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

    TransitionElapsed = Level.TimeSeconds - ThirdPersonTransitionStartTime;

    // Handle the invisible period during FP/TP transitions.
    if (bThirdPersonCameraTransitioning &&
        ThirdPersonTransitionInvisibleTime > 0.0)
    {
        if (!bHideThirdPersonAtEndOfTransition &&
            TransitionElapsed < ThirdPersonTransitionInvisibleTime)
        {
            // FP -> TP: hide at the beginning.
            P.bOwnerNoSee = true;
        }
        else if (bHideThirdPersonAtEndOfTransition &&
            TransitionElapsed >= ThirdPersonTransitionTime -
            ThirdPersonTransitionInvisibleTime)
        {
            // TP -> FP: hide at the end.
            P.bOwnerNoSee = true;
        }
        else if (ThirdPersonCameraMode == TPCM_FirstPerson &&
            bKeepThirdPersonVisualsDuringTransition)
        {
            P.bOwnerNoSee = false;
        }
        else if (ThirdPersonCameraMode == TPCM_FirstPerson)
        {
            P.bOwnerNoSee = bOriginalOwnerNoSee;
        }
        else
        {
            P.bOwnerNoSee = false;
        }
    }
    else if (ThirdPersonCameraMode == TPCM_FirstPerson &&
        bKeepThirdPersonVisualsDuringTransition)
    {
        P.bOwnerNoSee = false;
    }
    else if (ThirdPersonCameraMode == TPCM_FirstPerson)
    {
        P.bOwnerNoSee = bOriginalOwnerNoSee;
    }
    else
    {
        P.bOwnerNoSee = false;
    }

    // Synchronise the equipped Ballistic weapon's rendering.
    BW = BallisticWeapon(P.Weapon);

    if (BW != None)
    {
        BW.bBWThirdPersonCamera =
            (ThirdPersonCameraMode != TPCM_FirstPerson ||
            bKeepThirdPersonVisualsDuringTransition);
    }

    // Release the saved visibility state after restoring first person.
    if (ThirdPersonCameraMode == TPCM_FirstPerson &&
        !bKeepThirdPersonVisualsDuringTransition &&
        !bThirdPersonCameraTransitioning)
    {
        bHasSavedOwnerNoSee = false;
    }
}


//=============================================================================
// PLAYER CAMERA
//=============================================================================

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
    local vector CameraOrigin;
    local vector DesiredCameraLocation;
    local vector HitLocation;
    local vector HitNormal;
    local float TransitionAlpha;

    // Dedicated server does not need a rendered camera.
    if (Level.NetMode == NM_DedicatedServer)
    {
        Global.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
        return;
    }

    // Enforce Third Person Only.
    if (CameraPerspective == 1 &&
        ThirdPersonCameraMode == TPCM_FirstPerson)
    {
        ApplyCameraPerspective();
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

    // Calculate the normal first-person camera position.
    ViewActor = ViewTarget;
    CameraLocation = ViewTarget.Location;

    CalcFirstPersonView(CameraLocation, CameraRotation);

    // Remember the camera origin for collision detection.
    CameraOrigin = CameraLocation;

    // Calculate the destination camera position.
    if (ThirdPersonCameraMode != TPCM_FirstPerson)
        CalcBWThirdPersonView(CameraLocation, CameraRotation);

    // Smoothly transition between the previous and destination positions.
    if (bThirdPersonCameraTransitioning)
    {
        if (ThirdPersonTransitionTime <= 0.0)
        {
            bThirdPersonCameraTransitioning = false;
        }
        else
        {
            TransitionAlpha = FClamp(
                (Level.TimeSeconds - ThirdPersonTransitionStartTime)
                / ThirdPersonTransitionTime,
                0.0,
                1.0);

            // Smoothstep easing.
            TransitionAlpha = TransitionAlpha * TransitionAlpha
                * (3.0 - 2.0 * TransitionAlpha);

            DesiredCameraLocation = ThirdPersonTransitionStartLocation
                + (CameraLocation - ThirdPersonTransitionStartLocation)
                * TransitionAlpha;

            // Maintain camera collision during the transition.
            if (Trace(
                HitLocation,
                HitNormal,
                DesiredCameraLocation,
                CameraOrigin,
                false,
                vect(10,10,10)) != None)
            {
                CameraLocation = HitLocation
                    + HitNormal * ThirdPersonCameraCollisionRadius;
            }
            else
            {
                CameraLocation = DesiredCameraLocation;
            }

            // Finish the transition.
            if (TransitionAlpha >= 1.0)
            {
                bThirdPersonCameraTransitioning = false;
                bKeepThirdPersonVisualsDuringTransition = false;

                UpdateThirdPersonPawnVisibility();
            }
        }
    }

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

    ThirdPersonTransitionTime=0.300000
	ThirdPersonTransitionInvisiblePercent=15.000000
	
	CameraPerspective=2
}