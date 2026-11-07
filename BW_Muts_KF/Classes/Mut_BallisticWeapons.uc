class Mut_BallisticWeapons extends Mutator
    config(BW_Core_KF);

var() config bool bUseBWHands;
var() config byte CameraPerspective;

struct BWTraderWeapon
{
	var class<KFWeaponPickup> PickupClass;
	var byte TraderList;
};

var array<BWTraderWeapon> BWTraderWeapons;
var() config bool bDisableStandardTraderWeapons;
var array<class<Pickup> > DisabledTraderWeapons;

function ModifyPlayer(Pawn Other)
{
    local BW_KFPlayerController BWPC;
    local Inventory Inv;

    if (BW_KFPawn(Other) != None)
        GiveBWWelder(Other);

    Inv = Other.FindInventoryType(class'Tool_WD200_Main');

    Super.ModifyPlayer(Other);

    Inv = Other.FindInventoryType(class'Tool_WD200_Main');

    BWPC = BW_KFPlayerController(Other.Controller);

    if (BWPC != None)
        BWPC.SetCameraPerspective(CameraPerspective);
}

function string GetInventoryClassOverride(string InventoryClassName)
{
	if (InventoryClassName ~= "KFMod.Syringe")
	{
		return "BW_WD000_KF.Tool_ICIS25_Main";
	}

	if (InventoryClassName ~= "KFMod.Single")
	{
		return "BW_WD001_KF.Weapon_M806Pistol_Main";
	}

	if (InventoryClassName ~= "KFMod.Knife")
	{
		return "BW_WD001_KF.Weapon_A909Blades_Main";
	}

	if (InventoryClassName ~= "KFMod.SinglePickup")
	{
		return "BW_WD001_KF.Weapon_M806Pistol_Pickup";
	}

	return Super.GetInventoryClassOverride(InventoryClassName);
}

function GiveBWWelder(Pawn Other)
{
	local Inventory Inv;

	if (Other == None)
		return;

	Inv = Other.FindInventoryType(class'Tool_WD200_Main');

	if (Inv == None)
	{
		Inv = Spawn(class'Tool_WD200_Main');

		if (Inv != None)
			Inv.GiveTo(Other);
	}
}

