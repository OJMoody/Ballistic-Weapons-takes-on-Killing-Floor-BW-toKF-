class BW_KFBuyMenuSaleList extends KFBuyMenuSaleList;

function int PopulateBuyables()
{
	local int i;
	local int CurrentIndex;

	CurrentIndex = Super.PopulateBuyables();

	//=========================================================================
	// WILSON-41
	//=========================================================================

	for (i = ForSaleBuyables.Length - 1; i >= 0; i--)
	{
		// Dual Wilson owned: remove the single Wilson from the trader.
		if (ForSaleBuyables[i].ItemPickupClass == class'Weapon_Wilson41_Pickup')
		{
			if (IsInInventory(class'Weapon_Wilson41Dual_Pickup'))
			{
				ForSaleBuyables.Remove(i, 1);
				continue;
			}
		}

		// Single Wilson owned: dual Wilson becomes a half-price upgrade.
		if (ForSaleBuyables[i].ItemPickupClass == class'Weapon_Wilson41Dual_Pickup')
		{
			if (IsInInventory(class'Weapon_Wilson41_Pickup'))
			{
				ForSaleBuyables[i].ItemCost = ForSaleBuyables[i].ItemCost / 2;
				ForSaleBuyables[i].ItemWeight = ForSaleBuyables[i].ItemWeight / 2;
			}
		}
	}

	//=========================================================================
	// M806A2
	//=========================================================================

	for (i = ForSaleBuyables.Length - 1; i >= 0; i--)
	{
		// Dual M806 owned: remove the single M806 from the trader.
		if (ForSaleBuyables[i].ItemPickupClass == class'Weapon_M806Pistol_Pickup')
		{
			if (IsInInventory(class'Weapon_M806DualPistol_Pickup'))
			{
				ForSaleBuyables.Remove(i, 1);
				continue;
			}
		}

		// Single M806 owned: dual M806 becomes a half-price upgrade.
		if (ForSaleBuyables[i].ItemPickupClass == class'Weapon_M806DualPistol_Pickup')
		{
			if (IsInInventory(class'Weapon_M806Pistol_Pickup'))
			{
				ForSaleBuyables[i].ItemCost = ForSaleBuyables[i].ItemCost / 2;
				ForSaleBuyables[i].ItemWeight = ForSaleBuyables[i].ItemWeight / 2;
			}
		}
	}

	return ForSaleBuyables.Length;
}

defaultproperties
{
}