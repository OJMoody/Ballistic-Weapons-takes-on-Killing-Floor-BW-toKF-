class Weapon_EKS43Katana_PrimaryFire extends BallisticMeleeFire;

var() array<name> FireAnims;
var name LastFireAnim;

function PlayFiring()
{
     Super.PlayFiring();
}

simulated function InitEffects()
{
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

    bMeleeStrikeAnimationPlayed = false;

    Super(BallisticMeleeFire).ModeDoFire();
}

defaultproperties
{
    FireSound=SoundGroup'BWKF_EKS43_SN.EKS43.EKS-Slash'
	StereoFireSoundRef="BWKF_EKS43_SN.EKS43.EKS-Slash"
	
	FireAnims(0)="fire1"
    FireAnims(1)="fire2"
    FireAnims(2)="fire3"
    FireAnims(3)="fire4"

	AmmoClass=None
	bHasPrep=False
	bFireOnRelease=False
	bWaitForRelease=False
    DamageMin=30.000000
	DamageMax=30.000000
    FireRate=0.600000
    BotRefireRate=0.300000
    MeleeHitSounds(0)=Sound'KF_KatanaSnd.Katana_HitFlesh'
    MeleeHitEffectClass=class'Weapon_EKS43Katana_HitEffects'
}
