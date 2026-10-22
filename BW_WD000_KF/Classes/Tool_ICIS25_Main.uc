class Tool_ICIS25_Main extends BallisticMeleeWeapon;

#exec OBJ LOAD FILE=BWKF_ICIS_SN.uax

var() float AmmoRegenRate;
var() int HealBoostAmount;
var float RegenTimer;

const MaxAmmoCount = 500;

var localized string SuccessfulHealMessage;

var bool bQuickHealActive;

//=============================================================================
// INITIALIZATION
//=============================================================================

replication
{
    reliable if (Role < ROLE_Authority)
        ServerAttemptHeal;

    reliable if (Role == ROLE_Authority)
        ClientSuccessfulHeal;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        if (Level.Game.NumPlayers == 1)
            HealBoostAmount = 50;
        else
            HealBoostAmount = default.HealBoostAmount;
    }
}

simulated function bool StartFire(int Mode)
{
    local bool Result;
    local int SavedMagAmmo;

    SavedMagAmmo = MagAmmoRemaining;

    if (Mode == 0 && AmmoCharge[0] > 0 && MagAmmoRemaining < 1)
        MagAmmoRemaining = 1;

    Result = Super.StartFire(Mode);

    MagAmmoRemaining = SavedMagAmmo;

    return Result;
}

simulated function bool HackClientStartFire()
{
    if (StartFire(1))
    {
        if (Role < ROLE_Authority)
            ServerStartFire(1);

        FireMode[1].ModeDoFire();
        return true;
    }
    return false;
}

simulated function Timer()
{
	local KFPawn KFP;

	Super.Timer();

	KFP = KFPawn(Instigator);

	if (KFP != None && KFP.bIsQuickHealing > 0 && ClientState == WS_ReadyToFire)
	{
		if (KFP.bIsQuickHealing == 1)
		{
			bQuickHealActive = true;

			if (!HackClientStartFire())
			{
				bQuickHealActive = false;
				KFP.bIsQuickHealing = 2;
				SetTimer(0.2, false);
				return;
			}

			KFP.bIsQuickHealing = 2;
			SetTimer(FireMode[1].FireRate + 0.5, false);
		}
		else
		{
			Instigator.SwitchToLastWeapon();
			KFP.bIsQuickHealing = 0;
			bQuickHealActive = false;
		}
	}
	else if (ClientState == WS_Hidden && KFP != None)
	{
		KFP.bIsQuickHealing = 0;
		bQuickHealActive = false;
	}
}

simulated event AnimEnd(int Channel)
{
	local name Anim;
	local float Frame;
	local float Rate;
	local KFPawn KFP;

	GetAnimParams(Channel, Anim, Frame, Rate);

	Super.AnimEnd(Channel);

	if (Channel != 0 || Anim != 'SelfMedicateFire' || !bQuickHealActive)
		return;

	KFP = KFPawn(Instigator);

	if (KFP != None && KFP.bIsQuickHealing > 0)
	{
		Instigator.SwitchToLastWeapon();
		KFP.bIsQuickHealing = 0;
	}

	bQuickHealActive = false;
}

simulated function Notify_HealStart()
{
    local name Anim;
    local float Frame;
    local float Rate;

    GetAnimParams(0, Anim, Frame, Rate);

    if (Anim != 'FriendlyShankFire' && Anim != 'SelfMedicateFire')
        return;

    if (Role == ROLE_Authority)
    {
        if (Anim == 'FriendlyShankFire')
            Tool_ICIS25_PrimaryFire(FireMode[0]).NotifyHealStart();
        else
            Tool_ICIS25_SecondaryFire(FireMode[1]).NotifyHealStart();
    }

    if (Instigator != None && Instigator.IsLocallyControlled())
        PlayOwnedSound(Sound'BWKF_ICIS_SN.ICIS.ICISHeal', SLOT_Interact, 1.0,, 32);
}

//=============================================================================
// AMMO / CHARGE
//=============================================================================

simulated function MaxOutAmmo()
{
    AmmoCharge[0] = MaxAmmoCount;
}

simulated function SuperMaxOutAmmo()
{
    AmmoCharge[0] = 999;
}

simulated function int MaxAmmo(int Mode)
{
    return MaxAmmoCount;
}

simulated function FillToInitialAmmo()
{
    AmmoCharge[0] = MaxAmmoCount;
}

simulated function int AmmoAmount(int Mode)
{
    return AmmoCharge[0];
}

simulated function bool AmmoMaxed(int Mode)
{
    return AmmoCharge[0] >= MaxAmmoCount;
}

simulated function GetAmmoCount(out float MaxAmmoPrimary, out float CurAmmoPrimary)
{
    MaxAmmoPrimary = MaxAmmoCount;
    CurAmmoPrimary = AmmoCharge[0];
}

