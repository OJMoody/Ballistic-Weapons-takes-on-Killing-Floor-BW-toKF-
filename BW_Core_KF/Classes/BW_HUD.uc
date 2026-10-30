class BW_HUD extends HUDKillingFloor;

#exec OBJ LOAD FILE="BWKF_Core_T.utx" PACKAGE="BWKF_Core_T"

var NumericWidget AltAmmoChamberDigits;
var SpriteWidget AltAmmoDivider;

var() int AltAmmoChamberOffsetX;
var() int AltAmmoDividerOffsetX;
var() int AltAmmoDividerOffsetY;

var() int AltAmmoReserveOffsetX;

//=============================================================================
// WEAPON NAME / FIRE MODE
//=============================================================================

simulated function DrawWeaponName(Canvas C)
{
    local BallisticWeapon BW;
    local string CurWeaponName;
    local string ModeText;
    local string Divider;
    local float WeaponXL, WeaponYL;
    local float ModeXL, ModeYL;
    local float DividerXL, DividerYL;
    local float DividerX;
    local float WeaponX;
    local float ModeX;
    local float Y;

    if (PawnOwner == None || PawnOwner.Weapon == None)
        return;

    BW = BallisticWeapon(PawnOwner.Weapon);

    if (BW == None)
    {
        Super.DrawWeaponName(C);
        return;
    }

    CurWeaponName = PawnOwner.Weapon.GetHumanReadableName();
    ModeText = BW.GetCurrentWeaponModeName();
    Divider = "|";

    C.Font = GetFontSizeIndex(C, -1);
    C.SetDrawColor(255, 50, 50, KFHUDAlpha);

    C.StrLen(CurWeaponName, WeaponXL, WeaponYL);
    C.StrLen(ModeText, ModeXL, ModeYL);
    C.StrLen(Divider, DividerXL, DividerYL);

    if (!bLightHud)
        DividerX = C.ClipX * 0.90;
    else
        DividerX = C.ClipX * 0.89;

    WeaponX = DividerX - WeaponXL - (DividerXL * 0.5) - (C.ClipX * 0.005);
    ModeX = DividerX + (DividerXL * 0.5) + (C.ClipX * 0.005);

    if (!bLightHud)
        Y = C.ClipY * 0.90;
    else
        Y = C.ClipY * 0.915;

    C.SetPos(WeaponX, Y);
    C.DrawText(CurWeaponName);

    C.SetPos(DividerX - (DividerXL * 0.5), Y);
    C.DrawText(Divider);

    C.SetPos(ModeX, Y);
    C.DrawText(ModeText);
}

