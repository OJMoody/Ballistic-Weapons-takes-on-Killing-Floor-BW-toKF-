class Mut_BallisticWeapons extends Mutator
    config(BW_Core_KF);

var() config bool bUseBWHands;

struct BWTraderWeapon
{
	var class<KFWeaponPickup> PickupClass;
	var byte TraderList;
};

var array<BWTraderWeapon> BWTraderWeapons;

function string GetInventoryClassOverride(string InventoryClassName)
{
	if (InventoryClassName ~= "KFMod.Single")
	{
		return "BW_WD001_KF.Weapon_M806Pistol_Main";
	}

	return Super.GetInventoryClassOverride(InventoryClassName);
}

function PreBeginPlay()
{
    Super.PreBeginPlay();

    class'KFRandomItemSpawn'.default.PickupClasses[7] = class'BWArmorPickup';
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local BallisticWeapon BW;

    BW = BallisticWeapon(Other);

    if (BW != None)
        BW.BUseBWHands = bUseBWHands;

    if (Other.Class == class'Vest')
    {
        ReplaceWith(Other, "BW_Core_KF.BWArmorPickup");
        return false;
    }

    if (Other.Class == class'KFAmmoPickup')
    {
        ReplaceWith(Other, "BW_Core_KF.BWAmmoPickup");
        return false;
    }

    return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    Super.FillPlayInfo(PlayInfo);

    PlayInfo.AddSetting(
        "BW Hands",
        "bUseBWHands",
        "Use Ballistic Weapons hands",
        0,
        0,
        "Check"
    );
}

static function string GetDescriptionText(string SettingName)
{
    switch (SettingName)
    {
        case "bUseBWHands":
            return "Use the Ballistic Weapons hand and sleeve system instead of the standard Killing Floor hands.";
    }

    return Super.GetDescriptionText(SettingName);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetTimer(0.25, true);

    Level.Game.HUDType = "BW_Core_KF.BW_HUD";
}

simulated function Timer()
{
	local KFLevelRules KFLRules;

	foreach DynamicActors(class'KFLevelRules', KFLRules)
	{
		if (KFLRules != None)
		{
			SetupBWTrader(KFLRules);
			SetTimer(0.0, false);
			return;
		}
	}
}

simulated function SetupBWTrader(KFLevelRules KFLRules)
{
	local int i;

	if (KFLRules == None)
		return;

	for (i = 0; i < BWTraderWeapons.Length; i++)
		AddBWTraderWeapon(KFLRules, BWTraderWeapons[i].PickupClass, BWTraderWeapons[i].TraderList);

	SortBWTraderLists(KFLRules);
}

simulated function AddBWTraderWeapon(KFLevelRules KFLRules,class<KFWeaponPickup> PickupClass,byte TraderList)
{
	local int i;

	if (KFLRules == None || PickupClass == None)
		return;

	Log("BW TRADER: Adding " $ PickupClass $ " to trader list " $ TraderList);

	switch (TraderList)
	{
		case 0:
			for (i = 0; i < KFLRules.MediItemForSale.Length; i++)
				if (KFLRules.MediItemForSale[i] == PickupClass)
					return;

			KFLRules.MediItemForSale[KFLRules.MediItemForSale.Length] = PickupClass;
			break;

		case 1:
			for (i = 0; i < KFLRules.SuppItemForSale.Length; i++)
				if (KFLRules.SuppItemForSale[i] == PickupClass)
					return;

			KFLRules.SuppItemForSale[KFLRules.SuppItemForSale.Length] = PickupClass;
			break;

		case 2:
			for (i = 0; i < KFLRules.ShrpItemForSale.Length; i++)
				if (KFLRules.ShrpItemForSale[i] == PickupClass)
					return;

			KFLRules.ShrpItemForSale[KFLRules.ShrpItemForSale.Length] = PickupClass;

			Log("BW TRADER: Added " $ PickupClass $ " to ShrpItemForSale");
			Log("BW TRADER: ShrpItemForSale Length = " $ KFLRules.ShrpItemForSale.Length);
			break;

		case 3:
			for (i = 0; i < KFLRules.CommItemForSale.Length; i++)
				if (KFLRules.CommItemForSale[i] == PickupClass)
					return;

			KFLRules.CommItemForSale[KFLRules.CommItemForSale.Length] = PickupClass;
			break;

		case 4:
			for (i = 0; i < KFLRules.BersItemForSale.Length; i++)
				if (KFLRules.BersItemForSale[i] == PickupClass)
					return;

			KFLRules.BersItemForSale[KFLRules.BersItemForSale.Length] = PickupClass;
			break;

		case 5:
			for (i = 0; i < KFLRules.FireItemForSale.Length; i++)
				if (KFLRules.FireItemForSale[i] == PickupClass)
					return;

			KFLRules.FireItemForSale[KFLRules.FireItemForSale.Length] = PickupClass;
			break;

		case 6:
			for (i = 0; i < KFLRules.DemoItemForSale.Length; i++)
				if (KFLRules.DemoItemForSale[i] == PickupClass)
					return;

			KFLRules.DemoItemForSale[KFLRules.DemoItemForSale.Length] = PickupClass;
			break;

		case 7:
			for (i = 0; i < KFLRules.NeutItemForSale.Length; i++)
				if (KFLRules.NeutItemForSale[i] == PickupClass)
					return;

			KFLRules.NeutItemForSale[KFLRules.NeutItemForSale.Length] = PickupClass;
			break;
	}
}

simulated function SortBWTraderLists(KFLevelRules KFLRules)
{
	SortTraderList(KFLRules.MediItemForSale);
	SortTraderList(KFLRules.SuppItemForSale);
	SortTraderList(KFLRules.ShrpItemForSale);
	SortTraderList(KFLRules.CommItemForSale);
	SortTraderList(KFLRules.BersItemForSale);
	SortTraderList(KFLRules.FireItemForSale);
	SortTraderList(KFLRules.DemoItemForSale);
	SortTraderList(KFLRules.NeutItemForSale);
}

simulated function SortTraderList(out array<class<Pickup> > TraderItems)
{
	local int i;
	local int j;
	local class<Pickup> SortClass;
	local int SortCost;

	for (i = 1; i < TraderItems.Length; i++)
	{
		SortClass = TraderItems[i];
		SortCost = GetTraderItemCost(SortClass);
		j = i - 1;

		while (j >= 0 && GetTraderItemCost(TraderItems[j]) > SortCost)
		{
			TraderItems[j + 1] = TraderItems[j];
			j--;
		}

		TraderItems[j + 1] = SortClass;
	}
}

simulated function int GetTraderItemCost(class<Pickup> PickupClass)
{
	local class<KFWeaponPickup> WeaponPickupClass;

	if (PickupClass == None)
		return 2147483647;

	WeaponPickupClass = class<KFWeaponPickup>(PickupClass);

	if (WeaponPickupClass == None)
		return 2147483647;

	return WeaponPickupClass.default.Cost;
}

defaultproperties
{
	GroupName="KF-BW"
	FriendlyName="[BWMod] Ballistic Weapons"
	Description="Ballistic Weapons standard mutator. Replaces the starting 9mm pistol with the M806 Pistol."
	bAddToServerPackages=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	bNetNotify=True

	bUseBWHands=True
	
	BWTraderWeapons(0)=(PickupClass=Class'BW_WD001_KF.Weapon_M806DualPistol_Pickup',TraderList=2)
	BWTraderWeapons(1)=(PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup',TraderList=0)
	BWTraderWeapons(2)=(PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup',TraderList=5)
	BWTraderWeapons(3)=(PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup',TraderList=6)
}