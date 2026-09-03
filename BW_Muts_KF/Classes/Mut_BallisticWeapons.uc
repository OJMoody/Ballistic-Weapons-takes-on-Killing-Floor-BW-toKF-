class Mut_BallisticWeapons extends Mutator;

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
}

simulated function AddBWTraderWeapon(
	KFLevelRules KFLRules,
	class<KFWeaponPickup> PickupClass,
	byte TraderList)
{
	local int i;

	if (KFLRules == None || PickupClass == None)
		return;

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

defaultproperties
{
	GroupName="KF-BW"
	FriendlyName="[BWMod] Ballistic Weapons"
	Description="Ballistic Weapons standard mutator. Replaces the starting 9mm pistol with the M806 Pistol."
	bAddToServerPackages=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	bNetNotify=True

	BWTraderWeapons(0)=(PickupClass=Class'BW_WD001_KF.Weapon_M806Pistol_Pickup',TraderList=2)
}