simulated function DrawHudPassA(Canvas C)
{
	local BallisticWeapon BW;
	local NumericWidget AltAmmoReserveDigits;
	local Material OldAmmoIcon;
	local Material OldReserveAmmoIcon;
	local Material OldAltAmmoIcon;
	local byte OldAlpha0;
	local byte OldAlpha1;
	local byte OldClipsBGAlpha0;
	local byte OldClipsBGAlpha1;
	local byte OldClipsIconAlpha0;
	local byte OldClipsIconAlpha1;
	local byte OldClipsDigitsAlpha0;
	local byte OldClipsDigitsAlpha1;
	local byte OldBulletsBGAlpha0;
	local byte OldBulletsBGAlpha1;
	local byte OldBulletsIconAlpha0;
	local byte OldBulletsIconAlpha1;
	local byte OldBulletsDigitsAlpha0;
	local byte OldBulletsDigitsAlpha1;
	local byte OldSecondaryBGAlpha0;
	local byte OldSecondaryBGAlpha1;
	local byte OldSecondaryIconAlpha0;
	local byte OldSecondaryIconAlpha1;
	local byte OldSecondaryDigitsAlpha0;
	local byte OldSecondaryDigitsAlpha1;
	local BallisticHandGrenade Grenade;
	local byte OldGrenadeClipBGAlpha0, OldGrenadeClipBGAlpha1;
	local byte OldGrenadeClipIconAlpha0, OldGrenadeClipIconAlpha1;
	local byte OldGrenadeClipDigitsAlpha0, OldGrenadeClipDigitsAlpha1;
	local byte OldGrenadeReserveBGAlpha0, OldGrenadeReserveBGAlpha1;
	local byte OldGrenadeReserveIconAlpha0, OldGrenadeReserveIconAlpha1;
	local byte OldGrenadeReserveDigitsAlpha0, OldGrenadeReserveDigitsAlpha1;

	Grenade = None;

	if (PawnOwner != None && PawnOwner.Weapon != None)
	{
		BW = BallisticWeapon(PawnOwner.Weapon);
		Grenade = BallisticHandGrenade(PawnOwner.Weapon);
	}
	
	if (Grenade != None)
	{
		OldGrenadeClipBGAlpha0 = BulletsInClipBG.Tints[0].A;
		OldGrenadeClipBGAlpha1 = BulletsInClipBG.Tints[1].A;
		OldGrenadeClipIconAlpha0 = BulletsInClipIcon.Tints[0].A;
		OldGrenadeClipIconAlpha1 = BulletsInClipIcon.Tints[1].A;
		OldGrenadeClipDigitsAlpha0 = BulletsInClipDigits.Tints[0].A;
		OldGrenadeClipDigitsAlpha1 = BulletsInClipDigits.Tints[1].A;

		OldGrenadeReserveBGAlpha0 = ClipsBG.Tints[0].A;
		OldGrenadeReserveBGAlpha1 = ClipsBG.Tints[1].A;
		OldGrenadeReserveIconAlpha0 = ClipsIcon.Tints[0].A;
		OldGrenadeReserveIconAlpha1 = ClipsIcon.Tints[1].A;
		OldGrenadeReserveDigitsAlpha0 = ClipsDigits.Tints[0].A;
		OldGrenadeReserveDigitsAlpha1 = ClipsDigits.Tints[1].A;

		BulletsInClipBG.Tints[0].A = 0;
		BulletsInClipBG.Tints[1].A = 0;
		BulletsInClipIcon.Tints[0].A = 0;
		BulletsInClipIcon.Tints[1].A = 0;
		BulletsInClipDigits.Tints[0].A = 0;
		BulletsInClipDigits.Tints[1].A = 0;

		ClipsBG.Tints[0].A = 0;
		ClipsBG.Tints[1].A = 0;
		ClipsIcon.Tints[0].A = 0;
		ClipsIcon.Tints[1].A = 0;
		ClipsDigits.Tints[0].A = 0;
		ClipsDigits.Tints[1].A = 0;

		Super.DrawHudPassA(C);

		BulletsInClipBG.Tints[0].A = OldGrenadeClipBGAlpha0;
		BulletsInClipBG.Tints[1].A = OldGrenadeClipBGAlpha1;
		BulletsInClipIcon.Tints[0].A = OldGrenadeClipIconAlpha0;
		BulletsInClipIcon.Tints[1].A = OldGrenadeClipIconAlpha1;
		BulletsInClipDigits.Tints[0].A = OldGrenadeClipDigitsAlpha0;
		BulletsInClipDigits.Tints[1].A = OldGrenadeClipDigitsAlpha1;

		ClipsBG.Tints[0].A = OldGrenadeReserveBGAlpha0;
		ClipsBG.Tints[1].A = OldGrenadeReserveBGAlpha1;
		ClipsIcon.Tints[0].A = OldGrenadeReserveIconAlpha0;
		ClipsIcon.Tints[1].A = OldGrenadeReserveIconAlpha1;
		ClipsDigits.Tints[0].A = OldGrenadeReserveDigitsAlpha0;
		ClipsDigits.Tints[1].A = OldGrenadeReserveDigitsAlpha1;

		return;
	}

	if (BW == None)
	{
		Super.DrawHudPassA(C);
		return;
	}

	OldAmmoIcon = BulletsInClipIcon.WidgetTexture;
	OldReserveAmmoIcon = ClipsIcon.WidgetTexture;
	OldAltAmmoIcon = SecondaryClipsIcon.WidgetTexture;

	if (BW.AmmoIcon != None)
		BulletsInClipIcon.WidgetTexture = BW.AmmoIcon;

	if (BW.ReserveAmmoIcon != None)
		ClipsIcon.WidgetTexture = BW.ReserveAmmoIcon;

	if (BW.AltAmmoIcon != None)
		SecondaryClipsIcon.WidgetTexture = BW.AltAmmoIcon;

	if (BW.bAmmoHUDAsBar)
	{
		OldClipsBGAlpha0 = ClipsBG.Tints[0].A;
		OldClipsBGAlpha1 = ClipsBG.Tints[1].A;
		OldClipsIconAlpha0 = ClipsIcon.Tints[0].A;
		OldClipsIconAlpha1 = ClipsIcon.Tints[1].A;
		OldClipsDigitsAlpha0 = ClipsDigits.Tints[0].A;
		OldClipsDigitsAlpha1 = ClipsDigits.Tints[1].A;

		OldBulletsBGAlpha0 = BulletsInClipBG.Tints[0].A;
		OldBulletsBGAlpha1 = BulletsInClipBG.Tints[1].A;
		OldBulletsIconAlpha0 = BulletsInClipIcon.Tints[0].A;
		OldBulletsIconAlpha1 = BulletsInClipIcon.Tints[1].A;
		OldBulletsDigitsAlpha0 = BulletsInClipDigits.Tints[0].A;
		OldBulletsDigitsAlpha1 = BulletsInClipDigits.Tints[1].A;

		OldSecondaryBGAlpha0 = SecondaryClipsBG.Tints[0].A;
		OldSecondaryBGAlpha1 = SecondaryClipsBG.Tints[1].A;
		OldSecondaryIconAlpha0 = SecondaryClipsIcon.Tints[0].A;
		OldSecondaryIconAlpha1 = SecondaryClipsIcon.Tints[1].A;
		OldSecondaryDigitsAlpha0 = SecondaryClipsDigits.Tints[0].A;
		OldSecondaryDigitsAlpha1 = SecondaryClipsDigits.Tints[1].A;

		ClipsBG.Tints[0].A = 0;
		ClipsBG.Tints[1].A = 0;
		ClipsIcon.Tints[0].A = 0;
		ClipsIcon.Tints[1].A = 0;
		ClipsDigits.Tints[0].A = 0;
		ClipsDigits.Tints[1].A = 0;

		BulletsInClipBG.Tints[0].A = 0;
		BulletsInClipBG.Tints[1].A = 0;
		BulletsInClipIcon.Tints[0].A = 0;
		BulletsInClipIcon.Tints[1].A = 0;
		BulletsInClipDigits.Tints[0].A = 0;
		BulletsInClipDigits.Tints[1].A = 0;

		SecondaryClipsBG.Tints[0].A = 0;
		SecondaryClipsBG.Tints[1].A = 0;
		SecondaryClipsIcon.Tints[0].A = 0;
		SecondaryClipsIcon.Tints[1].A = 0;
		SecondaryClipsDigits.Tints[0].A = 0;
		SecondaryClipsDigits.Tints[1].A = 0;

		Super.DrawHudPassA(C);

		ClipsBG.Tints[0].A = OldClipsBGAlpha0;
		ClipsBG.Tints[1].A = OldClipsBGAlpha1;
		ClipsIcon.Tints[0].A = OldClipsIconAlpha0;
		ClipsIcon.Tints[1].A = OldClipsIconAlpha1;
		ClipsDigits.Tints[0].A = OldClipsDigitsAlpha0;
		ClipsDigits.Tints[1].A = OldClipsDigitsAlpha1;

		BulletsInClipBG.Tints[0].A = OldBulletsBGAlpha0;
		BulletsInClipBG.Tints[1].A = OldBulletsBGAlpha1;
		BulletsInClipIcon.Tints[0].A = OldBulletsIconAlpha0;
		BulletsInClipIcon.Tints[1].A = OldBulletsIconAlpha1;
		BulletsInClipDigits.Tints[0].A = OldBulletsDigitsAlpha0;
		BulletsInClipDigits.Tints[1].A = OldBulletsDigitsAlpha1;

		SecondaryClipsBG.Tints[0].A = OldSecondaryBGAlpha0;
		SecondaryClipsBG.Tints[1].A = OldSecondaryBGAlpha1;
		SecondaryClipsIcon.Tints[0].A = OldSecondaryIconAlpha0;
		SecondaryClipsIcon.Tints[1].A = OldSecondaryIconAlpha1;
		SecondaryClipsDigits.Tints[0].A = OldSecondaryDigitsAlpha0;
		SecondaryClipsDigits.Tints[1].A = OldSecondaryDigitsAlpha1;

		if (!bLightHud)
			DrawSpriteWidget(C, WelderBG);

		DrawSpriteWidget(C, WelderIcon);
		DrawNumericWidget(C, WelderDigits, DigitsSmall);

		BulletsInClipIcon.WidgetTexture = OldAmmoIcon;
		ClipsIcon.WidgetTexture = OldReserveAmmoIcon;
		SecondaryClipsIcon.WidgetTexture = OldAltAmmoIcon;

		return;
	}

	if (!BW.bShowAltAmmoChamber)
	{
		Super.DrawHudPassA(C);

		BulletsInClipIcon.WidgetTexture = OldAmmoIcon;
		ClipsIcon.WidgetTexture = OldReserveAmmoIcon;
		SecondaryClipsIcon.WidgetTexture = OldAltAmmoIcon;

		return;
	}

	OldAlpha0 = SecondaryClipsDigits.Tints[0].A;
	OldAlpha1 = SecondaryClipsDigits.Tints[1].A;

	SecondaryClipsDigits.Tints[0].A = 0;
	SecondaryClipsDigits.Tints[1].A = 0;

	Super.DrawHudPassA(C);

	SecondaryClipsDigits.Tints[0].A = OldAlpha0;
	SecondaryClipsDigits.Tints[1].A = OldAlpha1;

	BulletsInClipIcon.WidgetTexture = OldAmmoIcon;
	ClipsIcon.WidgetTexture = OldReserveAmmoIcon;
	SecondaryClipsIcon.WidgetTexture = OldAltAmmoIcon;

	AltAmmoChamberDigits = SecondaryClipsDigits;
	AltAmmoChamberDigits.Value = BW.GetAltAmmoChamber();
	AltAmmoChamberDigits.OffsetX += AltAmmoChamberOffsetX;
	DrawNumericWidget(C, AltAmmoChamberDigits, DigitsSmall);

	AltAmmoReserveDigits = SecondaryClipsDigits;
	AltAmmoReserveDigits.Value = BW.AmmoAmount(1);
	AltAmmoReserveDigits.OffsetX += AltAmmoReserveOffsetX;
	DrawNumericWidget(C, AltAmmoReserveDigits, DigitsSmall);

	AltAmmoDivider.WidgetTexture = Texture'BWKF_Core_T.Icons.HUDBW';
	AltAmmoDivider.RenderStyle = SecondaryClipsDigits.RenderStyle;
	AltAmmoDivider.TextureScale = SecondaryClipsDigits.TextureScale;
	AltAmmoDivider.DrawPivot = DP_MiddleMiddle;
	AltAmmoDivider.PosX = SecondaryClipsDigits.PosX;
	AltAmmoDivider.PosY = SecondaryClipsDigits.PosY;
	AltAmmoDivider.OffsetX = SecondaryClipsDigits.OffsetX + AltAmmoDividerOffsetX;
	AltAmmoDivider.OffsetY = SecondaryClipsDigits.OffsetY + AltAmmoDividerOffsetY;
	AltAmmoDivider.TextureCoords.X1 = 0;
	AltAmmoDivider.TextureCoords.Y1 = 0;
	AltAmmoDivider.TextureCoords.X2 = 64;
	AltAmmoDivider.TextureCoords.Y2 = 64;
	AltAmmoDivider.Tints[0] = SecondaryClipsDigits.Tints[0];
	AltAmmoDivider.Tints[1] = SecondaryClipsDigits.Tints[1];

	DrawSpriteWidget(C, AltAmmoDivider);
}

