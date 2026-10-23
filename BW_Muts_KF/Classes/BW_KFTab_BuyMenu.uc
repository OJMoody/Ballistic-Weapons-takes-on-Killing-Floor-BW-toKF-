class BW_KFTab_BuyMenu extends KFTab_BuyMenu;

var class<BallisticHandGrenade> CurrentGrenadeClass;
var class<BallisticHandGrenade> PendingGrenadeClass;
var array< class<BallisticHandGrenade> > GrenadeClasses;
var int PendingGrenadeIndex;
var bool bGrenadeSelectionConfirmed;
var int GrenadeSelectionConfirmedWave;

function DoBuy()
{
    if (KFPawn(PlayerOwner().Pawn) != None)
    {
        if (TheBuyable == None)
            return;

        // Grenades purchase ammunition, not another weapon.
        if (class<BallisticHandGrenade>(TheBuyable.ItemWeaponClass) != None)
        {
            DoBuyGrenade(false);
        }
        else if (class<Potato>(TheBuyable.ItemPickupClass) != None)
        {
            if (PlayerOwner().SteamStatsAndAchievements.DoPotato())
                KFPawn(PlayerOwner().Pawn).ServerBuyPotato();
        }
        else
        {
            KFPawn(PlayerOwner().Pawn).ServerBuyWeapon(TheBuyable.ItemWeaponClass, TheBuyable.ItemWeight);
        }

        MakeSomeBuyNoise();

        SaleSelect.List.SetIndex(-1);
        SaleSelect.List.BuyableToDisplay = None;
        TheBuyable = None;
        LastBuyable = None;

        UpdateBuySellButtons();
    }
}

function GUIBuyable BuildGrenadeBuyable(class<BallisticHandGrenade> GrenadeClass)
{
    local GUIBuyable GrenadeBuyable;
    local class<KFWeaponPickup> GrenadePickup;

    if (GrenadeClass == None)
        return None;

    GrenadePickup = class<KFWeaponPickup>(GrenadeClass.default.PickupClass);

    if (GrenadePickup == None)
        return None;

    GrenadeBuyable = new class'GUIBuyable';

    GrenadeBuyable.ItemName = GrenadeClass.default.ItemName;
	GrenadeBuyable.ItemDescription = GrenadeClass.default.Description;
	GrenadeBuyable.ItemImage = GrenadeClass.default.TraderInfoTexture;
    GrenadeBuyable.ItemWeaponClass = GrenadeClass;
    GrenadeBuyable.ItemPickupClass = GrenadePickup;
    GrenadeBuyable.ItemAmmoClass = GrenadeClass.default.FireModeClass[0].default.AmmoClass;
    GrenadeBuyable.ItemCost = 0;
    GrenadeBuyable.ItemAmmoCost = GrenadePickup.default.AmmoCost;
    GrenadeBuyable.ItemWeight = GrenadeClass.default.Weight;
    GrenadeBuyable.ItemPower = GrenadePickup.default.PowerValue;
    GrenadeBuyable.ItemRange = GrenadePickup.default.RangeValue;
    GrenadeBuyable.ItemSpeed = GrenadePickup.default.SpeedValue;
    GrenadeBuyable.bSaleList = false;
    GrenadeBuyable.bSellable = false;

    return GrenadeBuyable;
}

function int FindGrenadeIndex(class<BallisticHandGrenade> GrenadeClass)
{
    local int i;

    for (i = 0; i < GrenadeClasses.Length; i++)
    {
        if (GrenadeClasses[i] == GrenadeClass)
            return i;
    }

    return -1;
}

function UpdateGrenadeSelectionControls()
{
    local BW_GUIBuyWeaponInfoPanel GrenadeInfoPanel;
    local KFGameReplicationInfo KFGRI;
    local bool bIsGrenade;

    if (bGrenadeSelectionConfirmed && PlayerOwner() != None)
    {
        KFGRI = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo);

        if (KFGRI != None && KFGRI.WaveNumber != GrenadeSelectionConfirmedWave)
            bGrenadeSelectionConfirmed = false;
    }

    GrenadeInfoPanel = BW_GUIBuyWeaponInfoPanel(ItemInfo);

    if (GrenadeInfoPanel == None)
        return;

    bIsGrenade = TheBuyable != None
        && class<BallisticHandGrenade>(TheBuyable.ItemWeaponClass) != None;

    GrenadeInfoPanel.SetGrenadeSelectionMode(bIsGrenade);
}

