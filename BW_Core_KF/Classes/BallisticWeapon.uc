class BallisticWeapon extends KFWeapon
    abstract
	DependsOn(BUtil)
	HideDropDown
	CacheExempt
	Config(BW_Core_KF);

//=============================================================================
// FIRE MODES
//=============================================================================

struct WeaponModeType
{
	var() string ModeName;
	var() bool bUnavailable;
	var() string ModeID;
	var() float Value;
	var() int RecoilParamsIndex;
	var() int AimParamsIndex;
};

var() array<WeaponModeType> WeaponModes;
var() travel byte CurrentWeaponMode;

var byte PendingMode;

var() bool BUseBWHands;
var() Material BWSleeveTexture;
var() Material InvisibleSleeveTexture;

var() bool bShowAltAmmoChamber;

var() Texture AmmoIcon;
var() Texture ReserveAmmoIcon;
var() Texture AltAmmoIcon;

//=============================================================================
// MELEE
//=============================================================================

enum EMeleeState
{
	MS_None, 				// Default.
	MS_Pending, 			// Melee held while weapon is busy.
	MS_Held,				// Melee held and charging.
	MS_Strike,				// Melee attack is being performed.
	MS_StrikePending 		// Melee held again during a strike.
};

var protected BallisticMeleeFire MeleeFireMode;

var EMeleeState MeleeState;
var float MeleeInterval, MeleeHoldTime;
var float MeleeFatigue;

var() name MeleeFireAnim;
var() name MeleePrepAnim;

var byte MeleeTPAnimState;
var byte MeleeTPAnimCount;
var byte LastMeleeTPAnimCount;

var() class<BallisticMeleeFire> MeleeFireClass;

var byte ActiveMeleeFireMode;


//=============================================================================
// SIGHTS
//=============================================================================

var Actor SightFX;
var() class<Actor> SightFXClass;
var() name SightFXBone;

var Actor LeftSightFX;
var() class<Actor> LeftSightFXClass;
var() name LeftSightFXBone;

var() name SightHipAnim;
var() name SightIronsAnim;


//=============================================================================
// RELOAD
//=============================================================================

var bool bBallisticReload;
var() bool bShovelLoadPrimary;
var() bool bShovelLoadSecondary;

var() bool bShovelLoadEmptyStart;
var() bool bShovelLoadEmptyLoop;
var() bool bShovelLoadEmptyEnd;

var() name ShovelReloadStartAnimation;
var() name ShovelReloadLoopAnimation;
var() name ShovelReloadEndAnimation;

var() name ShovelReloadEmptyStartAnimation;
var() name ShovelReloadEmptyLoopAnimation;
var() name ShovelReloadEmptyEndAnimation;

var bool bShovelReload;
var bool bShovelReloadCancelRequested;
var bool bShovelReloadEndRequested;
var bool bShovelReloadStopRequested;
var bool bShovelReloadEmpty;
var bool bShovelReloadLooping;

var byte ShovelReloadMode;
var bool bPuttingDown;
var bool bReloadCancelRequested;
var bool bReloadResumePending;
var bool bBallisticClipOut;
var bool bBallisticAltReload;
var bool bAltReloadResumePending;

var bool bReloadResumePlaying;

var bool bBallisticReloadClipIn;

var byte BallisticReloadStage;

var int CurrentShovelLoadAmount;
var int AltAmmoLoaded;

var bool bSuppressStartFireReloadInterrupt;

var bool bReloadPending;

//=============================================================================
// Dual Weapons
//=============================================================================

var() name FlashBoneLeft;
var() name FlashBoneRight;
var() name AltFlashBoneRight;
var() name AltFlashBoneLeft;
var() name FireAnimLeft;
var() name FireAnimRight;
var() name SightFireAnimLeft;
var() name SightFireAnimRight;

var() name AltFireAnimLeft;
var() name AltFireAnimRight;
var() name AltSightFireAnimLeft;
var() name AltSightFireAnimRight;

var Actor AltThirdPersonActor;

var() name DualFireLeftBone;
var() name DualFireRightBone;

var bool bDualFireLeftPlaying;
var bool bDualFireRightPlaying;

const DualFireLeftChannel=1;
const DualFireRightChannel=2;


//=============================================================================
// RELOAD ANIMATION
//=============================================================================

var() name WeaponReloadFinishAnimation;
var() name WeaponReloadResumeAnimation;
var() name WeaponReloadResumeAnimation2;

var() name WeaponReloadAltAnimation;
var() name WeaponReloadAltResumeAnimation;

//=============================================================================
// RELOAD NOTIFIER SOUNDS
//=============================================================================

struct SoundInfo
{
    var() sound Sound;
    var() float Volume;
    var() float Radius;
    var() ESoundSlot Slot;
    var() float Pitch;
    var() bool bAtten;
};

var() BUtil.FullSound ClipOutSound;
var() BUtil.FullSound ClipInSound;
var() BUtil.FullSound ClipHitSound;
var() BUtil.FullSound SlideInSound;
var() BUtil.FullSound SlideOutSound;
var() BUtil.FullSound CockSound;

var() BUtil.FullSound ClipOutAltSound;
var() BUtil.FullSound ClipInAltSound;

var() BUtil.FullSound ShovelStartSound;
var() BUtil.FullSound ShovelLoopSound;
var() BUtil.FullSound ShovelEndSound;

var() BUtil.FullSound PutAwaySound;
var() BUtil.FullSound PulloutSound;

//=============================================================================
// SCOPES
//=============================================================================

var() bool bScoped;

var() Material ScopeMaskMaterial;
var() Material ScopeFallbackMaterial;

var() int ScopeLensMaterialID;

var() float ScopePortalFOV;
var() float ScopePortalFOVHigh;

var() float ScopeZoomedDisplayFOV;
var() float ScopeZoomedDisplayFOVHigh;

var() vector ScopeViewOffset;
var() vector ScopeViewOffsetHigh;

var() int ScopeTextureSize;
var() int ScopeTextureSizeHigh;

var ScriptedTexture ScopeScriptedTexture;
var Combiner ScopeScriptedCombiner;
var Shader ScopeScriptedShader;

replication
{
	reliable if (Role < ROLE_Authority)
		ServerMeleeHold, ServerMeleeRelease, ServerMeleeQueue, ServerMeleeQueueCancel, ServerSwitchWeaponMode, ServerClipIn, ServerShovelShellIn;

	reliable if (Role == ROLE_Authority)
		ClientSwitchWeaponMode, MeleeTPAnimState, MeleeTPAnimCount, AltAmmoLoaded;
}

simulated function SetupDualFireAnimationChannels()
{
	if (!bDualWeapon)
		return;

	AnimBlendParams(DualFireLeftChannel, 0.0, 0.0, 0.0, DualFireLeftBone);
	AnimBlendParams(DualFireRightChannel, 0.0, 0.0, 0.0, DualFireRightBone);
}

simulated function PlayDualFireAnimation(bool bLeft)
{
	local name AnimName;
	local BallisticInstantFire BIF;
	local float AnimRate;
	local int Channel;

	if (!bDualWeapon)
		return;

	if (bLeft)
	{
		if (bAimingRifle)
			AnimName = GetDualSightFireAnim(true);
		else
			AnimName = GetDualFireAnim(true);

		Channel = DualFireLeftChannel;
	}
	else
	{
		if (bAimingRifle)
			AnimName = GetDualSightFireAnim(false);
		else
			AnimName = GetDualFireAnim(false);

		Channel = DualFireRightChannel;
	}

	if (AnimName == '' || !HasAnim(AnimName))
		return;

	AnimRate = 1.0;

	if (FireMode[0] != None)
	{
		BIF = BallisticInstantFire(FireMode[0]);

		if (BIF != None)
			AnimRate = BIF.FireAnimRate;
	}

	if (bLeft)
	bDualFireLeftPlaying = true;
	else
		bDualFireRightPlaying = true;

	if (bLeft)
		AnimBlendParams(DualFireLeftChannel, 1.0, 0.0, 0.0, DualFireLeftBone);
	else
		AnimBlendParams(DualFireRightChannel, 1.0, 0.0, 0.0, DualFireRightBone);

	PlayAnim(AnimName, AnimRate, 0.0, Channel);
}

