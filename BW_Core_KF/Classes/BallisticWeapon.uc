class BallisticWeapon extends KFWeapon
    abstract
	DependsOn(BUtil)
	HideDropDown
	CacheExempt;

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

var() class<BallisticMeleeFire> MeleeFireClass;

//=============================================================================
// SIGHTS
//=============================================================================

var Actor SightFX;
var() class<Actor> SightFXClass;
var() name SightFXBone;


//=============================================================================
// RELOAD
//=============================================================================

var() bool bShovelLoad;

var bool bReloadCancelRequested;
var bool bReloadResumePending;
var bool bBallisticClipOut;

var int CurrentShovelLoadAmount;


//=============================================================================
// RELOAD ANIMATION
//=============================================================================

var() name WeaponReloadFinishAnimation;
var() name WeaponReloadResumeAnimation;
var() float ReloadResumeTime;


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

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (MeleeFireClass != none)
	{
		MeleeFireMode = BallisticMeleeFire(Level.ObjectPool.AllocateObject(MeleeFireClass));

		if (MeleeFireMode != none)
		{
			MeleeFireMode.ThisModeNum = 2;
			MeleeFireMode.Weapon = self;
			MeleeFireMode.Instigator = Instigator;
			MeleeFireMode.Level = Level;
			MeleeFireMode.Owner = self;
			MeleeFireMode.PreBeginPlay();
			MeleeFireMode.BeginPlay();
			MeleeFireMode.PostBeginPlay();
			MeleeFireMode.PostNetBeginPlay();
		}
	}
	InitializeScope();
}

//------------------------------------------------------------------------------
// HandleSleeveSwapping() - This function will handle sleeve swapping for
//	weapons depending on which player the person who picked the weapon up is.
//------------------------------------------------------------------------------
simulated function HandleSleeveSwapping()
{
	local XPawn XP;
	local Material SleeveTexture;

	if( !Instigator.IsHumanControlled() || !Instigator.IsLocallyControlled() )
		return;

	XP = XPawn(Instigator);

	if( XP == none )
		return;

	SleeveTexture = Class<BallisticSpeciesType>(XP.Species).static.GetSleeveTexture();

	if( SleeveTexture != none )
		Skins[SleeveNum] = SleeveTexture;
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

	log("BALLISTIC MODE: Switching "$LastMode$" -> "$CurrentWeaponMode);
	log("BALLISTIC MODE: "$WeaponModes[CurrentWeaponMode].ModeName$" / "$WeaponModes[CurrentWeaponMode].ModeID$" / Value "$WeaponModes[CurrentWeaponMode].Value);

	if (FireMode[0] != None)
	{
		BallisticInstantFire(FireMode[0]).SwitchWeaponMode(CurrentWeaponMode);
	}

	CheckBurstMode();

	log("BALLISTIC MODE: CurrentWeaponMode="$CurrentWeaponMode$" bBurstMode="$BallisticInstantFire(FireMode[0]).bBurstMode$" MaxBurst="$BallisticInstantFire(FireMode[0]).MaxBurst);
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

	log("BALLISTIC MODE: CheckBurstMode - ModeID="$WeaponModes[CurrentWeaponMode].ModeID);

	BF.SwitchWeaponMode(CurrentWeaponMode);

	log("BALLISTIC MODE: CurrentWeaponMode="$CurrentWeaponMode$" bBurstMode="$BF.bBurstMode$" MaxBurst="$BF.MaxBurst);
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
		PerformZoom(false);

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

	log("BALLISTIC MELEE: Checking pending melee.");

	if (MeleeFireMode == None)
		return;

	if (ClientState != WS_ReadyToFire)
		return;

	if (bIsReloading)
		return;

	if (IsFiring())
		return;

	log("BALLISTIC MELEE: Pending melee -> Held.");

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

    /*
        KFWeapon remains responsible for the actual reload,
        ammunition, perk modifiers and replication.

        Ballistic only adds its reload layer around it.
    */

    Super.ReloadMeNow();

    if (bShovelLoad)
        BeginBallisticShovelReload();
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
    if (!bIsReloading)
        return false;

    log("BALLISTIC RELOAD: InterruptReload - bShovelLoad="$bShovelLoad$" bBallisticClipOut="$bBallisticClipOut$" bReloadResumePending="$bReloadResumePending);

    bReloadCancelRequested = true;

    if (bShovelLoad)
    {
        log("BALLISTIC RELOAD: Shovel reload - normal cancellation.");
        return true;
    }

    bIsReloading = false;

    if (bBallisticClipOut)
    {
        log("BALLISTIC RELOAD: Clip OUT detected - playing ReloadResume.");
        bReloadResumePending = true;
        bReloadCancelRequested = false;
        PlayReloadResumeAnimation();
    }
    else
    {
        log("BALLISTIC RELOAD: Clip OUT not detected - playing ReloadFinish.");
        bReloadResumePending = false;
        bReloadCancelRequested = false;
        PlayReloadFinishAnimation();
    }

    return true;
}


//=============================================================================
// RELOAD RESUME
//=============================================================================

