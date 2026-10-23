class BW_GUIBuyWeaponInfoPanel extends GUIBuyWeaponInfoPanel;

var automated GUIButton GrenadePreviousButton;
var automated GUIButton GrenadeNextButton;
var automated GUIButton GrenadeConfirmButton;
var BW_KFTab_BuyMenu BuyMenuTab;

//=============================================================================
// GRENADE SELECTION CONTROLS
//=============================================================================

function SetGrenadeControlsVisible(bool bVisible)
{
    if (BuyMenuTab != None && BuyMenuTab.bGrenadeSelectionConfirmed)
        bVisible = false;

    GrenadePreviousButton.SetVisibility(bVisible);
    GrenadeNextButton.SetVisibility(bVisible);
    GrenadeConfirmButton.SetVisibility(bVisible);
}

function bool InternalOnClick(GUIComponent Sender)
{
    if (Sender == GrenadePreviousButton)
    {
        if (BuyMenuTab != None && !BuyMenuTab.bGrenadeSelectionConfirmed)
            NotifyGrenadePrevious();

        return true;
    }

    if (Sender == GrenadeNextButton)
    {
        if (BuyMenuTab != None && !BuyMenuTab.bGrenadeSelectionConfirmed)
            NotifyGrenadeNext();

        return true;
    }

    if (Sender == GrenadeConfirmButton)
    {
        if (BuyMenuTab != None && !BuyMenuTab.bGrenadeSelectionConfirmed)
            BuyMenuTab.ConfirmGrenadeSelection();

        return true;
    }

    return Super.InternalOnClick(Sender);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    SetGrenadeControlsVisible(false);
}

function SetGrenadeSelectionMode(bool bEnabled)
{
    SetGrenadeControlsVisible(bEnabled);
}

function NotifyGrenadePrevious()
{
    if (BuyMenuTab != None)
        BuyMenuTab.CycleGrenadeSelection(-1);
}

function NotifyGrenadeNext()
{
    if (BuyMenuTab != None)
        BuyMenuTab.CycleGrenadeSelection(1);
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    Begin Object Class=GUIButton Name=GrenadePrevious
        Caption="<"
        WinTop=0.005236
        WinLeft=0.035800
        WinWidth=0.12
        WinHeight=0.070000
        bScaleToParent=true
        bBoundToParent=true
        bAcceptsInput=true
        OnClick=InternalOnClick
    End Object
    GrenadePreviousButton=GrenadePrevious

    Begin Object Class=GUIButton Name=GrenadeNext
        Caption=">"
        WinTop=0.005236
        WinLeft=0.844200
        WinWidth=0.12
        WinHeight=0.070000
        bScaleToParent=true
        bBoundToParent=true
        bAcceptsInput=true
        OnClick=InternalOnClick
    End Object
    GrenadeNextButton=GrenadeNext

    Begin Object Class=GUIButton Name=GrenadeConfirm
        Caption="Confirm"
        WinTop=0.885000
        WinLeft=0.25
        WinWidth=0.5
        WinHeight=0.075000
        bScaleToParent=true
        bBoundToParent=true
        bAcceptsInput=true
        OnClick=InternalOnClick
    End Object
    GrenadeConfirmButton=GrenadeConfirm
}