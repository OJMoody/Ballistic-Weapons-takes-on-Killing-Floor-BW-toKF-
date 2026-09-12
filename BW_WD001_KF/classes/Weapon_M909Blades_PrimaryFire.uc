class Weapon_M909Blades_PrimaryFire extends BallisticKFMeleeFire;

var() array<name> FireAnims;
var name LastFireAnim;


function PlayFiring()
{
     Super.PlayFiring();
}

simulated event ModeDoFire()
{
    local int AnimToPlay;

    if(FireAnims.length > 0)
    {
        AnimToPlay = rand(FireAnims.length);

        LastFireAnim = FireAnim;
        FireAnim = FireAnims[AnimToPlay];

        if(LastFireAnim == FireAnims[1] && FireAnim == FireAnims[2] ||
			LastFireAnim == FireAnims[2] && FireAnim == FireAnims[1] ||
			LastFireAnim == FireAnims[2] && FireAnim == FireAnims[2])
			FireAnim = FireAnims[0];
    }
	
	Super(KFMeleeFire).ModeDoFire();
}

defaultproperties
{
    FireAnims(0)="fire1"
    FireAnims(1)="fire2"
    FireAnims(2)="fire3"
    FireAnims(3)="fire4"

    DamageMin=19.000000
	DamageMax=19.000000
    WideDamageMinHitAngle=0.75
    //hitDamageClass=Class'KFMod.DamTypeKnife'
    FireRate=0.600000
    BotRefireRate=0.300000
    MeleeHitSounds(0)=Sound'KF_KnifeSnd.Knife_HitFlesh'
    HitEffectClass=class'KnifeHitEffect'
}