simulated function PlayReloadResumeAnimation()
{
    log("BALLISTIC RELOAD: PlayReloadResumeAnimation - Animation="$WeaponReloadResumeAnimation);
    log("BALLISTIC RELOAD: HasAnim="$HasAnim(WeaponReloadResumeAnimation));

    if (WeaponReloadResumeAnimation != '' && HasAnim(WeaponReloadResumeAnimation))
    {
        log("BALLISTIC RELOAD: Playing ReloadResume.");
        PlayAnim(WeaponReloadResumeAnimation, 1.0, 0.0);
    }
    else
    {
        log("BALLISTIC RELOAD: ReloadResume animation NOT FOUND.");
        PlayIdle();
    }
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

    log("BALLISTIC RELOAD: ===== Notify_ClipOut ===== bBallisticClipOut="$bBallisticClipOut);

    class'BUtil'.static.PlayFullSound(self, ClipOutSound, true);
}

simulated function Notify_ClipIn()
{
    log("BALLISTIC RELOAD: ===== Notify_ClipIn =====");

    bBallisticClipOut = false;
    bReloadResumePending = false;

    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if (AmmoAmount(0) >= MagCapacity)
        MagAmmoRemaining = MagCapacity;
    else
        MagAmmoRemaining = AmmoAmount(0);

    class'BUtil'.static.PlayFullSound(self, ClipInSound, true);

    if (Role < ROLE_Authority)
        ServerClipIn();
}


simulated function Notify_CockStart()
{
    class'BUtil'.static.PlayFullSound(self, CockSound, true);
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
	if( bHasAimingMode )
	{
        if( Owner != none && Owner.Physics == PHYS_Falling &&
            Owner.PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z )
        {
            return;
        }

		if( bIsReloading || !CanZoomNow() )
			return;

		PerformZoom(True);
	}
}

simulated exec function ToggleIronSights()
{
	if( bHasAimingMode )
	{
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
    local KFPlayerController Player;

    HandleSleeveSwapping();

    Player = KFPlayerController(Instigator.Controller);

    if (Player != none && ClientGrenadeState != GN_BringUp)
    {
        if (class == class'Single')
        {
            Player.CheckForHint(10);
        }
        else if (class == class'Dualies')
        {
            Player.CheckForHint(11);
        }
        else if (class == class'Deagle')
        {
            Player.CheckForHint(12);
        }
        else if (class == class'Bullpup')
        {
            Player.CheckForHint(13);
        }
        else if (class == class'Shotgun')
        {
            Player.CheckForHint(14);
        }
        else if (class == class'Winchester')
        {
            Player.CheckForHint(15);
        }
        else if (class == class'Crossbow')
        {
            Player.CheckForHint(16);
        }
        else if (class == class'BoomStick')
        {
            Player.CheckForHint(17);
            Player.WeaponPulloutRemark(21);
        }
        else if (class == class'FlameThrower')
        {
            Player.CheckForHint(18);
        }
        else if (class == class'LAW')
        {
            Player.CheckForHint(19);
            Player.WeaponPulloutRemark(23);
        }
        else if (class == class'Knife' && bShowPullOutHint)
        {
            Player.CheckForHint(20);
        }
        else if (class == class'Machete')
        {
            Player.CheckForHint(21);
        }
        else if (class == class'Axe')
        {
            Player.CheckForHint(22);
            Player.WeaponPulloutRemark(24);
        }
        else if (class == class'DualDeagle' || class == class'GoldenDualDeagle')
        {
            Player.WeaponPulloutRemark(22);
        }

        bShowPullOutHint = true;
    }

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
            if ((Mesh != none) && bResumeReload && WeaponReloadResumeAnimation != '' && HasAnim(WeaponReloadResumeAnimation) && ClientGrenadeState != GN_BringUp && KFPawn(Instigator).bIsQuickHealing <= 0)
            {
                log("BALLISTIC RELOAD: BringUp playing ReloadResume.");
                PlayAnim(WeaponReloadResumeAnimation, 1.0, 0.0);
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
            }
        }

        ClientState = WS_BringUp;

        if (ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0)
        {
            ClientGrenadeState = GN_None;
            SetTimer(QuickBringUpTime, false);
        }
        else if (bResumeReload)
        {
            log("BALLISTIC RELOAD: BringUp using ReloadResumeTime="$ReloadResumeTime);
            SetTimer(ReloadResumeTime, false);
        }
        else
        {
            SetTimer(BringUpTime, false);
        }

        if (bResumeReload)
            bReloadResumePending = false;
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
            log("BallisticWeapon: Spawned SightFX "$SightFX$" for "$self);
            log("BallisticWeapon: Attaching SightFX to bone "$SightFXBone);
            AttachToBone(SightFX, SightFXBone);
            log("BallisticWeapon: SightFX location after attach "$SightFX.Location);
        }
    }
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
	if (Channel == 0)
	{
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
		{
			return;
		}
	}

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
	IdleAimAnim=SightIdle
	ReloadResumeTime=1.900000
	ReloadRate=2.0
	ReloadAnim="Reload"
	ReloadAnimRate=1.000000
	WeaponReloadResumeAnimation="ReloadResume"
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