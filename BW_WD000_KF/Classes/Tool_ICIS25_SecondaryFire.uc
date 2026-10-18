class Tool_ICIS25_SecondaryFire extends BallisticInstantFire;

//=============================================================================
// SELF HEAL
//=============================================================================

function DoFireEffect()
{
    if (Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 &&
        KFPlayerController(Instigator.Controller) != None &&
        KFSteamStatsAndAchievements(KFPlayerController(Instigator.Controller).SteamStatsAndAchievements) != None)
    {
        KFSteamStatsAndAchievements(KFPlayerController(Instigator.Controller).SteamStatsAndAchievements).AddSelfHeal();
    }
}

function NotifyHealStart()
{
    local float HealSum;
    local KFPlayerReplicationInfo KFPRI;

    if (Instigator == None || Weapon == None)
        return;

    if (Instigator.Health >= Instigator.HealthMax)
        return;

    if (Weapon.AmmoAmount(ThisModeNum) < AmmoPerFire)
        return;

    KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

    HealSum = Tool_ICIS25_Main(Weapon).HealBoostAmount;

    if (KFPRI != None && KFPRI.ClientVeteranSkill != None)
        HealSum *= KFPRI.ClientVeteranSkill.Static.GetHealPotency(KFPRI);

    if (!Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire))
        return;

    Instigator.GiveHealth(HealSum, Instigator.HealthMax);
}

//=============================================================================
// FIRING
//=============================================================================

// Do not consume the charge until the animation notify applies the heal.
event ModeDoFire()
{
    Load = 0;
    Super.ModeDoFire();
}

function bool AllowFire()
{
    if (Instigator == None || Weapon == None)
        return false;

    if (Instigator.Health >= Instigator.HealthMax)
        return false;

    return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

//=============================================================================
// FIRING ANIMATION
//=============================================================================

function PlayFiring()
{
    if (Weapon.Mesh != None)
        Weapon.PlayAnim('SelfMedicateFire', FireAnimRate, 0.0);

    Weapon.PlayOwnedSound(FireSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius, Default.FireAnimRate / FireAnimRate, false);
    ClientPlayForceFeedback(FireForce);
    FireCount++;
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    ShakeOffsetMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeOffsetTime=0.0
	ShakeRotMag=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotRate=(X=0.0,Y=0.0,Z=0.0)
	ShakeRotTime=0.0
	RecoilRate=0
	maxVerticalRecoilAngle=0
	maxHorizontalRecoilAngle=0
	ShellEjectClass=None
	ShellEjectBoneName=Root
	
	AmmoPerFire=500
    FireRate=3.600000
    bModeExclusive=True
    FireAnim="SelfMedicateFire"
    TweenTime=0.100000
    TransientSoundVolume=1.800000
	FireSound=SoundGroup'BWKF_ICIS_SN.ICIS.ICIS_Melee'
    FireSoundRef="BWKF_ICIS_SN.ICIS.ICIS_Melee"
    StereoFireSoundRef="BWKF_ICIS_SN.ICIS.ICIS_Melee"
    FlashEmitterClass=None
}