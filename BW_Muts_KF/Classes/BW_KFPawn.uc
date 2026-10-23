class BW_KFPawn extends KFHumanPawn;

var class<BallisticHandGrenade> DefaultGrenadeClass;
var class<BallisticHandGrenade> PendingGrenadeClass;

replication
{
    reliable if (Role < ROLE_Authority)
        ServerSelectGrenadeClass;
}

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

simulated exec function QuickHeal()
{
	local Tool_ICIS25_Main S;
	local Inventory I;
	local byte C;

	if (Health >= HealthMax)
		return;

	for (I = Inventory; I != None && C++ < 250; I = I.Inventory)
	{
		S = Tool_ICIS25_Main(I);

		if (S != None)
			break;
	}

	if (S == None)
		return;

	if (S.ChargeBar() < 0.95)
		return;

	bIsQuickHealing = 1;

	if (Weapon == None)
	{
		PendingWeapon = S;
		ChangedWeapon();
	}
	else if (Weapon != S)
	{
		PendingWeapon = S;
		Weapon.PutDown();
	}
	else
	{
		bIsQuickHealing = 0;
		S.HackClientStartFire();
	}
}


//=============================================================================
// GRENADE TYPE REPLACEMENT
//=============================================================================

function ServerSelectGrenadeClass(class<BallisticHandGrenade> NewGrenadeClass)
{
    local Inventory Inv;
    local BallisticHandGrenade OldGrenade, NewGrenade;
    local Ammunition OldAmmo, NewAmmo;
    local int SavedAmmo;
    local bool bWasEquipped;

    if (Role != ROLE_Authority || !CanBuyNow() || NewGrenadeClass == None)
        return;

    // Find the existing grenade.
    for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
    {
        OldGrenade = BallisticHandGrenade(Inv);

        if (OldGrenade != None)
            break;
    }

    if (OldGrenade == None || OldGrenade.Class == NewGrenadeClass)
        return;

    OldAmmo = OldGrenade.GetGrenadeAmmo();

    if (OldAmmo == None)
        return;

    SavedAmmo = Min(5, OldAmmo.AmmoAmount);
    bWasEquipped = (Weapon == OldGrenade);

    // Create and initialize the replacement.
    NewGrenade = Spawn(NewGrenadeClass);

    if (NewGrenade == None)
        return;

    NewGrenade.GiveTo(Self);

    if (NewGrenade.Owner != Self)
    {
        NewGrenade.Destroy();
        return;
    }

    NewAmmo = NewGrenade.GetGrenadeAmmo();

    if (NewAmmo == None)
    {
        NewGrenade.Destroy();
        return;
    }

    // Replace the initial ammo amount with the saved amount.
    NewAmmo.AmmoAmount = SavedAmmo;

	// Clear references to the grenade being removed.
	for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Weapon(Inv) != None && Weapon(Inv).OldWeapon == OldGrenade)
			Weapon(Inv).OldWeapon = None;
	}

    // Remove the old grenade through the normal inventory path.
    OldGrenade.Destroy();

    // If the grenade was equipped, force the replacement to be selected.
    if (bWasEquipped && NewAmmo.AmmoAmount > 0)
		ClientForceChangeWeapon(NewGrenade);
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

	if ( !CanBuyNow() || Class<KFWeapon>(WClass) == none || Class<KFWeaponPickup>(WClass.Default.PickupClass) == none )
	{
		SetTraderUpdate();
		Return;
	}

	for ( I = Inventory; I != none; I = I.Inventory )
	{
		if ( I.Class == WClass )
		{
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
				NewM806Ammo = Weapon_M806DualPistol_Main(I).AmmoAmount(0) / 2;
				NewM806MagAmmo = Weapon_M806DualPistol_Main(I).MagAmmoRemaining / 2;

				Price = Price / 2;

				if ( I == Weapon || I == PendingWeapon )
					ClientCurrentWeaponSold();

				PlayerReplicationInfo.Score += Price;

				I.Destroyed();
				I.Destroy();

				NewM806 = Spawn(class'Weapon_M806Pistol_Main');

				if ( NewM806 != none )
				{
					NewM806.GiveTo(self);

					NewM806.AddAmmo(NewM806Ammo - NewM806.AmmoAmount(0), 0);
					NewM806.MagAmmoRemaining = NewM806MagAmmo;
					NewM806.SellValue = Price;
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
				NewWilsonAmmo = Weapon_Wilson41Dual_Main(I).AmmoAmount(0) / 2;
				NewWilsonAltAmmo = Weapon_Wilson41Dual_Main(I).AmmoAmount(1) / 2;
				NewWilsonMagAmmo = Weapon_Wilson41Dual_Main(I).MagAmmoRemaining / 2;

				Price = Price / 2;

				if ( I == Weapon || I == PendingWeapon )
					ClientCurrentWeaponSold();

				PlayerReplicationInfo.Score += Price;

				I.Destroyed();
				I.Destroy();

				NewWilson41 = Spawn(class'Weapon_Wilson41_Main');

				if ( NewWilson41 != none )
				{
					NewWilson41.GiveTo(self);

					NewWilson41.AddAmmo(NewWilsonAmmo - NewWilson41.AmmoAmount(0), 0);
					NewWilson41.AddAmmo(NewWilsonAltAmmo - NewWilson41.AmmoAmount(1), 1);
					NewWilson41.MagAmmoRemaining = NewWilsonMagAmmo;
					NewWilson41.AltAmmoLoaded = 1;
					NewWilson41.SellValue = Price;
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
}

exec function SwitchToLastWeapon()
{
    local BallisticHandGrenade LastGrenade;
    local Inventory Inv;
    local Weapon FallbackWeapon;
    local bool bNeedFallback;

    if (Weapon == None)
        return;

    LastGrenade = BallisticHandGrenade(Weapon.OldWeapon);

    // A missing previous weapon or an empty grenade requires a fallback.
    bNeedFallback = (Weapon.OldWeapon == None);

    if (LastGrenade != None && LastGrenade.bRequireAmmoToSelect && LastGrenade.AmmoAmount(0) <= 0)
        bNeedFallback = true;

    if (!bNeedFallback)
    {
        Super.SwitchToLastWeapon();
        return;
    }

    // Prefer the A909 melee weapon.
    for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
    {
        FallbackWeapon = Weapon(Inv);

        if (FallbackWeapon != None && FallbackWeapon != Weapon
            && FallbackWeapon.Class == class'BW_WD001_KF.Weapon_A909Blades_Main')
            break;

        FallbackWeapon = None;
    }

    // Otherwise, choose another owned non-grenade weapon.
    if (FallbackWeapon == None)
    {
        for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
        {
            FallbackWeapon = Weapon(Inv);

            if (FallbackWeapon != None && FallbackWeapon != Weapon
                && BallisticHandGrenade(FallbackWeapon) == None)
                break;

            FallbackWeapon = None;
        }
    }

    if (FallbackWeapon != None)
    {
        PendingWeapon = FallbackWeapon;
        Weapon.PutDown();
    }
}

function ThrowGrenade()
{
    local Inventory Inv;
    local BallisticHandGrenade Grenade;
    local Weapon PreviousWeapon;

    if (Weapon == None || PendingWeapon != None)
        return;

    // If a grenade is already equipped, toggle it away.
    Grenade = BallisticHandGrenade(Weapon);

    if (Grenade != None)
    {
        // Never interrupt an active grenade throw.
        if (Grenade.bGrenadeCharging || Grenade.bGrenadeThrowPending || Grenade.bGrenadeReleased)
            return;

        // Prefer the weapon previously held before the grenade.
        PreviousWeapon = Grenade.OldWeapon;

        // If no previous weapon was recorded, find another owned weapon.
        if (PreviousWeapon == None || PreviousWeapon == Weapon)
        {
            for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
            {
                PreviousWeapon = Weapon(Inv);

                if (PreviousWeapon != None && PreviousWeapon != Weapon)
                    break;
            }
        }

        if (PreviousWeapon == None || PreviousWeapon == Weapon)
            return;

        PendingWeapon = PreviousWeapon;
        Weapon.PutDown();
        return;
    }

    // Find the player's owned grenade, regardless of its specific class.
    for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
    {
        Grenade = BallisticHandGrenade(Inv);

        if (Grenade != None && Grenade.AmmoAmount(0) > 0)
            break;
    }

    if (Grenade == None)
        return;

    PendingWeapon = Grenade;
    Weapon.PutDown();
}

function AddDefaultInventory()
{
    if (DefaultGrenadeClass != None)
        RequiredEquipment[2] = string(DefaultGrenadeClass);

    Super.AddDefaultInventory();
}

function bool ServerBuyAmmo(Class<Ammunition> AClass, bool bOnlyClip)
{
    local Inventory Inv;
    local BallisticHandGrenade Grenade;
    local Ammunition GrenadeAmmo;
    local class<KFWeaponPickup> GrenadePickupClass;
    local KFPlayerReplicationInfo KFPRI;
    local float UnitCost;
    local int AmmoToBuy;
    local int AmmoMissing;
    local int AffordableAmmo;

    // Find the player's existing ballistic hand grenade.
    if (AClass == class'FragAmmo' || Class<BallisticHandGrenadeAmmo>(AClass) != None)
    {
        for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
        {
            Grenade = BallisticHandGrenade(Inv);

            if (Grenade != None && Grenade.GetGrenadeAmmo() != None)
				break;

            Grenade = None;
        }

        if (Grenade != None)
        {
            if (!CanBuyNow())
            {
                SetTraderUpdate();
                return false;
            }

            GrenadeAmmo = Grenade.GetGrenadeAmmo();
            GrenadePickupClass = Class<KFWeaponPickup>(Grenade.PickupClass);
            KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

            if (GrenadePickupClass == None || KFPRI == None)
            {
                SetTraderUpdate();
                return false;
            }

            // Grenade and Utility capacity is always 5.
			GrenadeAmmo.MaxAmmo = 5;

            AmmoMissing = GrenadeAmmo.MaxAmmo - GrenadeAmmo.AmmoAmount;

            if (AmmoMissing <= 0)
            {
                SetTraderUpdate();
                return false;
            }

            // The shared grenade pickup defines the price per grenade.
            UnitCost = GrenadePickupClass.default.AmmoCost;

            if (KFPRI.ClientVeteranSkill != None)
                UnitCost *= KFPRI.ClientVeteranSkill.static.GetAmmoCostScaling(KFPRI, GrenadePickupClass);

            UnitCost = Max(1.0, float(int(UnitCost)));

            // A single purchase buys one grenade; a refill buys all missing grenades.
            if (bOnlyClip)
                AmmoToBuy = Min(BallisticHandGrenadeAmmo(GrenadeAmmo).AmmoPickupAmount, AmmoMissing);
            else
                AmmoToBuy = AmmoMissing;

            if (PlayerReplicationInfo.Score < UnitCost)
            {
                SetTraderUpdate();
                return false;
            }

            // Allow a partial refill when the player cannot afford the full amount.
            AffordableAmmo = int(PlayerReplicationInfo.Score / UnitCost);
            AmmoToBuy = Min(AmmoToBuy, AffordableAmmo);

            if (AmmoToBuy <= 0)
            {
                SetTraderUpdate();
                return false;
            }

            // Deduct payment and replenish the existing ammo object.
			log("Grenade Purchase: Pickup="$GrenadePickupClass@"AmmoCost="$GrenadePickupClass.default.AmmoCost@"UnitCost="$UnitCost);
			log("Grenade Purchase: AmmoToBuy="$AmmoToBuy@"CashBefore="$PlayerReplicationInfo.Score);

			PlayerReplicationInfo.Score -= float(AmmoToBuy) * UnitCost;

			log("Grenade Purchase: CashAfter="$PlayerReplicationInfo.Score);

			GrenadeAmmo.AddAmmo(AmmoToBuy);

            SetTraderUpdate();

            return true;
        }
    }

    // Preserve the normal KF1 purchase path for every other ammunition type.
    return Super.ServerBuyAmmo(AClass, bOnlyClip);
}


defaultproperties
{
    RequiredEquipment(3)="BW_WD000_KF.Tool_ICIS25_Main"
	DefaultGrenadeClass=class'BW_WD000_KF.Utility_NRP57Grenade_Main'
}