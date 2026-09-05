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
var() Material KFSleeveTexture;
var() Material InvisibleSleeveTexture;

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

var() class<BallisticMeleeFire> MeleeFireClass;

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
var() bool bShovelLoad;
var bool bPuttingDown;
var bool bReloadCancelRequested;
var bool bReloadResumePending;
var bool bBallisticClipOut;

var bool bReloadResumePlaying;

var byte BallisticReloadStage;

var int CurrentShovelLoadAmount;

//=============================================================================
// Dual Weapons
//=============================================================================

var() name FlashBoneLeft;
var() name FlashBoneRight;
var() name FireAnimLeft;
var() name FireAnimRight;
var() name SightFireAnimLeft;
var() name SightFireAnimRight;


//=============================================================================
// RELOAD ANIMATION
//=============================================================================

var() name WeaponReloadFinishAnimation;
var() name WeaponReloadResumeAnimation;
var() name WeaponReloadResumeAnimation2;


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
var() BUtil.FullSound CockSound;

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
	ServerMeleeHold, ServerMeleeRelease, ServerSwitchWeaponMode, ServerClipIn;

	reliable if (Role == ROLE_Authority)
	ClientSwitchWeaponMode;
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

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

simulated function ZoomIn(bool bAnimateTransition)
{
    Log("BW TRACE: ZoomIn ENTER - bReloadResumePlaying=" $ bReloadResumePlaying $ " bIsReloading=" $ bIsReloading $ " ClientState=" $ ClientState);

    if (bReloadResumePlaying)
    {
        Log("BW TRACE: ZoomIn BLOCKED");
        return;
    }

    Log("BW TRACE: ZoomIn ALLOWED");
    Super.ZoomIn(bAnimateTransition);
}

//------------------------------------------------------------------------------
// HandleSleeveSwapping() - This function will handle sleeve swapping for
//	weapons depending on which player the person who picked the weapon up is.
//------------------------------------------------------------------------------
simulated function HandleSleeveSwapping()
{
    local XPawn XP;

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
        Skins[1] = KFSleeveTexture;
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

	if (FireMode[0] != None && BallisticInstantFire(FireMode[0]) != None)
		BallisticInstantFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);

	CheckBurstMode();
}

//-----------------------------------------------------------------------------
// COMMON SWITCH WEAPON MODE
//-----------------------------------------------------------------------------