//=============================================================================
// INVENTORY SELECTION FILTER
//=============================================================================

function bool CanSelectInventoryItem(Inventory Item)
{
    local BallisticHandGrenade Grenade;

    Grenade = BallisticHandGrenade(Item);

    if (Grenade != None && Grenade.bRequireAmmoToSelect && Grenade.AmmoAmount(0) <= 0)
        return false;

    return true;
}

function PrevWeapon()
{
    local Inventory CurInv;
    local InventoryCategory Categorized[5];
    local int i, j;
    local bool bSelectedFound;

    if (PawnOwner != None && PawnOwner.Inventory != None && ShowInventory())
    {
        for (CurInv = PawnOwner.Inventory; CurInv != None; CurInv = CurInv.Inventory)
        {
            if (CurInv.InventoryGroup > 0 && CanSelectInventoryItem(CurInv))
            {
                if (CurInv == SelectedInventory)
                {
                    SelectedInventoryCategory = CurInv.InventoryGroup - 1;
                    SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount;
                    bSelectedFound = true;
                }

                Categorized[CurInv.InventoryGroup - 1].Items[Categorized[CurInv.InventoryGroup - 1].ItemCount++] = CurInv;
            }
        }

        if (!bSelectedFound)
        {
            for (i = 0; i < 5; i++)
            {
                if (Categorized[i].ItemCount > 0)
                {
                    SelectedInventoryCategory = i;
                    SelectedInventoryIndex = 0;
                    SelectedInventory = Categorized[i].Items[0];
                    return;
                }
            }

            return;
        }

        if (SelectedInventoryIndex >= Categorized[SelectedInventoryCategory].ItemCount)
            SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;

        if (SelectedInventoryIndex > 0)
        {
            SelectedInventoryIndex--;
            SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
        }
        else
        {
            for (i = SelectedInventoryCategory - 1; i != SelectedInventoryCategory && j < 10; i--)
            {
                if (i < 0)
                    i = 4;

                if (Categorized[i].ItemCount > 0)
                {
                    SelectedInventoryCategory = i;
                    SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;
                    SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
                    return;
                }

                j++;
            }

            SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;
            if (SelectedInventoryIndex >= 0)
                SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
        }
    }
}