simulated function ResetDualFireAnimationChannels()
{
	bDualFireLeftPlaying = false;
	bDualFireRightPlaying = false;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	SetupDualFireAnimationChannels();

	//=========================================================================
	// FIRE MODES
	//=========================================================================

	if (FireMode[0] != None)
	{
		FireMode[0].Weapon = self;
		FireMode[0].Instigator = Instigator;
	}

	if (FireMode[1] != None)
	{
		FireMode[1].Weapon = self;
		FireMode[1].Instigator = Instigator;
	}

	//=========================================================================
	// MELEE FIRE MODE
	//=========================================================================

	if (MeleeFireClass != None)
	{
		MeleeFireMode = new MeleeFireClass;
		MeleeFireMode.ThisModeNum = 2;
		MeleeFireMode.Weapon = self;
		MeleeFireMode.Instigator = Instigator;
		MeleeFireMode.Level = Level;
		MeleeFireMode.Owner = self;

		MeleeFireMode.FireAnim = MeleeFireAnim;
		MeleeFireMode.PreFireAnim = MeleePrepAnim;
	}
}

simulated event PostNetReceive()
{
    Super.PostNetReceive();

    if (MeleeTPAnimCount != LastMeleeTPAnimCount)
    {
        LastMeleeTPAnimCount = MeleeTPAnimCount;

        if (MeleeTPAnimState == 1)
            PlayThirdPersonMeleePrep();
        else if (MeleeTPAnimState == 2)
            PlayThirdPersonMeleeFire();
    }
}

simulated function name GetDualFireAnim(bool bLeft)
{
	if (bLeft)
		return FireAnimLeft;

	return FireAnimRight;
}

simulated function name GetDualSightFireAnim(bool bLeft)
{
	if (bLeft)
		return SightFireAnimLeft;

	return SightFireAnimRight;
}

simulated function name GetDualAltFireAnim(bool bLeft)
{
    if (bLeft)
        return AltFireAnimLeft;

    return AltFireAnimRight;
}

simulated function name GetDualAltSightFireAnim(bool bLeft)
{
    if (bLeft)
        return AltSightFireAnimLeft;

    return AltSightFireAnimRight;
}

simulated function ZoomIn(bool bAnimateTransition)
{
    if (bReloadResumePlaying || bBallisticAltReload)
    {
        return;
    }

    Super.ZoomIn(bAnimateTransition);
}

//------------------------------------------------------------------------------
// HandleSleeveSwapping() - This function will handle sleeve swapping for
//	weapons depending on which player the person who picked the weapon up is.
//------------------------------------------------------------------------------

simulated function HandleSleeveSwapping()
{
    local XPawn XP;
    local class<KFSpeciesType> KFSpecies;

    if( !Instigator.IsHumanControlled() || !Instigator.IsLocallyControlled() )
        return;

    XP = XPawn(Instigator);

    if( XP == none )
        return;

    Skins[0] = InvisibleSleeveTexture;
    Skins[1] = InvisibleSleeveTexture;

    if( BUseBWHands )
    {
        SleeveNum = 0;
        Skins[0] = BWSleeveTexture;
    }
    else
    {
        SleeveNum = 1;

        KFSpecies = class<KFSpeciesType>(XP.Species);

        if( KFSpecies != none )
            Skins[1] = KFSpecies.default.SleeveTexture;
    }
}

//=============================================================================
// FIRE MODE SWITCHING
//=============================================================================

exec simulated function SwitchWeaponMode(optional byte ModeNum)
{
	if (ModeNum == 0)
		ServerSwitchWeaponMode(255);
	else
		ServerSwitchWeaponMode(ModeNum - 1);
}

simulated function int GetAltAmmoChamber()
{
    return 0;
}

//-----------------------------------------------------------------------------
// SERVER SWITCH WEAPON MODE
//-----------------------------------------------------------------------------

function ServerSwitchWeaponMode(byte NewMode)
{
	local int StartMode;

	if (WeaponModes.Length == 0)
		return;

	if (NewMode == 255)
		NewMode = CurrentWeaponMode + 1;

	StartMode = NewMode;

	while (NewMode != CurrentWeaponMode && (NewMode >= WeaponModes.Length || WeaponModes[NewMode].bUnavailable))
	{
		if (NewMode >= WeaponModes.Length)
			NewMode = 0;
		else
			NewMode++;

		if (NewMode == StartMode)
			return;
	}

	if (NewMode >= WeaponModes.Length)
		NewMode = 0;

	if (!WeaponModes[NewMode].bUnavailable)
	{
		CommonSwitchWeaponMode(NewMode);
		ClientSwitchWeaponMode(CurrentWeaponMode);
		NetUpdateTime = Level.TimeSeconds - 1;
	}
}

simulated function string GetCurrentWeaponModeName()
{
	if (WeaponModes.Length == 0)
		return "";

	if (CurrentWeaponMode >= WeaponModes.Length)
		return "";

	if (WeaponModes[CurrentWeaponMode].bUnavailable)
		return "";

	return WeaponModes[CurrentWeaponMode].ModeName;
}

//-----------------------------------------------------------------------------
// CLIENT SWITCH WEAPON MODE
//-----------------------------------------------------------------------------

simulated function ClientSwitchWeaponMode(byte NewMode)
{
    if (NewMode >= WeaponModes.Length)
        return;

    CurrentWeaponMode = NewMode;

    if (FireMode[0] != None)
    {
        if (BallisticInstantFire(FireMode[0]) != None)
            BallisticInstantFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
        else if (BallisticShotgunFire(FireMode[0]) != None)
            BallisticShotgunFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
    }

    CheckBurstMode();
}

//-----------------------------------------------------------------------------
// COMMON SWITCH WEAPON MODE
//-----------------------------------------------------------------------------

simulated function CommonSwitchWeaponMode(byte NewMode)
{
    local BallisticInstantFire BIF;
    local BallisticShotgunFire BSF;

    CurrentWeaponMode = NewMode;

    if (FireMode[0] != None)
    {
        BIF = BallisticInstantFire(FireMode[0]);
        if (BIF != None)
            BIF.SwitchWeaponMode(CurrentWeaponMode);
        else
        {
            BSF = BallisticShotgunFire(FireMode[0]);
            if (BSF != None)
                BSF.SwitchWeaponMode(CurrentWeaponMode);
        }
    }

    CheckBurstMode();
}

//-----------------------------------------------------------------------------
// FIRE MODE MESSAGE
//-----------------------------------------------------------------------------

simulated function DisplayWeaponMode()
{
	local string ModeText;

	if (WeaponModes.Length == 0)
		return;

	if (CurrentWeaponMode >= WeaponModes.Length)
		return;

	ModeText = WeaponModes[CurrentWeaponMode].ModeName;

	if (ModeText == "")
		return;

	if (PlayerController(Instigator.Controller) != None)
		PlayerController(Instigator.Controller).ClientMessage("Fire Mode: "$ModeText);
}


//-----------------------------------------------------------------------------
// CHECK BURST MODE
//-----------------------------------------------------------------------------

simulated function CheckBurstMode()
{
	local BallisticInstantFire BF;

	if (FireMode[0] == None)
		return;

	BF = BallisticInstantFire(FireMode[0]);

	if (BF == None)
		return;

	if (CurrentWeaponMode >= WeaponModes.Length)
		return;

	BF.SwitchWeaponMode(CurrentWeaponMode);

}


//-----------------------------------------------------------------------------
// MELEE GUN LENGTH
//-----------------------------------------------------------------------------

final simulated function SetMeleeGunLength()
{
	// Reserved for ballistic gun-length handling.
}

final simulated function SetDefaultGunLength()
{
	// Reserved for ballistic gun-length handling.
}

//-----------------------------------------------------------------------------
// MELEE INPUT
//-----------------------------------------------------------------------------

exec simulated function MeleeHold()
{
	MeleeHoldImpl();
}

simulated function MeleeHoldImpl()
{
	if (MeleeFireMode == None)
		return;

	if (IsActionLocked())
		return;

	if (ClientState != WS_ReadyToFire)
		return;

	// Queue another melee prep while the current strike is still active.
	if (MeleeState == MS_Strike)
	{
		MeleeState = MS_StrikePending;
		ServerMeleeQueue();
		return;
	}

	if (MeleeState == MS_StrikePending)
		return;

	/*
		Do not interrupt an active reload.
		Queue the melee until the reload has finished.
	*/
	if (bIsReloading)
	{
		MeleeState = MS_Pending;
		return;
	}

	if (IsFiring())
	{
		MeleeState = MS_Pending;
		return;
	}

	if (bAimingRifle)
		return;

	MeleeState = MS_Held;
	MeleeHoldTime = 0.0;
	MeleeFireMode.HoldTime = 0.0;
	MeleeFireMode.HoldStartTime = Level.TimeSeconds;
	MeleeFireMode.bIsFiring = true;

	PlayThirdPersonMeleePrep();
	MeleeFireMode.PlayMeleeHold();
	SetMeleeGunLength();

	ServerMeleeHold();
}


//-----------------------------------------------------------------------------
// SERVER MELEE HOLD
//-----------------------------------------------------------------------------

