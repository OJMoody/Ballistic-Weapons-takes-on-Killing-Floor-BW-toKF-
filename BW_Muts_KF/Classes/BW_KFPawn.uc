class BW_KFPawn extends KFHumanPawn;

//=============================================================================
// SERVER BUY WEAPON
//=============================================================================

function ServerBuyWeapon( Class<Weapon> WClass, float ItemWeight )
{
	local Inventory I, J;
	local float Price;
	local bool bIsDualWeapon, bHasDual9mms, bHasDualHCs, bHasDualRevolvers;

	if ( !CanBuyNow() || Class<KFWeapon>(WClass) == none || Class<KFWeaponPickup>(WClass.Default.PickupClass) == none )
	{
		return;
	}

	if ( Class<KFWeapon>(WClass).Default.AppID > 0 && Class<KFWeapon>(WClass).Default.UnlockedByAchievement != -1 )
	{
		if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) == none ||
			(!KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).PlayerOwnsWeaponDLC(Class<KFWeapon>(WClass).Default.AppID) &&
			KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).Achievements[Class<KFWeapon>(WClass).Default.UnlockedByAchievement].bCompleted != 1) )
		{
			return;
		}
	}
	else if ( Class<KFWeapon>(WClass).Default.AppID > 0 )
	{
		if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) == none ||
			!KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).PlayerOwnsWeaponDLC(Class<KFWeapon>(WClass).Default.AppID) )
		{
			return;
		}
	}
	else if ( Class<KFWeapon>(WClass).Default.UnlockedByAchievement != -1 )
	{
		if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) == none ||
			KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).Achievements[Class<KFWeapon>(WClass).Default.UnlockedByAchievement].bCompleted != 1 )
		{
			return;
		}
	}

	Price = class<KFWeaponPickup>(WClass.Default.PickupClass).Default.Cost;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
	}

	for ( I = Inventory; I != None; I = I.Inventory )
	{
		if ( I.Class == WClass )
		{
			return;
		}

		//=========================================================================
		// WILSON-41 SINGLE / DUAL EXCLUSION
		//=========================================================================

		if ( WClass == class'Weapon_Wilson41_Main' && I.Class == class'Weapon_Wilson41Dual_Main' )
		{
			return;
		}

		if ( I.Class == class'Dualies' )
		{
			bHasDual9mms = true;
		}
		else if ( I.Class == class'DualDeagle' || I.Class == class'GoldenDualDeagle' )
		{
			bHasDualHCs = true;
		}
		else if ( I.Class == class'Dual44Magnum' )
		{
			bHasDualRevolvers = true;
		}
	}

	if ( WClass == class'DualDeagle' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.Class == class'Deagle' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualHCs = true;
	}

	if ( WClass == class'GoldenDualDeagle' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.Class == class'GoldenDeagle' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualHCs = true;
	}

	if ( WClass == class'Dual44Magnum' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.Class == class'Magnum44Pistol' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
		bHasDualRevolvers = true;
	}

	if ( WClass == class'DualMK23Pistol' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.Class == class'MK23Pistol' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
	}

	if ( WClass == class'DualFlareRevolver' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.Class == class'FlareRevolver' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
	}

	//=========================================================================
	// WILSON-41 DUAL
	//=========================================================================

	if ( WClass == class'Weapon_Wilson41Dual_Main' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.Class == class'Weapon_Wilson41_Main' )
			{
				Price = Price / 2;
				break;
			}
		}

		bIsDualWeapon = true;
	}

	bIsDualWeapon = bIsDualWeapon || WClass == class'Dualies';

	if ( !CanCarry(ItemWeight) )
	{
		return;
	}

	if ( PlayerReplicationInfo.Score < Price )
	{
		return;
	}

	I = Spawn(WClass);

	if ( I != none )
	{
		if ( KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponSpawned(I);
		}

		KFWeapon(I).UpdateMagCapacity(PlayerReplicationInfo);
		KFWeapon(I).FillToInitialAmmo();
		KFWeapon(I).SellValue = Price * 0.75;
		I.GiveTo(self);
		PlayerReplicationInfo.Score -= Price;

		if ( bIsDualWeapon )
		{
			if ( KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements) != none )
			{
				KFSteamStatsAndAchievements(PlayerReplicationInfo.SteamStatsAndAchievements).OnDualsAddedToInventory(bHasDual9mms, bHasDualHCs, bHasDualRevolvers);
			}
		}

		ClientForceChangeWeapon(I);
	}

	SetTraderUpdate();
}

