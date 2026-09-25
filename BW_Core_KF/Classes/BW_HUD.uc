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

    if (PawnOwner != None && PawnOwner.Weapon != None)
        BW = BallisticWeapon(PawnOwner.Weapon);

    if (BW == None)
    {
        Super.DrawHudPassA(C);
        return;
    }

    // Store the original ammo icons.
    OldAmmoIcon = BulletsInClipIcon.WidgetTexture;
    OldReserveAmmoIcon = ClipsIcon.WidgetTexture;
    OldAltAmmoIcon = SecondaryClipsIcon.WidgetTexture;

    // Apply weapon-specific ammo icons.
    if (BW.AmmoIcon != None)
        BulletsInClipIcon.WidgetTexture = BW.AmmoIcon;

    if (BW.ReserveAmmoIcon != None)
        ClipsIcon.WidgetTexture = BW.ReserveAmmoIcon;

    if (BW.AltAmmoIcon != None)
        SecondaryClipsIcon.WidgetTexture = BW.AltAmmoIcon;

    // Normal HUD drawing.
    if (!BW.bShowAltAmmoChamber)
    {
        Super.DrawHudPassA(C);

        // Restore the original ammo icons.
        BulletsInClipIcon.WidgetTexture = OldAmmoIcon;
        ClipsIcon.WidgetTexture = OldReserveAmmoIcon;
        SecondaryClipsIcon.WidgetTexture = OldAltAmmoIcon;

        return;
    }

    // Hide the normal secondary reserve number.
    OldAlpha0 = SecondaryClipsDigits.Tints[0].A;
    OldAlpha1 = SecondaryClipsDigits.Tints[1].A;

    SecondaryClipsDigits.Tints[0].A = 0;
    SecondaryClipsDigits.Tints[1].A = 0;

    Super.DrawHudPassA(C);

    // Restore the original widget.
    SecondaryClipsDigits.Tints[0].A = OldAlpha0;
    SecondaryClipsDigits.Tints[1].A = OldAlpha1;

    // Restore the original ammo icons.
    BulletsInClipIcon.WidgetTexture = OldAmmoIcon;
    ClipsIcon.WidgetTexture = OldReserveAmmoIcon;
    SecondaryClipsIcon.WidgetTexture = OldAltAmmoIcon;

    // Copy the stock secondary ammo widget.
    AltAmmoChamberDigits = SecondaryClipsDigits;

    // Set the chamber value.
    AltAmmoChamberDigits.Value = BW.GetAltAmmoChamber();

    // Move the chamber digit.
    AltAmmoChamberDigits.OffsetX += AltAmmoChamberOffsetX;

    // Draw chamber.
    DrawNumericWidget(C, AltAmmoChamberDigits, DigitsSmall);

    // Copy the stock secondary ammo widget.
	AltAmmoReserveDigits = SecondaryClipsDigits;

	// Move the reserve digit.
	AltAmmoReserveDigits.OffsetX += AltAmmoReserveOffsetX;

	// Draw reserve.
	DrawNumericWidget(C, AltAmmoReserveDigits, DigitsSmall);

    // Set up the slash.
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

    // Draw slash.
    DrawSpriteWidget(C, AltAmmoDivider);
}

defaultproperties
{
    AltAmmoChamberOffsetX=-13
    AltAmmoDividerOffsetX=10
    AltAmmoDividerOffsetY=27
	
	AltAmmoReserveOffsetX=25
}