class BW_HUD extends HUDKillingFloor;

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

defaultproperties
{
}