function NextWeapon()
{
    local Inventory CurInv;
    local InventoryCategory Categorized[5];
    local int i, j;
    local bool bSelectedFound;

    if (PawnOwner != None && PawnOwner.Inventory != None && ShowInventory())
    {
        for (CurInv = PawnOwner.Inventory; CurInv != None; CurInv = CurInv.Inventory)
        {
            if (CurInv.InventoryGroup > 0 && CanSelectInventoryItem(CurInv))
            {
                if (CurInv == SelectedInventory)
                {
                    SelectedInventoryCategory = CurInv.InventoryGroup - 1;
                    SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount;
                    bSelectedFound = true;
                }

                Categorized[CurInv.InventoryGroup - 1].Items[Categorized[CurInv.InventoryGroup - 1].ItemCount++] = CurInv;
            }
        }

        if (!bSelectedFound)
        {
            for (i = 0; i < 5; i++)
            {
                if (Categorized[i].ItemCount > 0)
                {
                    SelectedInventoryCategory = i;
                    SelectedInventoryIndex = 0;
                    SelectedInventory = Categorized[i].Items[0];
                    return;
                }
            }

            return;
        }

        if (SelectedInventoryIndex >= Categorized[SelectedInventoryCategory].ItemCount)
            SelectedInventoryIndex = Categorized[SelectedInventoryCategory].ItemCount - 1;

        if (SelectedInventoryIndex < Categorized[SelectedInventoryCategory].ItemCount - 1)
        {
            SelectedInventoryIndex++;
            SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
        }
        else
        {
            for (i = SelectedInventoryCategory + 1; i != SelectedInventoryCategory && j < 10; i++)
            {
                if (i > 4)
                    i = 0;

                if (Categorized[i].ItemCount > 0)
                {
                    SelectedInventoryCategory = i;
                    SelectedInventoryIndex = 0;
                    SelectedInventory = Categorized[SelectedInventoryCategory].Items[SelectedInventoryIndex];
                    return;
                }

                j++;
            }

            SelectedInventoryIndex = 0;
            if (Categorized[SelectedInventoryCategory].ItemCount > 0)
                SelectedInventory = Categorized[SelectedInventoryCategory].Items[0];
        }
    }
}