function PreBeginPlay()
{
	Super.PreBeginPlay();

	// Random item pickups
	class'KFRandomItemSpawn'.default.PickupClasses[0] = class'BW_WD001_KF.Weapon_M806DualPistol_Pickup';
	class'KFRandomItemSpawn'.default.PickupClasses[1] = class'BW_WD001_KF.Weapon_MRT6Shotgun_Pickup';
	class'KFRandomItemSpawn'.default.PickupClasses[2] = class'BW_WD001_KF.Weapon_M50Rifle_Pickup';
	class'KFRandomItemSpawn'.default.PickupClasses[3] = class'BW_WD001_KF.Weapon_Wilson41_Pickup';
	class'KFRandomItemSpawn'.default.PickupClasses[7] = class'BW_Core_KF.BWArmorPickup';

	// TODO: Replace remaining vanilla random weapon pickups when suitable BW alternatives become available.
	// Index 4: Winchester (Weight 2) class'KFRandomItemSpawn'.default.PickupClasses[4] = class'BW_WD001_KF.Weapon_XK2Submachinegun_Pickup';
	class'KFRandomItemSpawn'.default.PickupClasses[5] = class'BW_WD001_KF.Weapon_BOGPistol_Pickup';
	class'KFRandomItemSpawn'.default.PickupClasses[6] = class'BW_WD002_KF.Weapon_59MachinePistol_Pickup';

	// Player equipment
	class'BW_KFPawn'.default.RequiredEquipment[3] = "BW_WD000_KF.Tool_ICIS25_Main";
	class'BW_KFPawn'.default.RequiredEquipment[4] = "";

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

	if (Other.Class == class'WelderPickup')
	{
		ReplaceWith(Other, "BW_WD000_KF.Tool_WD200_Pickup");
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

	PlayInfo.AddSetting(
		"BW Trader",
		"bDisableStandardTraderWeapons",
		"Disable standard KF trader weapons",
		0,
		0,
		"Check"
	);
	PlayInfo.AddSetting(
		"Camera",
		"CameraPerspective",
		"Camera Perspective",
		0,
		1,
		"Select",
		"0;First Person Only;1;Third Person Only;2;First and Third Person"
);
}

static function string GetDescriptionText(string SettingName)
{
	switch (SettingName)
	{
		case "bUseBWHands":
			return "Use the Ballistic Weapons hand and sleeve system instead of the standard Killing Floor hands.";

		case "bDisableStandardTraderWeapons":
			return "Removes the configured standard Killing Floor weapons from the trader.";
		
		case "CameraPerspective":
			return "Controls which camera perspectives players can use. First Person Only disables third person, Third Person Only forces third person, and First and Third Person allows both.";
	}

	return Super.GetDescriptionText(SettingName);
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    KFGameType(Level.Game).PlayerControllerClass = class'BW_KFPlayerController';

    SetTimer(0.25, true);

    Level.Game.HUDType = "BW_Core_KF.BW_HUD";
}

simulated function Timer()
{
    local KFLevelRules KFLRules;
    local Controller C;

    foreach DynamicActors(class'KFLevelRules', KFLRules)
    {
        if (KFLRules != None)
        {
            SetupBWTrader(KFLRules);

            for (C = Level.ControllerList; C != None; C = C.NextController)
			{
				if (C.IsA('PlayerController'))
				{
					C.PawnClass = class'BW_KFPawn';
				}
			}

            SetTimer(0.0, false);
            return;
        }
    }
}

simulated function bool IsTraderWeaponDisabled(class<Pickup> PickupClass)
{
	local int i;

	if (PickupClass == None)
		return false;

	for (i = 0; i < DisabledTraderWeapons.Length; i++)
	{
		if (DisabledTraderWeapons[i] == PickupClass)
			return true;
	}

	return false;
}

simulated function RemoveDisabledTraderWeapons(KFLevelRules KFLRules)
{
	if (!bDisableStandardTraderWeapons || KFLRules == None)
		return;

	RemoveDisabledTraderWeaponsFromList(KFLRules.MediItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.SuppItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.ShrpItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.CommItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.BersItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.FireItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.DemoItemForSale);
	RemoveDisabledTraderWeaponsFromList(KFLRules.NeutItemForSale);
}

simulated function RemoveDisabledTraderWeaponsFromList(out array<class<Pickup> > TraderItems)
{
	local int i;

	for (i = TraderItems.Length - 1; i >= 0; i--)
	{
		if (IsTraderWeaponDisabled(TraderItems[i]))
			TraderItems.Remove(i, 1);
	}
}

simulated function SetupBWTrader(KFLevelRules KFLRules)
{
	local int i;

	if (KFLRules == None)
		return;

	RemoveDisabledTraderWeapons(KFLRules);

	for (i = 0; i < BWTraderWeapons.Length; i++)
		AddBWTraderWeapon(KFLRules, BWTraderWeapons[i].PickupClass, BWTraderWeapons[i].TraderList);

	SortBWTraderLists(KFLRules);
}

simulated function AddBWTraderWeapon(KFLevelRules KFLRules,class<KFWeaponPickup> PickupClass,byte TraderList)
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
	bDisableStandardTraderWeapons=True
	CameraPerspective=2

	// Medic
	DisabledTraderWeapons(0)=Class'KFMod.MP7MPickup'
	DisabledTraderWeapons(1)=Class'KFMod.BlowerThrowerPickup'
	DisabledTraderWeapons(2)=Class'KFMod.MP5MPickup'
	DisabledTraderWeapons(3)=Class'KFMod.CamoMP5MPickup'
	DisabledTraderWeapons(4)=Class'KFMod.M7A3MPickup'
	DisabledTraderWeapons(5)=Class'KFMod.KrissMPickup'
	DisabledTraderWeapons(6)=Class'KFMod.NeonKrissMPickup'

	// Support
	DisabledTraderWeapons(7)=Class'KFMod.ShotgunPickup'
	DisabledTraderWeapons(8)=Class'KFMod.CamoShotgunPickup'
	DisabledTraderWeapons(9)=Class'KFMod.BoomStickPickup'
	DisabledTraderWeapons(10)=Class'KFMod.KSGPickup'
	DisabledTraderWeapons(11)=Class'KFMod.NeonKSGPickup'
	DisabledTraderWeapons(12)=Class'KFMod.NailGunPickup'
	DisabledTraderWeapons(13)=Class'KFMod.SPShotGunPickup'
	DisabledTraderWeapons(14)=Class'KFMod.BenelliPickup'
	DisabledTraderWeapons(15)=Class'KFMod.GoldenBenelliPickup'
	DisabledTraderWeapons(16)=Class'KFMod.AA12Pickup'
	DisabledTraderWeapons(17)=Class'KFMod.GoldenAA12Pickup'

	// Sharpshooter
	DisabledTraderWeapons(18)=Class'KFMod.SinglePickup'
	DisabledTraderWeapons(19)=Class'KFMod.DualiesPickup'
	DisabledTraderWeapons(20)=Class'KFMod.WinchesterPickup'
	DisabledTraderWeapons(21)=Class'KFMod.Magnum44Pickup'
	DisabledTraderWeapons(22)=Class'KFMod.DeaglePickup'
	DisabledTraderWeapons(23)=Class'KFMod.GoldenDeaglePickup'
	DisabledTraderWeapons(24)=Class'KFMod.MK23Pickup'
	DisabledTraderWeapons(25)=Class'KFMod.CrossbowPickup'
	DisabledTraderWeapons(26)=Class'KFMod.Dual44MagnumPickup'
	DisabledTraderWeapons(27)=Class'KFMod.DualMK23Pickup'
	DisabledTraderWeapons(28)=Class'KFMod.DualDeaglePickup'
	DisabledTraderWeapons(29)=Class'KFMod.GoldenDualDeaglePickup'
	DisabledTraderWeapons(30)=Class'KFMod.SPSniperPickup'
	DisabledTraderWeapons(31)=Class'KFMod.M14EBRPickup'
	DisabledTraderWeapons(32)=Class'KFMod.M99Pickup'

	// Commando
	DisabledTraderWeapons(33)=Class'KFMod.BullpupPickup'
	DisabledTraderWeapons(34)=Class'KFMod.ThompsonPickup'
	DisabledTraderWeapons(35)=Class'KFMod.SPThompsonPickup'
	DisabledTraderWeapons(36)=Class'KFMod.ThompsonDrumPickup'
	DisabledTraderWeapons(37)=Class'KFMod.AK47Pickup'
	DisabledTraderWeapons(38)=Class'KFMod.GoldenAK47Pickup'
	DisabledTraderWeapons(39)=Class'KFMod.NeonAK47Pickup'
	DisabledTraderWeapons(40)=Class'KFMod.M4Pickup'
	DisabledTraderWeapons(41)=Class'KFMod.CamoM4Pickup'
	DisabledTraderWeapons(42)=Class'KFMod.MKb42Pickup'
	DisabledTraderWeapons(43)=Class'KFMod.SCARMK17Pickup'
	DisabledTraderWeapons(44)=Class'KFMod.NeonSCARMK17Pickup'
	DisabledTraderWeapons(45)=Class'KFMod.FNFAL_ACOG_Pickup'

	// Berserker
	DisabledTraderWeapons(46)=Class'KFMod.KnifePickup'
	DisabledTraderWeapons(47)=Class'KFMod.MachetePickup'
	DisabledTraderWeapons(48)=Class'KFMod.AxePickup'
	DisabledTraderWeapons(49)=Class'KFMod.KatanaPickup'
	DisabledTraderWeapons(50)=Class'KFMod.GoldenKatanaPickup'
	DisabledTraderWeapons(51)=Class'KFMod.ScythePickup'
	DisabledTraderWeapons(52)=Class'KFMod.ChainsawPickup'
	DisabledTraderWeapons(53)=Class'KFMod.GoldenChainsawPickup'
	DisabledTraderWeapons(54)=Class'KFMod.DwarfAxePickup'
	DisabledTraderWeapons(55)=Class'KFMod.ClaymoreSwordPickup'
	DisabledTraderWeapons(56)=Class'KFMod.CrossbuzzsawPickup'

	// Firebug
	DisabledTraderWeapons(57)=Class'KFMod.MAC10Pickup'
	DisabledTraderWeapons(58)=Class'KFMod.FlareRevolverPickup'
	DisabledTraderWeapons(59)=Class'KFMod.FlameThrowerPickup'
	DisabledTraderWeapons(60)=Class'KFMod.GoldenFTPickup'
	DisabledTraderWeapons(61)=Class'KFMod.DualFlareRevolverPickup'
	DisabledTraderWeapons(62)=Class'KFMod.TrenchgunPickup'
	DisabledTraderWeapons(63)=Class'KFMod.HuskGunPickup'

	// Demolition
	DisabledTraderWeapons(64)=Class'KFMod.M79Pickup'
	DisabledTraderWeapons(65)=Class'KFMod.GoldenM79Pickup'
	DisabledTraderWeapons(66)=Class'KFMod.SPGrenadePickup'
	DisabledTraderWeapons(67)=Class'KFMod.PipeBombPickup'
	DisabledTraderWeapons(68)=Class'KFMod.SealSquealPickup'
	DisabledTraderWeapons(69)=Class'KFMod.SeekerSixPickup'
	DisabledTraderWeapons(70)=Class'KFMod.M4203Pickup'
	DisabledTraderWeapons(71)=Class'KFMod.LAWPickup'
	DisabledTraderWeapons(72)=Class'KFMod.M32Pickup'
	DisabledTraderWeapons(73)=Class'KFMod.CamoM32Pickup'

	// Neutral
	DisabledTraderWeapons(74)=Class'KFMod.ZEDMKIIPickup'
	DisabledTraderWeapons(75)=Class'KFMod.ZEDGunPickup'
	DisabledTraderWeapons(76)=Class'KFMod.Potato'

	BWTraderWeapons(0)=(PickupClass=Class'BW_WD001_KF.Weapon_M806DualPistol_Pickup',TraderList=2)
	BWTraderWeapons(1)=(PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup',TraderList=0)
	BWTraderWeapons(2)=(PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup',TraderList=5)
	BWTraderWeapons(3)=(PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup',TraderList=6)
	BWTraderWeapons(4)=(PickupClass=Class'BW_WD001_KF.Weapon_MRT6Shotgun_Pickup',TraderList=1)
	BWTraderWeapons(5)=(PickupClass=Class'BW_WD001_KF.Weapon_Wilson41_Pickup',TraderList=2)
	BWTraderWeapons(6)=(PickupClass=Class'BW_WD001_KF.Weapon_Wilson41Dual_Pickup',TraderList=2)
	BWTraderWeapons(7)=(PickupClass=Class'BW_WD001_KF.Weapon_M763Shotgun_Pickup',TraderList=1)
	BWTraderWeapons(8)=(PickupClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_Pickup',TraderList=3)
	BWTraderWeapons(9)=(PickupClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_Pickup',TraderList=3)
	BWTraderWeapons(10)=(PickupClass=Class'BW_WD001_KF.Weapon_M50Rifle_Pickup',TraderList=3)
	BWTraderWeapons(11)=(PickupClass=Class'BW_WD002_KF.Weapon_59MachinePistol_Pickup',TraderList=0)
}