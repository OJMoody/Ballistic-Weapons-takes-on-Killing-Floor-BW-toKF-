class BW_WelderUseInteraction extends Interaction;

//=============================================================================
// VARIABLES
//=============================================================================

var float WelderUseTime;
var bool bTriggered;

//=============================================================================
// INPUT
//=============================================================================

function bool KeyEvent(out EInputKey Key, out EInputAction Action, float Delta)
{
    local BW_KFPlayerController BWPC;

    if (Key != IK_E)
        return false;

    if (ViewportOwner == None)
        return false;

    BWPC = BW_KFPlayerController(ViewportOwner.Actor);

    if (BWPC == None)
        return false;

    if (Action == IST_Press)
    {
        if (!BWPC.bWelderUseHeld)
        {
            BWPC.bWelderUseHeld = true;
            WelderUseTime = 0.0;
            bTriggered = false;
        }
    }
    else if (Action == IST_Release)
    {
        BWPC.bWelderUseHeld = false;
        WelderUseTime = 0.0;
        bTriggered = false;
    }

    return false;
}

//=============================================================================
// TICK
//=============================================================================

function Tick(float DeltaTime)
{
    local BW_KFPlayerController BWPC;

    if (ViewportOwner == None)
        return;

    BWPC = BW_KFPlayerController(ViewportOwner.Actor);

    if (BWPC == None || !BWPC.bWelderUseHeld || bTriggered)
        return;

    WelderUseTime += DeltaTime;

    if (WelderUseTime >= 0.5)
    {
        bTriggered = true;
        BWPC.ServerTrySelectWD200();
    }
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    bActive=True
    bRequiresTick=True
    bVisible=False
    bNativeEvents=False
}