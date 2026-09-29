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

	if (PawnOwner != None && PawnOwner.Weapon != None)
		BW = BallisticWeapon(PawnOwner.Weapon);

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

defaultproperties
{
    AltAmmoChamberOffsetX=-13
    AltAmmoDividerOffsetX=10
    AltAmmoDividerOffsetY=27
	
	AltAmmoReserveOffsetX=25
}