simulated function float AmmoStatus(optional int Mode)
{
    return float(AmmoCharge[0]) / float(MaxAmmoCount);
}

simulated function bool ConsumeAmmo(int Mode, float Load, optional bool bAmountNeededIsMax)
{
    if (Load > AmmoCharge[0])
        return false;

    AmmoCharge[0] -= Load;
    return true;
}

function bool AddAmmo(int AmmoToAdd, int Mode)
{
    if (AmmoCharge[0] < MaxAmmoCount)
    {
        AmmoCharge[0] += AmmoToAdd;

        if (AmmoCharge[0] > MaxAmmoCount)
            AmmoCharge[0] = MaxAmmoCount;
    }

    return false;
}

simulated function bool HasAmmo()
{
    return AmmoCharge[0] > 0;
}

simulated function CheckOutOfAmmo()
{
    if (AmmoCharge[0] <= 0)
        OutOfAmmo();
}

simulated function float ChargeBar()
{
    return FClamp(float(AmmoCharge[0]) / float(MaxAmmoCount), 0, 1);
}

//=============================================================================
// CHARGE REGENERATION
//=============================================================================

function ServerAttemptHeal()
{
    Tool_ICIS25_PrimaryFire(FireMode[0]).AttemptHeal();
}

simulated function ClientSuccessfulHeal(string HealedName)
{
    Tool_ICIS25_PrimaryFire(FireMode[0]).SuccessfulHeal();

    if (PlayerController(Instigator.Controller) != None)
        PlayerController(Instigator.Controller).ClientMessage(SuccessfulHealMessage $ HealedName, 'CriticalEvent');
}

simulated function Tick(float DeltaTime)
{
    local KFPlayerReplicationInfo KFPRI;

    Super.Tick(DeltaTime);

    if (Level.NetMode == NM_Client || AmmoCharge[0] >= MaxAmmoCount || RegenTimer >= Level.TimeSeconds)
        return;

    RegenTimer = Level.TimeSeconds + AmmoRegenRate;

    if (Instigator != None)
        KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

    if (KFPRI != None && KFPRI.ClientVeteranSkill != None)
        AmmoCharge[0] += 10 * KFPRI.ClientVeteranSkill.Static.GetSyringeChargeRate(KFPRI);
    else
        AmmoCharge[0] += 10;

    if (AmmoCharge[0] > MaxAmmoCount)
        AmmoCharge[0] = MaxAmmoCount;
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'Tool_ICIS25_PrimaryFire'
    FireModeClass(1)=Class'Tool_ICIS25_SecondaryFire'
    MeleeFireClass=Class'Tool_ICIS25_MeleeFire'
    AttachmentClass=Class'Tool_ICIS25_Attachment'
    PickupClass=Class'BW_WD000_KF.Tool_ICIS25_Pickup'

	Mesh=SkeletalMesh'BWKF_ICIS_A.ICISStim_FP_Mesh'
	PlayerViewPivot=(Yaw=0)
	PlayerViewOffset=(X=30.000000,Z=-10.000000)
	Priority=6
	InventoryGroup=5
	GroupOffset=1
	
	PulloutSound=(Sound=Sound'BWKF_ICIS_SN.ICIS.ICISPullout')
    PutAwaySound=(Sound=Sound'BWKF_ICIS_SN.ICIS.ICISPutaway')
	
	HudImage=Texture'BWKF_ICIS_T.Icons.MedIcon_StimUnselected'
	SelectedHudImage=Texture'BWKF_ICIS_T.Icons.MedIcon_StimSelected'
	
	ItemName="FMD ICIS-25 Stim Pack"
	Description="Chemical Formula KFBR382, serum #25 is one in a long line of exerimental military stimulants, and is one of the more successful prototypes. It is supplied alongside the heavy-duty Intravenous Chemical Injection System for troop use in dangerous situations, and while previous serums were never able to breach the 50% mortality mark, No. 25 is showing serious potential and is being fielded to select testing groups. Studies show that #25 increases aggression, suppresses pain receptors, and allows troops to continue fighting past fatigue points that were previously thought impossible. Unfortunately, some #25-injected troops are already showing signs of severe psychosis and a few others have already died of unforeseen cardiac explosions."
	WeaponModes(2)=(ModeName="Heal",ModeID="WM_SemiAuto")

    AmmoRegenRate=0.300000
    HealBoostAmount=20
    AmmoCharge(0)=500

    bAmmoHUDAsBar=True
    bShowChargingBar=True
    bConsumesPhysicalAmmo=False
	Weight=0.000000
	bKFNeverThrow=True
	
	SuccessfulHealMessage="You healed "
}