function ServerMeleeHold()
{
    if (MeleeFireMode == None)
        return;

    MeleeState = MS_Held;

    MeleeHoldTime = 0.0;
    MeleeFireMode.HoldTime = 0.0;
    MeleeFireMode.HoldStartTime = Level.TimeSeconds;
    MeleeFireMode.Instigator = Instigator;
    MeleeFireMode.bIsFiring = true;

    MeleeTPAnimState = 1;
    MeleeTPAnimCount++;
    NetUpdateTime = Level.TimeSeconds - 1;

    if (!Instigator.IsLocallyControlled())
        PlayThirdPersonMeleePrep();

    MeleeFireMode.PlayPreFire();
    SetMeleeGunLength();
}

//-----------------------------------------------------------------------------
// MELEE RELEASE
//-----------------------------------------------------------------------------

exec simulated function MeleeRelease()
{
	MeleeReleaseImpl();
}


simulated function MeleeReleaseImpl()
{
	if (MeleeFireMode == None)
		return;

	if (ClientState != WS_ReadyToFire)
		return;

	switch (MeleeState)
	{
		case MS_Pending:
			MeleeState = MS_None;
			break;

		case MS_Held:
			MeleeFireMode.bIsFiring = false;

			MeleeState = MS_Strike;

			if (Instigator.IsLocallyControlled())
			{
				PlayThirdPersonMeleeFire();
				MeleeFireMode.PlayFiring();
			}

			ServerMeleeRelease();
			SetDefaultGunLength();
			break;

		case MS_StrikePending:
			MeleeState = MS_Strike;
			ServerMeleeQueueCancel();
			break;

	}
}


//=============================================================================
// SERVER MELEE RELEASE
//=============================================================================

final function ServerMeleeRelease()
{
    MeleeState = MS_Strike;

    if (MeleeFireMode == none)
        return;

    MeleeFireMode.Instigator = Instigator;

    MeleeTPAnimState = 2;
    MeleeTPAnimCount++;
    NetUpdateTime = Level.TimeSeconds - 1;

    if (!Instigator.IsLocallyControlled())
    {
        PlayThirdPersonMeleeFire();
        MeleeFireMode.ServerPlayFiring();
    }

    MeleeFireMode.DoFireEffect();
    SetDefaultGunLength();
}

//=============================================================================
// SERVER MELEE QUEUE
//=============================================================================

final function ServerMeleeQueue()
{
    if (MeleeState == MS_Strike)
        MeleeState = MS_StrikePending;
}


//-----------------------------------------------------------------------------
// SERVER MELEE QUEUE CANCEL
//-----------------------------------------------------------------------------

final function ServerMeleeQueueCancel()
{
    if (MeleeState == MS_StrikePending)
        MeleeState = MS_Strike;
}

//-----------------------------------------------------------------------------
// MELEE STATE QUERY
//-----------------------------------------------------------------------------

simulated final function bool IsHoldingMelee()
{
	return MeleeState == MS_Held || MeleeState == MS_Strike || MeleeState == MS_StrikePending;
}

simulated function bool IsActionLocked()
{
	return bBallisticAltReload;
}


//=============================================================================
// MELEE STRIKE COMPLETE
//=============================================================================

simulated function MeleeStrikeFinished()
{
	if (MeleeState == MS_StrikePending)
	{
		MeleeState = MS_Held;
		MeleeHoldTime = 0.0;
		MeleeFireMode.HoldTime = 0.0;
		MeleeFireMode.HoldStartTime = Level.TimeSeconds;
		MeleeFireMode.bIsFiring = true;

		PlayThirdPersonMeleePrep();
		MeleeFireMode.PlayMeleeHold();

		SetMeleeGunLength();

		ServerMeleeHold();
	}
	else
	{
		MeleeState = MS_None;

		MeleeHoldTime = 0.0;
		MeleeFireMode.HoldTime = 0.0;
		MeleeFireMode.HoldStartTime = 0.0;
		MeleeFireMode.bIsFiring = false;

		SetDefaultGunLength();
	}
}


//=============================================================================
// CHECK PENDING MELEE
//=============================================================================

simulated function CheckPendingMelee()
{
	if (MeleeState != MS_Pending)
		return;

	if (MeleeFireMode == None)
		return;

	if (ClientState != WS_ReadyToFire)
		return;

	if (bIsReloading)
		return;

	if (IsFiring())
		return;

	MeleeState = MS_Held;

	MeleeHoldTime = 0.0;
	MeleeFireMode.HoldTime = 0.0;
	MeleeFireMode.HoldStartTime = Level.TimeSeconds;

	PlayThirdPersonMeleePrep();
	MeleeFireMode.PlayMeleeHold();

	SetMeleeGunLength();

	ServerMeleeHold();
}


//=============================================================================
// RELOAD
//=============================================================================

exec function ReloadMeNow()
{
	if (ClientState == WS_BringUp)
		return;

	if (MeleeState == MS_Held || MeleeState == MS_Pending || MeleeState == MS_Strike || MeleeState == MS_StrikePending)
		return;

	if (IsActionLocked())
		return;

	if (bIsReloading || bBallisticReload || bBallisticAltReload || bBallisticReloadClipIn)
		return;

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	//=========================================================================
	// FULL PRIMARY MAGAZINE
	//=========================================================================
	// A full primary magazine must never enter the normal reload queue.
	// If an alternate reload is available, allow Reload to perform it instead.
	if (MagAmmoRemaining >= MagCapacity)
	{
		bReloadPending = false;

		if (!AllowAltReload())
			return;
	}

	//=========================================================================
	// PRIMARY AMMO CHECK
	//=========================================================================
	if (MagAmmoRemaining < MagCapacity && (AmmoAmount(0) - MagAmmoRemaining) <= 0)
	{
		bReloadPending = false;

		if (!AllowAltReload())
			return;
	}

	//=========================================================================
	// WAIT FOR FIRING COOLDOWN
	//=========================================================================
	if (FireMode[0].bIsFiring || FireMode[1].bIsFiring ||
		(FireMode[0].NextFireTime - Level.TimeSeconds) > 0.1)
	{
		bReloadPending = true;
		return;
	}

	bReloadPending = false;

	//=========================================================================
	// PRIMARY RELOAD
	//=========================================================================
	if (MagAmmoRemaining < MagCapacity && AllowReload())
	{
		UpdateMagCapacity(Instigator.PlayerReplicationInfo);

		bReloadCancelRequested = false;
		bReloadResumePending = false;
		bBallisticClipOut = false;
		BallisticReloadStage = 0;
		ResetDualFireAnimationChannels();
		bBallisticReload = true;

		Super.ReloadMeNow();

		if (bShovelLoadPrimary)
		{
			ShovelReloadMode = 0;
			BeginBallisticShovelReload();
		}

		return;
	}

	//=========================================================================
	// ALTERNATE RELOAD
	//=========================================================================
	if (AllowAltReload())
	{
		bReloadCancelRequested = false;
		bReloadResumePending = false;
		bBallisticClipOut = false;
		ResetDualFireAnimationChannels();
		bBallisticAltReload = true;
		BallisticReloadStage = 0;

		PlayAltReloadAnimation();

		return;
	}
}

simulated function bool AllowAltReload()
{
	return AltAmmoLoaded <= 0 && AmmoAmount(1) > 0;
}

exec function ReloadAlt()
{
	if (ClientState == WS_BringUp)
		return;
	
	if (MeleeState == MS_Held || MeleeState == MS_Pending || MeleeState == MS_Strike || MeleeState == MS_StrikePending)
		return;

	if (IsActionLocked())
		return;

	if (bIsReloading || bBallisticReload || bBallisticReloadClipIn)
		return;

	if (!AllowAltReload())
		return;

	bReloadCancelRequested = false;
	bReloadResumePending = false;
	bBallisticClipOut = false;
	ResetDualFireAnimationChannels();
	bBallisticAltReload = true;
	BallisticReloadStage = 0;

	PlayAltReloadAnimation();
}

simulated function PlayAltReloadAnimation()
{
	if (bAimingRifle)
		PerformZoom(false);

	if (WeaponReloadAltAnimation != '' && HasAnim(WeaponReloadAltAnimation))
		PlayAnim(WeaponReloadAltAnimation, ReloadAnimRate, 0.0);
	else
	{
		bBallisticAltReload = false;
		bBallisticReloadClipIn = false;
		BallisticReloadStage = 0;
		PlayIdle();
	}
}

simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds, ReloadMulti;

	if (bHasAimingMode)
	{
		if (bForceLeaveIronsights)
		{
			if (bAimingRifle)
			{
				ZoomOut(true);

				if (Role < ROLE_Authority)
					ServerZoomOut(false);
			}

			bForceLeaveIronsights = false;
		}

		if (ForceZoomOutTime > 0)
		{
			if (bAimingRifle)
			{
				if (Level.TimeSeconds - ForceZoomOutTime > 0)
				{
					ForceZoomOutTime = 0;

					ZoomOut(true);

					if (Role < ROLE_Authority)
						ServerZoomOut(false);
				}
			}
			else
			{
				ForceZoomOutTime = 0;
			}
		}
	}

	if ((Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;

	if (FlashLight != none)
	{
		AdjustLightGraphic();

		if (FlashLight.bHasLight)
		{
			if (Instigator.Health <= 0 || KFHumanPawn(Instigator).TorchBatteryLife <= 0 || Instigator.PendingWeapon != none)
			{
				KFHumanPawn(Instigator).bTorchOn = false;
				ServerSpawnLight();
			}
		}
	}

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	//=========================================================================
	// PENDING RELOAD
	//=========================================================================
	// A shot can finish its firing state before KFWeapon's NextFireTime
	// cooldown has expired. Queue the reload and start it once the normal
	// reload lockout has cleared.

	if (bReloadPending &&
	ClientState != WS_BringUp &&
	!bIsReloading &&
	!bBallisticReload &&
	!bBallisticAltReload &&
	!bBallisticReloadClipIn &&
	!FireMode[0].bIsFiring &&
	!FireMode[1].bIsFiring &&
	(FireMode[0].NextFireTime - Level.TimeSeconds) <= 0.1)
	{
		bReloadPending = false;

		UpdateMagCapacity(Instigator.PlayerReplicationInfo);

		if (MagAmmoRemaining < MagCapacity || AllowAltReload())
		{
			ReloadMeNow();
		}

		return;
	}

	if (!bIsReloading)
	{
		if (!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;

			if (MagAmmoRemaining == 0 || ((LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining) && MagAmmoRemaining < MagCapacity))
				ReloadMeNow();
		}
	}
	else
	{
		if (bBallisticReload)
			return;

		if (bBallisticReloadClipIn)
			return;

		if ((Level.TimeSeconds - ReloadTimer) >= ReloadRate)
		{
			if (AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				if (KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none)
				{
					ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
				}
				else
				{
					ReloadMulti = 1.0;
				}

				if (MagAmmoRemaining < MagCapacity)
				{
					AddReloadedAmmo();

					if (bHoldToReload)
						NumLoadedThisReload++;
				}

				if (MagAmmoRemaining >= MagCapacity || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload)
					ActuallyFinishReloading();
				else if (Level.NetMode != NM_Client)
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if (bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}


//=============================================================================
// SHOVEL RELOAD
//=============================================================================

function BeginBallisticShovelReload()
{
    CurrentShovelLoadAmount = GetShovelLoadAmount();

    bShovelReload = true;
    bShovelReloadCancelRequested = false;
    bShovelReloadEndRequested = false;
    bShovelReloadStopRequested = false;
    bShovelReloadLooping = false;

    if (ShovelReloadMode == 0)
        bShovelReloadEmpty = MagAmmoRemaining <= 0;
    else
        bShovelReloadEmpty = AltAmmoLoaded <= 0;

    Log("SHOVEL BEGIN: Role="$Role);
    Log("  Mag="$MagAmmoRemaining);
    Log("  Reserve="$AmmoAmount(0));
    Log("  Cancel="$bShovelReloadCancelRequested);
    Log("  Stop="$bShovelReloadStopRequested);

    PlayShovelReloadStartAnimation();
}

// Default Ballistic shovel behaviour.
// Individual weapons can override this.

function int GetShovelLoadAmount()
{
    return 1;
}

simulated function name GetShovelReloadStartAnimation()
{
    if (bShovelReloadEmpty && bShovelLoadEmptyStart &&
        ShovelReloadEmptyStartAnimation != '' &&
        HasAnim(ShovelReloadEmptyStartAnimation))
        return ShovelReloadEmptyStartAnimation;

    return ShovelReloadStartAnimation;
}

simulated function name GetShovelReloadLoopAnimation()
{
    if (bShovelReloadEmpty && bShovelLoadEmptyLoop &&
        ShovelReloadEmptyLoopAnimation != '' &&
        HasAnim(ShovelReloadEmptyLoopAnimation))
        return ShovelReloadEmptyLoopAnimation;

    return ShovelReloadLoopAnimation;
}

simulated function name GetShovelReloadEndAnimation()
{
    if (bShovelReloadEmpty && bShovelLoadEmptyEnd &&
        ShovelReloadEmptyEndAnimation != '' &&
        HasAnim(ShovelReloadEmptyEndAnimation))
        return ShovelReloadEmptyEndAnimation;

    return ShovelReloadEndAnimation;
}

simulated function PlayShovelReloadStartAnimation()
{
    local name AnimName;

    AnimName = GetShovelReloadStartAnimation();

    if (AnimName != '' && HasAnim(AnimName))
    {
        PlayAnim(AnimName, ReloadAnimRate, 0.0);
        return;
    }

    PlayIdle();
}

simulated function PlayShovelReloadLoopAnimation()
{
    local name AnimName;

    AnimName = GetShovelReloadLoopAnimation();

    if (AnimName != '' && HasAnim(AnimName))
    {
        bShovelReloadLooping = true;
        PlayAnim(AnimName, ReloadAnimRate, 0.0);
        return;
    }

    PlayIdle();
}

simulated function PlayShovelReloadEndAnimation()
{
    local name AnimName;

    AnimName = GetShovelReloadEndAnimation();

    if (AnimName != '' && HasAnim(AnimName))
    {
        PlayAnim(AnimName, ReloadAnimRate, 0.0);
        return;
    }

    PlayIdle();
}


//=============================================================================
// RELOAD CANCELLATION
//=============================================================================

simulated function bool InterruptReload()
{
	if (bSuppressStartFireReloadInterrupt)
		return false;

	if (bBallisticAltReload && !bPuttingDown)
		return false;

	if (bShovelReload)
	{
		bShovelReloadCancelRequested = true;
		return true;
	}

	if (bBallisticReload || bBallisticReloadClipIn)
		return false;
		
	if (!bIsReloading && !bBallisticAltReload && BallisticReloadStage == 0)
		return false;

	bReloadCancelRequested = true;
	bBallisticReloadClipIn = false;

	if (bBallisticAltReload)
	{
		bReloadCancelRequested = true;
		bBallisticReloadClipIn = false;
		bIsReloading = false;

		if (BallisticReloadStage == 0)
		{
			bReloadResumePending = true;
			bAltReloadResumePending = true;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayAltReloadResumeAnimation();

			return true;
		}

		log("BW DEBUG >>> SETTING bReloadResumePending TRUE");
		bReloadResumePending = true;
		bReloadCancelRequested = false;

		if (!bPuttingDown)
			PlayAltReloadResumeAnimation();

		return true;
	}

	bIsReloading = false;
	bBallisticReload = false;

	switch (BallisticReloadStage)
	{
		case 0:
			bReloadResumePending = false;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayReloadFinishAnimation();
			break;

		case 1:
			log("BW DEBUG >>> SETTING bReloadResumePending TRUE");
			bReloadResumePending = true;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayReloadResumeAnimation();
			break;

		case 2:
			log("BW DEBUG >>> SETTING bReloadResumePending TRUE");
			bReloadResumePending = true;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayReloadResumeAnimation2();
			break;

		case 3:
			bReloadResumePending = false;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayAnim(SelectAnim, SelectAnimRate, 0.0);
			break;
	}

	return true;
}


//=============================================================================
// RELOAD RESUME
//=============================================================================

simulated function PlayReloadResumeAnimation()
{

    if (WeaponReloadResumeAnimation != '' && HasAnim(WeaponReloadResumeAnimation))
    {
        bReloadResumePlaying = true;
        PlayAnim(WeaponReloadResumeAnimation, 1.0, 0.0);
    }
    else
        PlayIdle();
}

simulated function PlayReloadResumeAnimation2()
{
    if (WeaponReloadResumeAnimation2 != '' && HasAnim(WeaponReloadResumeAnimation2))
    {
        bReloadResumePlaying = true;
        PlayAnim(WeaponReloadResumeAnimation2, 1.0, 0.0);
    }
    else
        PlayIdle();
}

simulated function PlayAltReloadResumeAnimation()
{
	if (WeaponReloadAltResumeAnimation != '' && HasAnim(WeaponReloadAltResumeAnimation))
	{
		bReloadResumePlaying = true;
		PlayAnim(WeaponReloadAltResumeAnimation, 1.0, 0.0);
	}
	else
		PlayIdle();
}

function ServerClipIn()
{
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if (AmmoAmount(0) >= MagCapacity)
        MagAmmoRemaining = MagCapacity;
    else
        MagAmmoRemaining = AmmoAmount(0);

    bBallisticReload = false;
    bReloadEffectDone = false;
    bReloadResumePending = false;
    BallisticReloadStage = 0;
}

//=============================================================================
// RELOAD FINISH
//=============================================================================

simulated function PlayReloadFinishAnimation()
{
	if (WeaponReloadFinishAnimation != '')
		PlayAnim(WeaponReloadFinishAnimation, 1.0, 0.0);
	else
		PlayIdle();
}

simulated function ActuallyFinishReloading()
{
    Super.ActuallyFinishReloading();

    if (FireMode[0] != None && BallisticInstantFire(FireMode[0]) != None)
    {
        BallisticInstantFire(FireMode[0]).ResetBurst();
        BallisticInstantFire(FireMode[0]).ResetDualFire();
    }
}

simulated function bool WasLastDualFireLeft()
{
    if (FireMode[0] == None)
        return false;

    if (BallisticInstantFire(FireMode[0]) == None)
        return false;

    return BallisticInstantFire(FireMode[0]).bLastDualFireLeft;
}

//=============================================================================
// CLIP NOTIFIERS
//=============================================================================

simulated function Notify_ClipHit()
{
    class'BUtil'.static.PlayFullSound(self, ClipHitSound, true);
}

simulated function Notify_SlideIn()
{
    class'BUtil'.static.PlayFullSound(self, SlideInSound, true);
}

simulated function Notify_SlideOut()
{
    class'BUtil'.static.PlayFullSound(self, SlideOutSound, true);
}

simulated function Notify_ClipOut()
{
	bBallisticClipOut = true;

	if (!bDualWeapon)
		BallisticReloadStage = 1;

	class'BUtil'.static.PlayFullSound(self, ClipOutSound, true);
}

simulated function Notify_ClipIn()
{
    bBallisticClipOut = false;
    bReloadResumePending = false;
    bBallisticReloadClipIn = true;
    bBallisticReload = false;

    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

    if (Role == ROLE_Authority)
        AddReloadedAmmo();

    BallisticReloadStage = 0;
}

simulated function Notify_ClipOutAlt()
{
	bBallisticClipOut = true;

	if (!bDualWeapon)
		BallisticReloadStage = 1;

	class'BUtil'.static.PlayFullSound(self, ClipOutAltSound, true);
}

simulated function Notify_ClipInAlt()
{
	bBallisticClipOut = false;
	bReloadResumePending = false;
	bAltReloadResumePending = false;
	bBallisticReload = false;

	if (Role == ROLE_Authority && AltAmmoLoaded <= 0 && AmmoAmount(1) > 0)
	{
		ConsumeAmmo(1, 1);
		AltAmmoLoaded = 1;
	}

	class'BUtil'.static.PlayFullSound(self, ClipInAltSound, true);

	BallisticReloadStage = 0;
}

simulated function Notify_CockStart()
{
    class'BUtil'.static.PlayFullSound(self, CockSound, true);
}

simulated function Notify_ClipOut1()
{
    class'BUtil'.static.PlayFullSound(self, ClipOutSound, true);
}

simulated function Notify_ClipOut2()
{
    BallisticReloadStage = 1;
    class'BUtil'.static.PlayFullSound(self, ClipOutSound, true);
}

simulated function Notify_ClipOut3()
{
	BallisticReloadStage = 1;

	class'BUtil'.static.PlayFullSound(self, ClipOutSound, true);
}

simulated function Notify_ClipIn3()
{
    BallisticReloadStage = 0;
    bBallisticReload = false;
    bReloadResumePending = false;

    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if (AmmoAmount(0) >= MagCapacity)
        MagAmmoRemaining = MagCapacity;
    else
        MagAmmoRemaining = AmmoAmount(0);

    class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

    if (Role < ROLE_Authority)
        ServerClipIn();

    if (FireMode[0] != None)
        BallisticInstantFire(FireMode[0]).ResetDualFire();
}

simulated function Notify_ClipIn1()
{
	BallisticReloadStage = 2;
	class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

	if (BallisticInstantFire(FireMode[0]) != None)
		BallisticInstantFire(FireMode[0]).bDualFireLeft = false;
}

simulated function Notify_ClipIn2()
{
    BallisticReloadStage = 3;
    bBallisticReload = false;
    bBallisticReloadClipIn = true;

    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if (AmmoAmount(0) >= MagCapacity)
        MagAmmoRemaining = MagCapacity;
    else
        MagAmmoRemaining = AmmoAmount(0);

    class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

    if (Role < ROLE_Authority)
        ServerClipIn();

    if (BallisticInstantFire(FireMode[0]) != None)
        BallisticInstantFire(FireMode[0]).bDualFireLeft = false;
}

simulated function Notify_SwipePoint1()
{
    if (MeleeState != MS_None && MeleeFireMode != none)
    {
        MeleeFireMode.ProcessSwipePoint(0);
    }
    else if (FireMode[0] != none && BallisticMeleeFire(FireMode[0]) != none)
    {
        BallisticMeleeFire(FireMode[0]).ProcessSwipePoint(0);
    }
    else if (FireMode[1] != none && BallisticMeleeFire(FireMode[1]) != none)
    {
        BallisticMeleeFire(FireMode[1]).ProcessSwipePoint(0);
    }
}

simulated function Notify_SwipePoint2()
{
    if (MeleeState != MS_None && MeleeFireMode != none)
    {
        MeleeFireMode.ProcessSwipePoint(1);
    }
    else if (FireMode[0] != none && BallisticMeleeFire(FireMode[0]) != none)
    {
        BallisticMeleeFire(FireMode[0]).ProcessSwipePoint(1);
    }
    else if (FireMode[1] != none && BallisticMeleeFire(FireMode[1]) != none)
    {
        BallisticMeleeFire(FireMode[1]).ProcessSwipePoint(1);
    }
}

simulated function Notify_SwipePoint3()
{
    if (MeleeState != MS_None && MeleeFireMode != none)
    {
        MeleeFireMode.ProcessSwipePoint(2);
    }
    else if (FireMode[0] != none && BallisticMeleeFire(FireMode[0]) != none)
    {
        BallisticMeleeFire(FireMode[0]).ProcessSwipePoint(2);
    }
    else if (FireMode[1] != none && BallisticMeleeFire(FireMode[1]) != none)
    {
        BallisticMeleeFire(FireMode[1]).ProcessSwipePoint(2);
    }
}

simulated function Notify_SwipePoint4()
{
    if (MeleeState != MS_None && MeleeFireMode != none)
    {
        MeleeFireMode.ProcessSwipePoint(3);
    }
    else if (FireMode[0] != none && BallisticMeleeFire(FireMode[0]) != none)
    {
        BallisticMeleeFire(FireMode[0]).ProcessSwipePoint(3);
    }
    else if (FireMode[1] != none && BallisticMeleeFire(FireMode[1]) != none)
    {
        BallisticMeleeFire(FireMode[1]).ProcessSwipePoint(3);
    }
}

simulated function Notify_SwipePoint5()
{
    if (MeleeState != MS_None && MeleeFireMode != none)
    {
        MeleeFireMode.ProcessSwipePoint(4);
    }
    else if (FireMode[0] != none && BallisticMeleeFire(FireMode[0]) != none)
    {
        BallisticMeleeFire(FireMode[0]).ProcessSwipePoint(4);
    }
    else if (FireMode[1] != none && BallisticMeleeFire(FireMode[1]) != none)
    {
        BallisticMeleeFire(FireMode[1]).ProcessSwipePoint(4);
    }
}


//=============================================================================
// ALT RELOAD NOTIFIERS
//=============================================================================

simulated function Notify_ClipOutAlt1()
{
    BallisticReloadStage = 1;

    class'BUtil'.static.PlayFullSound(self, ClipOutAltSound, true);
}

simulated function Notify_ClipOutAlt2()
{
    BallisticReloadStage = 2;

    class'BUtil'.static.PlayFullSound(self, ClipOutAltSound, true);
}

simulated function Notify_ClipOutAlt3()
{
    BallisticReloadStage = 3;

    class'BUtil'.static.PlayFullSound(self, ClipOutAltSound, true);
}

simulated function Notify_ClipInAlt1()
{
    if (Role == ROLE_Authority && AltAmmoLoaded < 2 && AmmoAmount(1) > 0)
    {
        ConsumeAmmo(1, 1);
        AltAmmoLoaded++;
    }

    BallisticReloadStage = 2;

    class'BUtil'.static.PlayFullSound(self, ClipInAltSound, true);
}

simulated function Notify_ClipInAlt2()
{
    if (Role == ROLE_Authority && AltAmmoLoaded < 2 && AmmoAmount(1) > 0)
    {
        ConsumeAmmo(1, 1);
        AltAmmoLoaded++;
    }

    BallisticReloadStage = 3;

    class'BUtil'.static.PlayFullSound(self, ClipInAltSound, true);
}

simulated function Notify_ClipInAlt3()
{
    if (Role == ROLE_Authority && AltAmmoLoaded < 2 && AmmoAmount(1) > 0)
    {
        ConsumeAmmo(1, 1);
        AltAmmoLoaded++;
    }

    BallisticReloadStage = 0;

    class'BUtil'.static.PlayFullSound(self, ClipInAltSound, true);
}


//=============================================================================
// SHOVEL NOTIFIERS
//=============================================================================

simulated function Notify_ShovelStart()
{
    class'BUtil'.static.PlayFullSound(self, ShovelStartSound, true);
}

simulated function Notify_ShovelLoop()
{
    class'BUtil'.static.PlayFullSound(self, ShovelLoopSound, true);
}

simulated function Notify_ShovelEnd()
{
    class'BUtil'.static.PlayFullSound(self, ShovelEndSound, true);
}

simulated function Notify_ShellInSmall()
{
    Log("SHOVEL TRACE 1: Notify_ShellInSmall");
    HandleShovelShellIn(1);
}

simulated function Notify_ShellInLarge()
{
    Log("SHOVEL TRACE 1: Notify_ShellInLarge");
    HandleShovelShellIn(CurrentShovelLoadAmount);
}

simulated function Notify_ShellLoopCheck()
{
    HandleShovelLoopCheck();
}


//=============================================================================
// SHOVEL HANDLERS
//=============================================================================

simulated function HandleShovelShellIn(int LoadAmount)
{
    if (!bShovelReload)
        return;

    if (LoadAmount <= 0)
        return;

    if (Role < ROLE_Authority)
    {
        ServerShovelShellIn(LoadAmount);
        return;
    }

    if (ShovelReloadMode == 0)
        AddShovelPrimaryAmmo(LoadAmount);
    else
        AddShovelSecondaryAmmo(LoadAmount);
}

function ServerShovelShellIn(int LoadAmount)
{
    if (!bShovelReload)
        return;

    if (LoadAmount <= 0)
        return;

    if (ShovelReloadMode == 0)
        AddShovelPrimaryAmmo(LoadAmount);
    else
        AddShovelSecondaryAmmo(LoadAmount);
}

simulated function AddShovelPrimaryAmmo(int LoadAmount)
{
    if (Role != ROLE_Authority)
        return;

    if (!bShovelReload)
        return;

    if (LoadAmount <= 0)
        return;

    if (MagAmmoRemaining >= MagCapacity)
        return;

    MagAmmoRemaining = MagAmmoRemaining + LoadAmount;

    Log("SHOVEL AFTER ADD: "$MagAmmoRemaining$" / "$MagCapacity);
}

simulated function AddShovelSecondaryAmmo(int LoadAmount)
{
    local int AvailableAmmo;
    local int ActualLoadAmount;

    if (Role != ROLE_Authority)
        return;

    AvailableAmmo = AmmoAmount(1);

    if (AvailableAmmo <= 0)
        return;

    ActualLoadAmount = LoadAmount;

    if (ActualLoadAmount > AvailableAmmo)
        ActualLoadAmount = AvailableAmmo;

    if (ActualLoadAmount <= 0)
        return;

    if (ConsumeAmmo(1, ActualLoadAmount))
        AltAmmoLoaded += ActualLoadAmount;
}

simulated function HandleShovelLoopCheck()
{
    Log("SHOVEL LOOP CHECK: Role="$Role);
	Log("  Shovel="$bShovelReload);
	Log("  Cancel="$bShovelReloadCancelRequested);
	Log("  Stop="$bShovelReloadStopRequested);
	Log("  End="$bShovelReloadEndRequested);
	Log("  Mag="$MagAmmoRemaining);
	Log("  Reserve="$AmmoAmount(0));
	
	if (!bShovelReload)
        return;

    if (bShovelReloadCancelRequested || bShovelReloadStopRequested)
    {
        bShovelReloadCancelRequested = false;
        bShovelReloadStopRequested = false;
        bShovelReloadEndRequested = true;
        return;
    }

    if (ShovelReloadMode == 0)
    {
        UpdateMagCapacity(Instigator.PlayerReplicationInfo);

        if (MagAmmoRemaining >= MagCapacity ||
            AmmoAmount(0) <= MagAmmoRemaining)
        {
            bShovelReloadEndRequested = true;
            return;
        }
    }
    else
    {
        if (AmmoAmount(1) <= 0)
        {
            bShovelReloadEndRequested = true;
            return;
        }
    }

    bShovelReloadEndRequested = false;
}

//=============================================================================
// Third Person
//=============================================================================

simulated function AttachToPawn(Pawn P)
{
    local name BoneName;
    local BallisticAttachment AltAttachment;

    Super.AttachToPawn(P);

    if (!bDualWeapon)
        return;

    if (AltThirdPersonActor == None)
    {
        AltThirdPersonActor = Spawn(AttachmentClass, Owner);

        if (InventoryAttachment(AltThirdPersonActor) != None)
            InventoryAttachment(AltThirdPersonActor).InitFor(self);

        AltAttachment = BallisticAttachment(AltThirdPersonActor);

        if (AltAttachment != None)
            AltAttachment.SetDualMesh(true);
    }
    else
        AltThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;

    if (AltThirdPersonActor == None)
        return;

    BoneName = P.GetOffhandBoneFor(self);

    if (BoneName == '')
    {
        AltThirdPersonActor.SetLocation(P.Location);
        AltThirdPersonActor.SetBase(P);
    }
    else
        P.AttachToBone(AltThirdPersonActor, BoneName);
}

simulated function PlayAltThirdPersonFlash()
{
    local BallisticAttachment AltAttachment;

    if (AltThirdPersonActor == None)
        return;

    AltAttachment = BallisticAttachment(AltThirdPersonActor);

    if (AltAttachment == None)
        return;

    AltAttachment.DoFlashEmitter();
}

simulated function PlayThirdPersonMeleePrep()
{
    local BallisticAttachment WeapAttach;

    if (ThirdPersonActor == None)
        return;

    WeapAttach = BallisticAttachment(ThirdPersonActor);

    if (WeapAttach == None)
        return;

    WeapAttach.PlayThirdPersonMeleePrep();
}

simulated function PlayThirdPersonMeleeFire()
{
    local BallisticAttachment WeapAttach;

    if (ThirdPersonActor == None)
        return;

    WeapAttach = BallisticAttachment(ThirdPersonActor);

    if (WeapAttach == None)
        return;

    WeapAttach.PlayThirdPersonMeleeFire();
}


//=============================================================================
// Iron Sight Code
//=============================================================================

simulated exec function IronSightZoomIn()
{
	if( bHasAimingMode )
	{
        if (ClientState == WS_BringUp)
            return;

        if( Owner != none && Owner.Physics == PHYS_Falling &&
            Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
        {
            return;
        }

		if( bIsReloading || bReloadResumePlaying || bBallisticAltReload || IsHoldingMelee() || !CanZoomNow() )
			return;

		PerformZoom(True);
	}
}

simulated exec function ToggleIronSights()
{
    if( bHasAimingMode )
    {
        if (ClientState == WS_BringUp)
            return;

        if (bReloadResumePlaying)
            return;

        if( bAimingRifle )
		{
			if (bBallisticAltReload)
				return;

			PerformZoom(false);
		}
        else
        {
            if( Owner != none && Owner.Physics == PHYS_Falling &&
                Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
            {
                return;
            }

            if (IsHoldingMelee())
                return;

            if( bIsReloading || bBallisticAltReload || !CanZoomNow() )
				return;

            PerformZoom(True);
        }
    }
}

//=============================================================================
// PUT DOWN & PULL OUT
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
	local int Mode;
	local bool bResumeReload;
	local bool bPlayingBringUpAnim;
	local KFPlayerController Player;

	HandleSleeveSwapping();

	Player = KFPlayerController(Instigator.Controller);

	if (KFHumanPawn(Instigator) != none)
		KFHumanPawn(Instigator).SetAiming(false);

	bAimingRifle = false;
	bIsReloading = false;
	IdleAnim = default.IdleAnim;

	bResumeReload = bReloadResumePending;

	if (ClientState == WS_Hidden || ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0)
	{
		class'BUtil'.static.PlayFullSound(self, PulloutSound, true);

		ClientPlayForceFeedback(SelectForce);

		if (Instigator.IsLocallyControlled())
		{
			if ((Mesh != none) && bResumeReload && ClientGrenadeState != GN_BringUp && KFPawn(Instigator).bIsQuickHealing <= 0)
			{
				if (bAltReloadResumePending && WeaponReloadAltResumeAnimation != '' && HasAnim(WeaponReloadAltResumeAnimation))
				{
					bReloadResumePlaying = true;
					PlayAnim(WeaponReloadAltResumeAnimation, 1.0, 0.0);
					bPlayingBringUpAnim = true;
					bAltReloadResumePending = false;
				}
				else if (BallisticReloadStage == 2 && WeaponReloadResumeAnimation2 != '' && HasAnim(WeaponReloadResumeAnimation2))
				{
					bReloadResumePlaying = true;
					PlayAnim(WeaponReloadResumeAnimation2, 1.0, 0.0);
					bPlayingBringUpAnim = true;
				}
				else if (WeaponReloadResumeAnimation != '' && HasAnim(WeaponReloadResumeAnimation))
				{
					bReloadResumePlaying = true;
					PlayAnim(WeaponReloadResumeAnimation, 1.0, 0.0);
					bPlayingBringUpAnim = true;
				}
			}
			else if ((Mesh != none) && HasAnim(SelectAnim))
			{
				if (ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0)
				{
					PlayAnim(SelectAnim, SelectAnimRate * (BringUpTime / QuickBringUpTime), 0.0);
				}
				else
				{
					PlayAnim(SelectAnim, SelectAnimRate, 0.0);
				}

				bPlayingBringUpAnim = true;
			}
		}

		ClientState = WS_BringUp;

		if (ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0)
		{
			ClientGrenadeState = GN_None;
		}
		else if (bResumeReload)
		{
			bReloadResumePending = false;
		}

		if (!bPlayingBringUpAnim)
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
				FireMode[Mode].InitEffects();

			PlayIdle();
			ClientState = WS_ReadyToFire;
		}
	}

	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		FireMode[Mode].bIsFiring = false;
		FireMode[Mode].HoldTime = 0.0;
		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
		FireMode[Mode].bInstantStop = false;
	}

	if ((PrevWeapon != none) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch)
		OldWeapon = PrevWeapon;
	else
		OldWeapon = none;

	if (SightFX == none && SightFXClass != none)
	{
		SightFX = Spawn(SightFXClass);

		if (SightFX != none)
		{
			AttachToBone(SightFX, SightFXBone);
		}
	}

	if (bDualWeapon && LeftSightFX == none && LeftSightFXClass != none)
	{
		LeftSightFX = Spawn(LeftSightFXClass);

		if (LeftSightFX != none)
		{
			AttachToBone(LeftSightFX, LeftSightFXBone);
		}
	}
}

simulated function Timer()
{
	if (ClientState == WS_BringUp)
		return;

	Super.Timer();
}

simulated function bool StartFire(int Mode)
{
	local bool RetVal;
	local bool bAutoReloadStart;

	if (ClientState == WS_BringUp)
		return false;

	if (bBallisticAltReload)
		return false;

	if (bShovelReload)
	{
		if (bShovelReloadLooping)
		{
			bShovelReloadStopRequested = true;
			return false;
		}

		return false;
	}
	
	if (Mode == 1 && (bIsReloading || bBallisticReload || bBallisticReloadClipIn))
		return false;

	if (bIsReloading || bBallisticReload || bBallisticReloadClipIn)
		return false;

	bAutoReloadStart = false;

	if (Mode == 0 && MagAmmoRemaining < 1 && BallisticMeleeFire(FireMode[Mode]) == None)
	{
		if (bModeZeroCanDryFire)
		{
			if (!bIsReloading)
			{
				if (FireMode[0].NextFireTime <= Level.TimeSeconds)
				{
					if (AllowReload())
						bAutoReloadStart = true;
				}
			}
		}

		if (!bAutoReloadStart)
			return false;
	}

	if (bAutoReloadStart)
		bSuppressStartFireReloadInterrupt = true;

	RetVal = Super.StartFire(Mode);

	if (bAutoReloadStart)
		bSuppressStartFireReloadInterrupt = false;

	if (RetVal)
	{
		if (Mode == 0 && ForceZoomOutOnFireTime > 0)
			ForceZoomOutTime = Level.TimeSeconds + ForceZoomOutOnFireTime;
		else if (Mode == 1 && ForceZoomOutOnAltFireTime > 0)
			ForceZoomOutTime = Level.TimeSeconds + ForceZoomOutOnAltFireTime;

		NumClicks = 0;

		if (!bAutoReloadStart)
			InterruptReload();
	}

	return RetVal;
}

simulated function bool PutDown()
{
	local bool bResult;

	bPuttingDown = true;
	
	ResetDualFireAnimationChannels();

	//=========================================================================
	// RELOAD
	//=========================================================================
	// Shovel reloads are cancelled when the weapon is lowered.
	// They do not use the normal reload-resume system.

	if (bShovelReload)
	{
		bShovelReload = false;
		bShovelReloadCancelRequested = false;
		bShovelReloadEndRequested = false;
		bShovelReloadStopRequested = false;
		bShovelReloadLooping = false;
		CurrentShovelLoadAmount = 0;

		bBallisticReload = false;
		bBallisticReloadClipIn = false;
		bIsReloading = false;
	}
	else if (bBallisticAltReload)
	{
		bReloadResumePending = true;
		bAltReloadResumePending = true;
		bBallisticAltReload = false;
		bIsReloading = false;
		bBallisticReloadClipIn = false;
	}
	else if (bIsReloading || bBallisticReload || bBallisticReloadClipIn)
	{
		bReloadResumePending = true;
		bBallisticReload = false;
		bBallisticReloadClipIn = false;
		bIsReloading = false;
	}

	//=========================================================================
	// MELEE
	//=========================================================================

	if (MeleeFireMode != none)
	{
		MeleeFireMode.bIsFiring = false;
		MeleeFireMode.HoldTime = 0.0;
		MeleeFireMode.HoldStartTime = 0.0;
	}

	MeleeState = MS_None;
	MeleeHoldTime = 0.0;

	//=========================================================================
	// EFFECTS
	//=========================================================================

	if (SightFX != none)
	{
		SightFX.Destroy();
		SightFX = none;
	}

	if (LeftSightFX != none)
	{
		LeftSightFX.Destroy();
		LeftSightFX = none;
	}

	if (AltThirdPersonActor != none)
	{
		AltThirdPersonActor.Destroy();
		AltThirdPersonActor = none;
	}

	bResult = Super.PutDown();

	bPuttingDown = false;

	return bResult;
}

//=============================================================================
// Scope Code
//=============================================================================

simulated function InitializeScope()
{
    if (!bScoped)
        return;

    if (ScopeScriptedTexture == none)
    {
        ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));

        if (ScopeScriptedTexture != none)
        {
            ScopeScriptedTexture.FallbackMaterial = ScopeFallbackMaterial;
            ScopeScriptedTexture.SetSize(ScopeTextureSize, ScopeTextureSize);
            ScopeScriptedTexture.Client = self;
        }
    }

    if (ScopeScriptedCombiner == none)
    {
        ScopeScriptedCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));

        if (ScopeScriptedCombiner != none)
        {
            ScopeScriptedCombiner.Material1 = ScopeMaskMaterial;
            ScopeScriptedCombiner.Material2 = ScopeScriptedTexture;
            ScopeScriptedCombiner.FallbackMaterial = ScopeFallbackMaterial;
            ScopeScriptedCombiner.CombineOperation = CO_Multiply;
            ScopeScriptedCombiner.AlphaOperation = AO_Use_Mask;
        }
    }

    if (ScopeScriptedShader == none)
    {
        ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));

        if (ScopeScriptedShader != none)
        {
            ScopeScriptedShader.Diffuse = ScopeScriptedCombiner;
            ScopeScriptedShader.SelfIllumination = ScopeScriptedCombiner;
            ScopeScriptedShader.FallbackMaterial = ScopeFallbackMaterial;
        }
    }
}

