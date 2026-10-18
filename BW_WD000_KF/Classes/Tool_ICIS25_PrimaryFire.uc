class Tool_ICIS25_PrimaryFire extends BallisticInstantFire;

var float LastHealAttempt;
var float HealAttemptDelay;
var float LastHealMessageTime;
var float HealMessageDelay;
var float InjectDelay;

var localized string NoHealTargetMessage;
var KFHumanPawn CachedHealee;

//=============================================================================
// TARGET SELECTION
//=============================================================================

function KFHumanPawn GetHealee()
{
    local KFHumanPawn KFHP, BestKFHP;
    local vector Dir;
    local float TempDot, BestDot;

    if (Instigator == None)
        return None;

    Dir = vector(Instigator.GetViewRotation());

    foreach Instigator.VisibleCollidingActors(class'KFHumanPawn', KFHP, 80.0)
    {
        if (!KFHP.bCanBeHealed)
            continue;

        if (KFHP.Health < KFHP.HealthMax && KFHP.Health > 0)
        {
            TempDot = Dir dot (KFHP.Location - Instigator.Location);

            if (TempDot > 0.7 && TempDot > BestDot)
            {
                BestKFHP = KFHP;
                BestDot = TempDot;
            }
        }
    }

    return BestKFHP;
}

function bool CanFindHealee()
{
    local KFHumanPawn Healtarget;

    Healtarget = GetHealee();

    if (Healtarget == None)
    {
        if (KFPlayerController(Instigator.Controller) != None)
            KFPlayerController(Instigator.Controller).CheckForHint(53);

        return false;
    }

    if (Healtarget.Health >= Healtarget.HealthMax ||
        Healtarget.Health + Healtarget.healthToGive >= Healtarget.HealthMax)
        return false;

    return true;
}

function bool AllowFire()
{
    return Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire;
}

//=============================================================================
// SERVER HEAL ATTEMPT
//=============================================================================

function AttemptHeal()
{
    local KFHumanPawn Healtarget;
    local string HealeeName;

    if (Instigator == None)
        return;

    CachedHealee = None;

    if (AllowFire())
    {
        Healtarget = GetHealee();

        if (Healtarget != None &&
            Healtarget.Health > 0 &&
            Healtarget.Health < Healtarget.HealthMax &&
            Healtarget.Health + Healtarget.healthToGive < Healtarget.HealthMax)
        {
            CachedHealee = Healtarget;

            if (Healtarget.PlayerReplicationInfo != None &&
                Healtarget.PlayerReplicationInfo.PlayerName != "")
                HealeeName = Healtarget.PlayerReplicationInfo.PlayerName;
            else
                HealeeName = Healtarget.MenuName;

            Tool_ICIS25_Main(Weapon).ClientSuccessfulHeal(HealeeName);
            return;
        }
    }

    if (KFPlayerController(Instigator.Controller) != None &&
        LastHealAttempt + HealAttemptDelay < Level.TimeSeconds)
    {
        KFPlayerController(Instigator.Controller).ClientMessage(NoHealTargetMessage, 'CriticalEvent');
        LastHealAttempt = Level.TimeSeconds;
    }
}

//=============================================================================
// HEAL APPLICATION
//=============================================================================

function NotifyHealStart()
{
    local KFHumanPawn Healed;
    local KFPlayerReplicationInfo PRI;
    local float HealSum;
    local int MedicReward;

    if (Instigator == None || Weapon == None)
        return;

    if (CachedHealee == None)
        return;

    Healed = CachedHealee;

    if (Healed.Health <= 0 || Healed == Instigator)
        return;

    if (Healed.Health >= Healed.HealthMax ||
        Healed.Health + Healed.healthToGive >= Healed.HealthMax)
        return;

    if (Weapon.AmmoAmount(ThisModeNum) < AmmoPerFire)
        return;

    MedicReward = Tool_ICIS25_Main(Weapon).HealBoostAmount;

    PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

    if (PRI != None && PRI.ClientVeteranSkill != None)
        MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);

    if (!Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire))
        return;

    HealSum = MedicReward;
    Healed.GiveHealth(HealSum, Healed.HealthMax);

    if (PRI != None)
    {
        if (MedicReward > 0 &&
            KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != None)
            KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward);

        MedicReward = int((FMin(float(MedicReward), Healed.HealthMax) / Healed.HealthMax) * 60);
        PRI.ReceiveRewardForHealing(MedicReward, Healed);

        if (KFHumanPawn(Instigator) != None)
            KFHumanPawn(Instigator).AlphaAmount = 255;
    }

    if (PlayerController(Instigator.Controller) != None)
        PlayerController(Instigator.Controller).Speech('AUTO', 5, "");

    LastHealMessageTime = Level.TimeSeconds;
    CachedHealee = None;
}


//=============================================================================
// CLIENT / SERVER FIRING
//=============================================================================

event ModeDoFire()
{
    if (Weapon != None && Weapon.Instigator != None &&
        Weapon.Instigator.IsLocallyControlled())
        Tool_ICIS25_Main(Weapon).ServerAttemptHeal();
}

simulated function SuccessfulHeal()
{
    if (Weapon != None && Weapon.Instigator != None &&
        Weapon.Instigator.IsLocallyControlled())
        PlayFiring();
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
	
	AmmoPerFire=250
    InjectDelay=0.360000
    FireRate=2.800000
    HealAttemptDelay=0.500000
    HealMessageDelay=10.000000
    NoHealTargetMessage="You must be near another player to heal them!"
    bWaitForRelease=True
    FireAnim="FriendlyShankFire"
	FireSound=SoundGroup'BWKF_ICIS_SN.ICIS.ICIS_Melee'
	FireSoundRef="BWKF_ICIS_SN.ICIS.ICIS_Melee"
    StereoFireSoundRef="BWKF_ICIS_SN.ICIS.ICIS_Melee"
	FlashEmitterClass=None
}