// Knife Stab //
class Weapon_M909Blades_SecondaryFire extends BallisticKFMeleeFire;

defaultproperties
{
    DamageMin=55.000000
	DamageMax=55.000000
    WideDamageMinHitAngle=0.7
    //hitDamageClass=Class'KFMod.DamTypeKnife'
    FireAnim="FireStab"
    FireRate=1.1
    BotRefireRate=1.1
    MeleeHitSounds(0)=Sound'KF_KnifeSnd.Knife_HitFlesh'
    HitEffectClass=class'KnifeHitEffect'
}