simulated event RenderTexture(ScriptedTexture Tex)
{
    local rotator RollMod;
    local float PortalFOV;

    if (!bScoped || Instigator == none || Tex == none || Tex.Client == none)
        return;

    PortalFOV = ScopePortalFOV;

    if (ScopePortalFOVHigh > 0.0 && ScopeTextureSizeHigh > ScopeTextureSize)
        PortalFOV = ScopePortalFOVHigh;

    RollMod = Instigator.GetViewRotation();

    if (Owner != none)
        Tex.DrawPortal(0, 0, Tex.USize, Tex.VSize, Owner, (Instigator.Location + Instigator.EyePosition()), RollMod, PortalFOV);
}


//=============================================================================
// ANIMATION END
//=============================================================================

simulated function AnimEnd(int Channel)
{
	local name AnimName;
	local float Frame;
	local float Rate;
	local int Mode;

	//=============================================================================
	// Dual Fire Animation Channels
	//=============================================================================

	if (Channel == DualFireLeftChannel)
	{
		bDualFireLeftPlaying = false;
		AnimBlendParams(DualFireLeftChannel, 0.0, 0.2, 0.0, DualFireLeftBone);
		return;
	}

	if (Channel == DualFireRightChannel)
	{
		bDualFireRightPlaying = false;
		AnimBlendParams(DualFireRightChannel, 0.0, 0.2, 0.0, DualFireRightBone);
		return;
	}
	
	//=============================================================================
	// Original Weapon Animation Channel
	//=============================================================================

	if (Channel == 0)
	{
		GetAnimParams(0, AnimName, Frame, Rate);

		if (bShovelReload)
		{
			if (AnimName == GetShovelReloadStartAnimation())
			{
				PlayShovelReloadLoopAnimation();
				return;
			}

			if (AnimName == GetShovelReloadLoopAnimation())
			{
				if (bShovelReloadEndRequested)
				{
					bShovelReloadEndRequested = false;
					bShovelReloadLooping = false;
					PlayShovelReloadEndAnimation();
				}
				else
				{
					PlayShovelReloadLoopAnimation();
				}

				return;
			}

			if (AnimName == GetShovelReloadEndAnimation())
			{
				bShovelReload = false;
				bShovelReloadLooping = false;
				bShovelReloadCancelRequested = false;
				bShovelReloadEndRequested = false;
				bIsReloading = false;
				bBallisticReload = false;
				bBallisticReloadClipIn = false;
				bReloadResumePending = false;

				PlayIdle();
				return;
			}
		}

		if (bBallisticAltReload && AnimName == WeaponReloadAltAnimation)
		{
			bBallisticAltReload = false;
			bBallisticReloadClipIn = false;
			BallisticReloadStage = 0;
		}

		if (bReloadResumePlaying &&
			(AnimName == WeaponReloadResumeAnimation ||
				AnimName == WeaponReloadResumeAnimation2 ||
				AnimName == WeaponReloadAltResumeAnimation))
		{
			bReloadResumePlaying = false;
			bBallisticReloadClipIn = false;
		}

		if (bIsReloading &&
			(AnimName == ReloadAnim ||
				AnimName == WeaponReloadResumeAnimation ||
				AnimName == WeaponReloadResumeAnimation2 ||
				AnimName == WeaponReloadAltResumeAnimation))
		{
			bIsReloading = false;
			bReloadEffectDone = false;
			bReloadResumePending = false;
			bBallisticReloadClipIn = false;
			BallisticReloadStage = 0;
		}

		if (bIsReloading)
			return;

		if (MeleeState == MS_Strike || MeleeState == MS_StrikePending)
			MeleeStrikeFinished();

		if (MeleeState == MS_Held)
			return;

		if (ClientState == WS_BringUp &&
			(AnimName == SelectAnim ||
				AnimName == WeaponReloadResumeAnimation ||
				AnimName == WeaponReloadResumeAnimation2 ||
				AnimName == WeaponReloadAltResumeAnimation))
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
				FireMode[Mode].InitEffects();

			PlayIdle();
			ClientState = WS_ReadyToFire;

			return;
		}
	}

	if (bIsReloading)
		return;

	Super.AnimEnd(Channel);
	CheckPendingMelee();
}


