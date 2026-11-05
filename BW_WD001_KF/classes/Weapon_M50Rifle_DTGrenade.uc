//=============================================================================
// DTM50Grenade
//
// Direct impact damage type for the M50 rifle grenade.
//=============================================================================

class Weapon_M50Rifle_DTGrenade extends DT_BWExplode;

defaultproperties
{
    DeathStrings(0)="%o was tagged by %k's M900 grenade."
    DeathStrings(1)="%o played with %k's live M900 grenade."

    SimpleKillString="M50 Grenade"

    InvasionDamageScaling=2.000000
    DamageIdent="Grenade"

    WeaponClass=Class'BW_WD001_KF.Weapon_M50Rifle_Main'

    DeathString="%o was tagged by %k's M900 grenade."
    FemaleSuicide="%o tagged herself with her own grenade."
    MaleSuicide="%o tagged himself with his own grenade."

    bDelayedDamage=True
}