function SelectWeapon()
{
    local Inventory I;
    local bool bFoundItem;
    local bool bAllowSelect;
    local KFHumanPawn KFHP;

    HideInventory();

    if (PawnOwner == None)
        return;

    KFHP = KFHumanPawn(PawnOwner);

    if (KFHP == None || SelectedInventory == None)
        return;

    for (I = PawnOwner.Inventory; I != None; I = I.Inventory)
    {
        if (I == SelectedInventory)
        {
            bFoundItem = true;
            break;
        }
    }

    if (!bFoundItem || !CanSelectInventoryItem(SelectedInventory))
        return;

    bAllowSelect = KFHP.AllowHoldWeapon(KFWeapon(SelectedInventory));

    if (!bAllowSelect)
        return;

    PawnOwner.PendingWeapon = Weapon(SelectedInventory);

    if (PawnOwner.Weapon != None)
    {
        if (PawnOwner.Weapon != PawnOwner.PendingWeapon)
            PawnOwner.Weapon.PutDown();
    }
    else
        PawnOwner.ChangedWeapon();
}


//=============================================================================
// AMMO DISPLAY
//=============================================================================

simulated function CalculateAmmo()
{
    local KFWeapon KFW;
    local BallisticWeapon BW;

    MaxAmmoPrimary = 1;
    CurAmmoPrimary = 1;

    if (PawnOwner == None || PawnOwner.Weapon == None)
        return;

    KFW = KFWeapon(PawnOwner.Weapon);

    if (KFW == None)
        return;

    BW = BallisticWeapon(PawnOwner.Weapon);

    PawnOwner.Weapon.GetAmmoCount(MaxAmmoPrimary, CurAmmoPrimary);

    if (PawnOwner.Weapon.FireModeClass[1].default.AmmoClass != None)
        CurClipsSecondary = PawnOwner.Weapon.AmmoAmount(1);

    if (KFW.bHoldToReload || (BW != None && BW.bShowAmmoAsRounds))
    {
        CurClipsPrimary = Max(CurAmmoPrimary - KFW.MagAmmoRemaining, 0);
        return;
    }

    CurClipsPrimary = (CurAmmoPrimary - KFW.MagAmmoRemaining) / KFW.MagCapacity;

    if ((CurAmmoPrimary - KFW.MagAmmoRemaining) % KFW.MagCapacity > 0)
        CurClipsPrimary += 1;

    if (CurClipsPrimary < 0)
        CurClipsPrimary = 0;
}

//=============================================================================
// BALLISTIC GRENADE HUD
//=============================================================================

simulated function UpdateHud()
{
    local Inventory Inv;
    local BallisticHandGrenade Grenade;

    Super.UpdateHud();

    if (PawnOwner == None)
    {
        GrenadeDigits.Value = 0;
        return;
    }

    for (Inv = PawnOwner.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        Grenade = BallisticHandGrenade(Inv);

        if (Grenade != None)
            break;
    }

    if (Grenade != None)
        GrenadeDigits.Value = Grenade.AmmoAmount(0);
    else
        GrenadeDigits.Value = 0;
}


defaultproperties
{
    AltAmmoChamberOffsetX=-13
    AltAmmoDividerOffsetX=10
    AltAmmoDividerOffsetY=27
	
	AltAmmoReserveOffsetX=25
}