function ConfirmGrenadeSelection()
{
    local BW_KFPawn BWPawn;
    local KFGameReplicationInfo KFGRI;

    if (bGrenadeSelectionConfirmed || PendingGrenadeClass == None)
        return;

    if (PlayerOwner() == None || PlayerOwner().Pawn == None)
        return;

    BWPawn = BW_KFPawn(PlayerOwner().Pawn);

    if (BWPawn == None)
        return;

    BWPawn.ServerSelectGrenadeClass(PendingGrenadeClass);

    KFGRI = KFGameReplicationInfo(PlayerOwner().GameReplicationInfo);

    if (KFGRI != None)
        GrenadeSelectionConfirmedWave = KFGRI.WaveNumber;

    bGrenadeSelectionConfirmed = true;

    UpdateGrenadeSelectionControls();
}

function OnAnychange()
{
    Super.OnAnychange();
    UpdateGrenadeSelectionControls();
}

function UpdatePanel()
{
    Super.UpdatePanel();
    UpdateGrenadeSelectionControls();
}

function class<BallisticHandGrenade> GetCurrentGrenadeClass()
{
    local Inventory Inv;

    if (PlayerOwner() == None || PlayerOwner().Pawn == None)
        return None;

    for (Inv = PlayerOwner().Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        if (BallisticHandGrenade(Inv) != None)
            return class<BallisticHandGrenade>(Inv.Class);
    }

    return None;
}

event Opened(GUIComponent Sender)
{
    Super.Opened(Sender);

    CurrentGrenadeClass = GetCurrentGrenadeClass();
    PendingGrenadeClass = CurrentGrenadeClass;

    PendingGrenadeIndex = FindGrenadeIndex(CurrentGrenadeClass);

    if (PendingGrenadeIndex < 0 && GrenadeClasses.Length > 0)
    {
        PendingGrenadeIndex = 0;
        PendingGrenadeClass = GrenadeClasses[0];
    }
}

function CycleGrenadeSelection(int Direction)
{
    local BW_GUIBuyWeaponInfoPanel GrenadeInfoPanel;

    GrenadeInfoPanel = BW_GUIBuyWeaponInfoPanel(ItemInfo);

    if (GrenadeInfoPanel == None || GrenadeClasses.Length == 0)
        return;
		
	if (bGrenadeSelectionConfirmed)
		return;
		
    if (Direction < 0)
    {
        PendingGrenadeIndex--;

        if (PendingGrenadeIndex < 0)
            PendingGrenadeIndex = GrenadeClasses.Length - 1;
    }
    else
    {
        PendingGrenadeIndex++;

        if (PendingGrenadeIndex >= GrenadeClasses.Length)
            PendingGrenadeIndex = 0;
    }

    PendingGrenadeClass = GrenadeClasses[PendingGrenadeIndex];
	
	GrenadeInfoPanel.Display(BuildGrenadeBuyable(PendingGrenadeClass));

    // The pending class changes here.
    // The actual inventory grenade remains unchanged.
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local BW_GUIBuyWeaponInfoPanel GrenadeInfoPanel;

    Super.InitComponent(MyController, MyOwner);

    GrenadeInfoPanel = BW_GUIBuyWeaponInfoPanel(ItemInfo);

    if (GrenadeInfoPanel != None)
        GrenadeInfoPanel.BuyMenuTab = Self;
}

defaultproperties
{
    Begin Object Class=BW_GUIBuyWeaponInfoPanel Name=ItemInf
        WinTop=0.193730
        WinLeft=0.332571
        WinWidth=0.333947
        WinHeight=0.489407
    End Object
    ItemInfo=ItemInf

    Begin Object class=BW_KFBuyMenuSaleListBox Name=SaleBox
        WinTop=0.064312
        WinLeft=0.672632
        WinWidth=0.325857
        WinHeight=0.674039
    End Object
    SaleSelect=SaleBox

    Begin Object class=BW_KFBuyMenuInvListBox Name=InventoryBox
        WinTop=0.070841
        WinLeft=0.000108
        WinWidth=0.328204
        WinHeight=0.521856
    End Object
    InvSelect=InventoryBox
	
	GrenadeClasses(0)=Class'BW_WD000_KF.Utility_NRP57Grenade_Main'
    GrenadeClasses(1)=Class'BW_WD000_KF.Utility_FP7Grenade_Main'
}