//=============================================================================
// SERVER SELL WEAPON
//=============================================================================

function ServerSellWeapon( Class<Weapon> WClass )
{
	local Inventory I;
	local Single NewSingle;
	local Deagle NewDeagle;
	local Magnum44Pistol New44Magnum;
	local MK23Pistol NewMK23;
	local FlareRevolver NewFlare;
	local Weapon_M806Pistol_Main NewM806;
	local Weapon_Wilson41_Main NewWilson41;
	local int NewM806Ammo;
	local int NewM806MagAmmo;
	local int NewWilsonAmmo;
	local int NewWilsonAltAmmo;
	local int NewWilsonMagAmmo;
	local float Price;

	Log("BW_KFPawn ServerSellWeapon: WClass="$WClass);

	if ( !CanBuyNow() || Class<KFWeapon>(WClass) == none || Class<KFWeaponPickup>(WClass.Default.PickupClass) == none )
	{
		Log("BW_KFPawn ServerSellWeapon: Initial validation FAILED");
		SetTraderUpdate();
		Return;
	}

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( I.Class == WClass )
		{
			Log("BW_KFPawn ServerSellWeapon: Found inventory class "$I.Class);
			Log("BW_KFPawn ServerSellWeapon: Inventory object "$I);

			if ( KFWeapon(I) != none && KFWeapon(I).SellValue != -1 )
			{
				Price = KFWeapon(I).SellValue;
			}
			else
			{
				Price = int(class<KFWeaponPickup>(WClass.default.PickupClass).default.Cost * 0.75);

				if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
				{
					Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
				}
			}

			//=========================================================================
			// VANILLA DUALIES
			//=========================================================================

			if ( Dualies(I) != none && DualDeagle(I) == none && Dual44Magnum(I) == none
				&& DualMK23Pistol(I) == none && DualFlareRevolver(I) == none )
			{
				NewSingle = Spawn(class'Single');

				if ( NewSingle != none )
					NewSingle.GiveTo(self);
			}

			if ( DualDeagle(I) != none )
			{
				if ( GoldenDualDeagle(I) != none )
					NewDeagle = Spawn(class'GoldenDeagle');
				else
					NewDeagle = Spawn(class'Deagle');

				NewDeagle.GiveTo(self);
				Price = Price / 2;
				NewDeagle.SellValue = Price;
			}

			if ( Dual44Magnum(I) != none )
			{
				New44Magnum = Spawn(class'Magnum44Pistol');
				New44Magnum.GiveTo(self);
				Price = Price / 2;
				New44Magnum.SellValue = Price;
			}

			if ( DualMK23Pistol(I) != none )
			{
				NewMK23 = Spawn(class'MK23Pistol');
				NewMK23.GiveTo(self);
				Price = Price / 2;
				NewMK23.SellValue = Price;
			}

			if ( DualFlareRevolver(I) != none )
			{
				NewFlare = Spawn(class'FlareRevolver');
				NewFlare.GiveTo(self);
				Price = Price / 2;
				NewFlare.SellValue = Price;
			}

			//=========================================================================
			// M806 DUAL
			//=========================================================================

			if ( Weapon_M806DualPistol_Main(I) != none )
			{
				Log("BW_KFPawn ServerSellWeapon: M806 DUAL BLOCK ENTERED");

				NewM806Ammo = Weapon_M806DualPistol_Main(I).AmmoAmount(0) / 2;
				NewM806MagAmmo = Weapon_M806DualPistol_Main(I).MagAmmoRemaining / 2;

				Price = Price / 2;

				Log("BW_KFPawn ServerSellWeapon: M806 Ammo="$NewM806Ammo);
				Log("BW_KFPawn ServerSellWeapon: M806 MagAmmo="$NewM806MagAmmo);
				Log("BW_KFPawn ServerSellWeapon: M806 Sale Price="$Price);

				if ( I == Weapon || I == PendingWeapon )
					ClientCurrentWeaponSold();

				PlayerReplicationInfo.Score += Price;

				I.Destroyed();
				I.Destroy();

				NewM806 = Spawn(class'Weapon_M806Pistol_Main');

				Log("BW_KFPawn ServerSellWeapon: Spawned M806 single = "$NewM806);

				if ( NewM806 != none )
				{
					NewM806.GiveTo(self);

					Log("BW_KFPawn ServerSellWeapon: M806 GiveTo complete");

					NewM806.AddAmmo(NewM806Ammo - NewM806.AmmoAmount(0), 0);
					NewM806.MagAmmoRemaining = NewM806MagAmmo;
					NewM806.SellValue = Price;

					Log("BW_KFPawn ServerSellWeapon: M806 single configured");
				}

				SetTraderUpdate();

				if ( KFGameType(Level.Game) != none )
					KFGameType(Level.Game).WeaponDestroyed(WClass);

				return;
			}

			//=========================================================================
			// WILSON-41 DUAL
			//=========================================================================

			if ( Weapon_Wilson41Dual_Main(I) != none )
			{
				Log("BW_KFPawn ServerSellWeapon: WILSON DUAL BLOCK ENTERED");

				NewWilsonAmmo = Weapon_Wilson41Dual_Main(I).AmmoAmount(0) / 2;
				NewWilsonAltAmmo = Weapon_Wilson41Dual_Main(I).AmmoAmount(1) / 2;
				NewWilsonMagAmmo = Weapon_Wilson41Dual_Main(I).MagAmmoRemaining / 2;

				Price = Price / 2;

				Log("BW_KFPawn ServerSellWeapon: Wilson Ammo="$NewWilsonAmmo);
				Log("BW_KFPawn ServerSellWeapon: Wilson AltAmmo="$NewWilsonAltAmmo);
				Log("BW_KFPawn ServerSellWeapon: Wilson MagAmmo="$NewWilsonMagAmmo);
				Log("BW_KFPawn ServerSellWeapon: Wilson Sale Price="$Price);

				if ( I == Weapon || I == PendingWeapon )
					ClientCurrentWeaponSold();

				PlayerReplicationInfo.Score += Price;

				I.Destroyed();
				I.Destroy();

				NewWilson41 = Spawn(class'Weapon_Wilson41_Main');

				Log("BW_KFPawn ServerSellWeapon: Spawned Wilson single = "$NewWilson41);

				if ( NewWilson41 != none )
				{
					NewWilson41.GiveTo(self);

					Log("BW_KFPawn ServerSellWeapon: Wilson GiveTo complete");

					NewWilson41.AddAmmo(NewWilsonAmmo - NewWilson41.AmmoAmount(0), 0);
					NewWilson41.AddAmmo(NewWilsonAltAmmo - NewWilson41.AmmoAmount(1), 1);
					NewWilson41.MagAmmoRemaining = NewWilsonMagAmmo;
					NewWilson41.AltAmmoLoaded = 1;
					NewWilson41.SellValue = Price;

					Log("BW_KFPawn ServerSellWeapon: Wilson single configured");
				}

				SetTraderUpdate();

				if ( KFGameType(Level.Game) != none )
					KFGameType(Level.Game).WeaponDestroyed(WClass);

				return;
			}

			//=========================================================================
			// FINISH NORMAL SALE
			//=========================================================================

			if ( I == Weapon || I == PendingWeapon )
				ClientCurrentWeaponSold();

			PlayerReplicationInfo.Score += Price;

			I.Destroyed();
			I.Destroy();

			SetTraderUpdate();

			if ( KFGameType(Level.Game) != none )
			{
				KFGameType(Level.Game).WeaponDestroyed(WClass);
			}

			return;
		}
	}

	Log("BW_KFPawn ServerSellWeapon: No matching inventory weapon found");
}