//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (ScopeScriptedTexture != none)
    {
        ScopeScriptedTexture.Client = none;
        Level.ObjectPool.FreeObject(ScopeScriptedTexture);
        ScopeScriptedTexture = none;
    }

    if (ScopeScriptedCombiner != none)
    {
        ScopeScriptedCombiner.Material2 = none;
        Level.ObjectPool.FreeObject(ScopeScriptedCombiner);
        ScopeScriptedCombiner = none;
    }

    if (ScopeScriptedShader != none)
    {
        ScopeScriptedShader.Diffuse = none;
        ScopeScriptedShader.SelfIllumination = none;
        Level.ObjectPool.FreeObject(ScopeScriptedShader);
        ScopeScriptedShader = none;
    }

	if (SightFX != None)
	{
		SightFX.Destroy();
		SightFX = None;
	}

	if (LeftSightFX != None)
	{
		LeftSightFX.Destroy();
		LeftSightFX = None;
	}
	
	if (AltThirdPersonActor != None)
	{
		AltThirdPersonActor.Destroy();
		AltThirdPersonActor = None;
	}

    Super.Destroyed();
}

defaultproperties
{
	ClipHitSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    ClipOutSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    ClipInSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Misc,Pitch=1.000000,bAtten=True)
	CockSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Misc,Pitch=1.000000,bAtten=True)
	SlideInSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	SlideOutSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	PulloutSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	ClipOutAltSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	ClipInAltSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
    WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
    WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
	CurrentWeaponMode=0

	SleeveNum=500
    BUseBWHands=False
    BWSleeveTexture=Texture'BWKF_Core_T.HandRig.BallisticHandRigKF-Tex'
	InvisibleSleeveTexture=Texture'BWKF_Core_T.Misc.Invisible'
	
	AmmoIcon=Texture'KillingFloorHUD.HUD.Hud_Bullets'
    ReserveAmmoIcon=Texture'KillingFloorHUD.HUD.Hud_Ammo_Clip'
    AltAmmoIcon=Texture'KillingFloor2HUD.HUD.Hud_M79'
	
	IdleAimAnim=SightIdle
	ReloadRate=2.0
	ReloadAnim="Reload"
	ReloadAnimRate=1.000000
	WeaponReloadResumeAnimation="ReloadResume"
	WeaponReloadResumeAnimation2="ReloadResumeLeft"
	WeaponReloadAltAnimation="ReloadAlt"
	WeaponReloadAltResumeAnimation="ReloadAltResume"
	AltFireAnimLeft='FireLeftAlt'
	AltFireAnimRight='FireRightAlt'
	AltSightFireAnimLeft='SightFireLeftAlt'
	AltSightFireAnimRight='SightFireRightAlt'
	SelectAnim="Pullout"
    SelectAnimRate=1.0
	PutDownAnim="Putaway"
	Weight=4.000000
	Description="This is a BW weapon."
	BobDamping=6.000000
	bHasAimingMode=true
	bTorchEnabled=false
	
	PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
	
	DualFireLeftBone="RootLeft"
	DualFireRightBone="RootRight"
	
	DisplayFOV=70.0
    StandardDisplayFOV=70.0
    PlayerIronSightFOV=70
    ZoomedDisplayFOV=40
	PlayerViewPivot=(Yaw=32768)
	
	ActiveMeleeFireMode=255
	bShowAltAmmoChamber=False
	//Dual Weapon Props
	bDualWeapon=False
	FlashBoneRight="Tip"
	FlashBoneLeft="Tip-2"
	AltFlashBoneRight="Tip2"
	AltFlashBoneLeft="Tip2-2"
	FireAnimRight="FireRight"
	FireAnimLeft="FireLeft"
	SightFireAnimRight="SightFireRight"
	SightFireAnimLeft="SightFireLeft"
	
	//Shovel Defaults
	bShovelLoadPrimary=False
	bShovelLoadSecondary=False
	bShovelLoadEmptyStart=False
	bShovelLoadEmptyLoop=False
	bShovelLoadEmptyEnd=False
	ShovelReloadStartAnimation="ReloadStart"
	ShovelReloadLoopAnimation="ReloadLoop"
	ShovelReloadEndAnimation="ReloadEnd"
	ShovelReloadEmptyStartAnimation="ReloadEmptyStart"
	ShovelReloadEmptyLoopAnimation="ReloadEmptyLoop"
	ShovelReloadEmptyEndAnimation="ReloadEmptyEnd"
	
	//BScoped Related Defaults
	bScoped=False
	ScopeMaskMaterial=Texture'KillingFloorWeapons.CommandoCross'
	ScopeFallbackMaterial=Shader'ScopeShaders.Zoomblur.LensShader'
	ScopeLensMaterialID=0
	ScopePortalFOV=12.0
	ScopePortalFOVHigh=22.0
	ScopeZoomedDisplayFOV=60.0
	ScopeZoomedDisplayFOVHigh=35.0
	ScopeViewOffset=(X=0.0,Y=0.0,Z=0.0)
	ScopeViewOffsetHigh=(X=0.0,Y=0.0,Z=0.0)
	ScopeTextureSize=512
	ScopeTextureSizeHigh=1024
}