simulated function CommonSwitchWeaponMode(byte NewMode)
{
	local int LastMode;

	if (Instigator == None)
		return;

	if (NewMode >= WeaponModes.Length)
		return;

	if (WeaponModes[NewMode].bUnavailable)
		return;

	LastMode = CurrentWeaponMode;
	CurrentWeaponMode = NewMode;

	if (FireMode[0] != None)
	{
		BallisticInstantFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
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

	if (MeleeState == MS_Strike)
	{
		MeleeState = MS_StrikePending;
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
				MeleeFireMode.PlayFiring();

			ServerMeleeRelease();
			SetDefaultGunLength();
			break;

		case MS_StrikePending:
			MeleeState = MS_StrikePending;
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

	if (!Instigator.IsLocallyControlled())
		MeleeFireMode.ServerPlayFiring();

	MeleeFireMode.DoFireEffect();
	SetDefaultGunLength();
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
	return false;
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

	MeleeFireMode.PlayMeleeHold();

	SetMeleeGunLength();

	ServerMeleeHold();
}


//=============================================================================
// RELOAD
//=============================================================================

exec function ReloadMeNow()
{
	if (MeleeState == MS_Held || MeleeState == MS_Pending || MeleeState == MS_Strike || MeleeState == MS_StrikePending)
		return;

	if (IsActionLocked())
		return;

	if (!AllowReload())
		return;

	bReloadCancelRequested = false;
	bReloadResumePending = false;
	bBallisticClipOut = false;
	BallisticReloadStage = 0;
	bBallisticReload = true;

	Super.ReloadMeNow();

	if (bShovelLoad)
		BeginBallisticShovelReload();
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

				AddReloadedAmmo();

				if (bHoldToReload)
					NumLoadedThisReload++;

				if (MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload)
					ReloadTimer = Level.TimeSeconds;

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

    Notify_ShovelStart();
}


// Default Ballistic shovel behaviour.
// Individual weapons can override this.

function int GetShovelLoadAmount()
{
    return 1;
}


//=============================================================================
// RELOAD CANCELLATION
//=============================================================================

simulated function bool InterruptReload()
{
	
	Log("BW TRACE: InterruptReload ENTER - Stage=" $ BallisticReloadStage $ " bIsReloading=" $ bIsReloading $ " bReloadResumePlaying=" $ bReloadResumePlaying $ " bBallisticReload=" $ bBallisticReload);
	
	if (!bIsReloading && BallisticReloadStage == 0)
		return false;

	bReloadCancelRequested = true;

	if (bShovelLoad && bIsReloading)
		return true;

	bIsReloading = false;

	Log("BW TRACE: InterruptReload SWITCH - Stage=" $ BallisticReloadStage);

	switch (BallisticReloadStage)
	{
		case 0:
			bReloadResumePending = false;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayReloadFinishAnimation();
			break;

		case 1:
			bReloadResumePending = true;
			bReloadCancelRequested = false;

			if (!bPuttingDown)
				PlayReloadResumeAnimation();
			break;

		case 2:
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
    Log("BW TRACE: PlayReloadResumeAnimation ENTER - Anim=" $ WeaponReloadResumeAnimation $ " Stage=" $ BallisticReloadStage);

    if (WeaponReloadResumeAnimation != '' && HasAnim(WeaponReloadResumeAnimation))
    {
        bReloadResumePlaying = true;
        Log("BW TRACE: PlayReloadResumeAnimation SET FLAG TRUE");
        PlayAnim(WeaponReloadResumeAnimation, 1.0, 0.0);
    }
    else
        PlayIdle();
}

simulated function PlayReloadResumeAnimation2()
{
    Log("BW TRACE: PlayReloadResumeAnimation2 ENTER - Anim=" $ WeaponReloadResumeAnimation2 $ " Stage=" $ BallisticReloadStage);

    if (WeaponReloadResumeAnimation2 != '' && HasAnim(WeaponReloadResumeAnimation2))
    {
        bReloadResumePlaying = true;
        Log("BW TRACE: PlayReloadResumeAnimation2 SET FLAG TRUE");
        PlayAnim(WeaponReloadResumeAnimation2, 1.0, 0.0);
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
	Log("M806 DEBUG: ActuallyFinishReloading - bIsReloading=" $ bIsReloading $ " bBallisticReload=" $ bBallisticReload $ " BallisticReloadStage=" $ BallisticReloadStage);

	Super.ActuallyFinishReloading();
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
	bBallisticReload = false;

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if (AmmoAmount(0) >= MagCapacity)
		MagAmmoRemaining = MagCapacity;
	else
		MagAmmoRemaining = AmmoAmount(0);

	class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

	if (Role < ROLE_Authority)
		ServerClipIn();

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

	bIsReloading = false;
	bReloadEffectDone = false;

	if (FireMode[0] != None)
		BallisticInstantFire(FireMode[0]).ResetDualFire();
}

simulated function Notify_ClipIn1()
{
	BallisticReloadStage = 2;
	class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

	Log("M806 DEBUG: ClipIn1 - bIsReloading=" $ bIsReloading $ " bBallisticReload=" $ bBallisticReload $ " ClientState=" $ ClientState);

	if (BallisticInstantFire(FireMode[0]) != None)
		BallisticInstantFire(FireMode[0]).bDualFireLeft = false;
}

simulated function Notify_ClipIn2()
{
	BallisticReloadStage = 3;
	bBallisticReload = false;

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

	bIsReloading = false;
	bReloadEffectDone = false;
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

    HandleShovelLoop();
}


simulated function Notify_ShovelEnd()
{
    class'BUtil'.static.PlayFullSound(self, ShovelEndSound, true);

    HandleShovelEnd();
}


//=============================================================================
// SHOVEL HANDLERS
//=============================================================================

simulated function HandleShovelLoop()
{
    /*
        Actual KF ammunition insertion will be hooked into the
        existing KFShotgunWeapon/KFWeapon mechanism here.
    */
}

simulated function HandleShovelEnd()
{
    if (bReloadCancelRequested)
    {
        bReloadCancelRequested = false;
        bIsReloading = false;

        PlayReloadFinishAnimation();
    }
}


//=============================================================================
// Iron Sight Code
//=============================================================================


simulated exec function IronSightZoomIn()
{
	Log("BW TRACE: IronSightZoomIn - bReloadResumePlaying=" $ bReloadResumePlaying $ " bIsReloading=" $ bIsReloading);

	if( bHasAimingMode )
	{
        if (ClientState == WS_BringUp)
            return;

        if( Owner != none && Owner.Physics == PHYS_Falling &&
            Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
        {
            return;
        }

		if( bIsReloading || bReloadResumePlaying || IsHoldingMelee() || !CanZoomNow() )
			return;

		PerformZoom(True);
	}
}

simulated exec function ToggleIronSights()
{
    Log("BW TRACE: ToggleIronSights - bReloadResumePlaying=" $ bReloadResumePlaying $ " bIsReloading=" $ bIsReloading $ " bAimingRifle=" $ bAimingRifle);

    if( bHasAimingMode )
    {
        if (ClientState == WS_BringUp)
            return;

        if (bReloadResumePlaying)
            return;

        if( bAimingRifle )
        {
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

            if( bIsReloading || !CanZoomNow() )
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

	Log("BW TRACE: BringUp ENTER - ClientState=" $ ClientState $ " SelectAnim=" $ SelectAnim $ " ReloadResume=" $ WeaponReloadResumeAnimation $ " ReloadResume2=" $ WeaponReloadResumeAnimation2 $ " Stage=" $ BallisticReloadStage);

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
				if (BallisticReloadStage == 2 && WeaponReloadResumeAnimation2 != '' && HasAnim(WeaponReloadResumeAnimation2))
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
	Log("BW TRACE: Timer - ClientState=" $ ClientState);
	
	if (ClientState == WS_BringUp)
		return;

	Super.Timer();
}

simulated function bool StartFire(int Mode)
{
	local bool RetVal;

	Log("BW TRACE: StartFire ENTER - Mode=" $ Mode $ " ClientState=" $ ClientState $ " bAimingRifle=" $ bAimingRifle $ " bIsReloading=" $ bIsReloading $ " MeleeState=" $ MeleeState);

	if (ClientState == WS_BringUp)
	{
		Log("BW TRACE: StartFire BLOCKED - WS_BringUp");
		return false;
	}

	RetVal = Super.StartFire(Mode);

	Log("BW TRACE: StartFire AFTER SUPER - RetVal=" $ RetVal $ " ClientState=" $ ClientState $ " bAimingRifle=" $ bAimingRifle);

	if (RetVal)
	{
		if (Mode == 0 && ForceZoomOutOnFireTime > 0)
			ForceZoomOutTime = Level.TimeSeconds + ForceZoomOutOnFireTime;
		else if (Mode == 1 && ForceZoomOutOnAltFireTime > 0)
			ForceZoomOutTime = Level.TimeSeconds + ForceZoomOutOnAltFireTime;

		NumClicks = 0;
		InterruptReload();
	}

	return RetVal;
}

simulated function bool PutDown()
{
	local bool bResult;

	bPuttingDown = true;
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

	Log("BW TRACE: AnimEnd ENTER - Channel=" $ Channel $ " ClientState=" $ ClientState $ " bAimingRifle=" $ bAimingRifle $ " bIsReloading=" $ bIsReloading);

	if (Channel == 0)
	{
		GetAnimParams(0, AnimName, Frame, Rate);

		Log("BW TRACE: AnimEnd Channel0 - Anim=" $ AnimName $ " Frame=" $ Frame $ " Rate=" $ Rate $ " ClientState=" $ ClientState);

		if (bReloadResumePlaying &&
			(AnimName == WeaponReloadResumeAnimation ||
				AnimName == WeaponReloadResumeAnimation2))
		{
			bReloadResumePlaying = false;
		}

		if (bIsReloading)
			Log("BallisticWeapon: AnimEnd during reload - Anim=" $ AnimName);

		if (MeleeState == MS_Strike)
		{
			MeleeStrikeFinished();
			return;
		}

		if (MeleeState == MS_StrikePending)
		{
			MeleeStrikeFinished();
			return;
		}

		if (MeleeState == MS_Held)
			return;

		if (ClientState == WS_BringUp &&
			(AnimName == SelectAnim ||
				AnimName == WeaponReloadResumeAnimation ||
				AnimName == WeaponReloadResumeAnimation2))
		{
			Log("BW TRACE: BringUp AnimEnd MATCH - Anim=" $ AnimName $ " SelectAnim=" $ SelectAnim);

			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
				FireMode[Mode].InitEffects();

			PlayIdle();
			ClientState = WS_ReadyToFire;

			Log("BW TRACE: BringUp AnimEnd SET READY - ClientState=" $ ClientState);

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

    Super.Destroyed();
}

defaultproperties
{
	ClipHitSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    ClipOutSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    ClipInSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	CockSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	SlideInSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	PulloutSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
    WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
    WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
	CurrentWeaponMode=0

	SleeveNum=500
    BUseBWHands=False
    BWSleeveTexture=Texture'BWKF_Core_T.HandRig.BallisticHandRigKF-Tex'
    KFSleeveTexture=Texture'KF_Weapons_Trip_T.hands.hands_1stP_military_diff'
	InvisibleSleeveTexture=Texture'BWKF_Core_T.Misc.Invisible'

	IdleAimAnim=SightIdle
	ReloadRate=2.0
	ReloadAnim="Reload"
	ReloadAnimRate=1.000000
	WeaponReloadResumeAnimation="ReloadResume"
	WeaponReloadResumeAnimation2="ReloadResumeLeft"
	SelectAnim="Pullout"
    SelectAnimRate=1.0
	PutDownAnim="Putaway"
	Weight=4.000000
	Description="This is a BW weapon."
	BobDamping=6.000000
	bHasAimingMode=true
	bTorchEnabled=false
	
	PlayerViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
	
	DisplayFOV=70.0
    StandardDisplayFOV=70.0
    PlayerIronSightFOV=70
    ZoomedDisplayFOV=40
	PlayerViewPivot=(Yaw=32768)
	
	//Dual Weapon Props
	bDualWeapon=False
	FlashBoneRight="Tip"
	FlashBoneLeft="Tip-2"
	FireAnimRight="FireRight"
	FireAnimLeft="FireLeft"
	SightFireAnimRight="SightFireRight"
	SightFireAnimLeft="SightFireLeft"
	
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