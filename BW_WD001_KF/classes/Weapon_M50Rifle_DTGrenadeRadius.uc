//=============================================================================
// DTM50GrenadeRadius
//
// Radius damage type for the M50 rifle grenade.
//=============================================================================

class Weapon_M50Rifle_DTGrenadeRadius extends DT_BWExplode;

defaultproperties
{
    DeathStrings(0)="%o lost a few teeth to %k's M900 grenade."
    DeathStrings(1)="%k's M900 grenade turned %o into chunky red ash."
    DeathStrings(2)="%o found %k's M900 grenade."

    SimpleKillString="M50 Grenade"

    InvasionDamageScaling=2.000000

    WeaponClass=Class'BW_WD001_KF.Weapon_M50Rifle_Main'

    DeathString="%o lost a few teeth to %k's M900 grenade."
    FemaleSuicide="%o found one of her M900 grenades."
    MaleSuicide="%o found one of his M900 grenades."

    bDelayedDamage=True
}