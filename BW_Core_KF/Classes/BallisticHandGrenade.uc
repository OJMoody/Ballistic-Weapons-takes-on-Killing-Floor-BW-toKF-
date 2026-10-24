class BallisticHandGrenade extends BallisticWeapon
    abstract;

var bool bGrenadeThrowPending;
var bool bGrenadeReleased;
var bool bGrenadeCharging;

var float GrenadeChargeStartTime;
var float GrenadeChargeTime;

var byte GrenadeFireMode;

var bool bSkipGrenadePutDown;
var bool bGrenadePulloutPlaying;

var() bool bRequireAmmoToSelect;

var() BUtil.FullSound GrenadePinPullSound;
var() BUtil.FullSound GrenadePinPushSound;

replication
{
    reliable if (Role < ROLE_Authority)
        ServerBeginGrenadeThrow, ServerCommitGrenadeThrow,
        ServerReleaseGrenade, ServerFinishGrenadeThrow;
}

//=============================================================================
// INPUT
//=============================================================================

simulated function bool StartFire(int Mode)
{
    local BallisticHandGrenadeFire GrenadeFire;

    if (Mode < 0 || Mode > 1)
        return false;

    if (ClientState == WS_BringUp)
        return false;

    if (bGrenadeThrowPending || bGrenadeReleased || bGrenadeCharging || bGrenadePulloutPlaying)
        return false;

    GrenadeFire = BallisticHandGrenadeFire(FireMode[Mode]);

    if (GrenadeFire == None)
        return false;

    if (AmmoAmount(0) < 1 || GrenadeFire.GrenadePrepareAnimation == ''
        || GrenadeFire.GrenadeThrowAnimation == '')
        return false;

    GrenadeFireMode = Mode;
    bGrenadeCharging = true;
    FireMode[Mode].bIsFiring = true;

    GrenadeChargeStartTime = Level.TimeSeconds;
    GrenadeChargeTime = 0.0;

    LoopAnim(GrenadeFire.GrenadePrepareAnimation, 1.0, 0.0);

    if (Role < ROLE_Authority)
        ServerBeginGrenadeThrow(Mode);

    return true;
}

simulated event StopFire(int Mode)
{
    if (Mode != GrenadeFireMode || !bGrenadeCharging)
    {
        Super.StopFire(Mode);
        return;
    }

    FireMode[GrenadeFireMode].bIsFiring = false;
    bGrenadeCharging = false;

    GrenadeChargeTime = FMax(0.0, Level.TimeSeconds - GrenadeChargeStartTime);

    if (Role == ROLE_Authority)
        BeginGrenadeThrow();
    else
    {
        BeginGrenadeThrow();
        ServerCommitGrenadeThrow(GrenadeFireMode, GrenadeChargeTime);
    }
}

//=============================================================================
// WEAPON SELECTION
//=============================================================================

simulated function Weapon WeaponChange(byte F, bool bSilent)
{
    if (bRequireAmmoToSelect && InventoryGroup == F && AmmoAmount(0) <= 0)
    {
        if (Inventory == None)
            return None;

        return Inventory.WeaponChange(F, bSilent);
    }

    return Super.WeaponChange(F, bSilent);
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if (bRequireAmmoToSelect && AmmoAmount(0) <= 0)
    {
        if (Inventory == None)
            return CurrentChoice;

        return Inventory.PrevWeapon(CurrentChoice, CurrentWeapon);
    }

    return Super.PrevWeapon(CurrentChoice, CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if (bRequireAmmoToSelect && AmmoAmount(0) <= 0)
    {
        if (Inventory == None)
            return CurrentChoice;

        return Inventory.NextWeapon(CurrentChoice, CurrentWeapon);
    }

    return Super.NextWeapon(CurrentChoice, CurrentWeapon);
}

//=============================================================================
// THROW ANIMATION
//=============================================================================

simulated function BeginGrenadeThrow()
{
    local BallisticHandGrenadeFire GrenadeFire;

    if (bGrenadeThrowPending || bGrenadeReleased)
        return;

    if (GrenadeFireMode > 1)
        return;

    GrenadeFire = BallisticHandGrenadeFire(FireMode[GrenadeFireMode]);

    if (GrenadeFire == None)
        return;

    bGrenadeThrowPending = true;

    class'BUtil'.static.PlayFullSound(self, GrenadeFire.GrenadeThrowSound);

    PlayAnim(GrenadeFire.GrenadeThrowAnimation, 1.0, 0.0);
}

//=============================================================================
// GRENADE NOTIFIERS
//=============================================================================

simulated function Notify_GrenadeLeaveHand()
{
    if (!bGrenadeThrowPending || bGrenadeReleased)
        return;

    // Hide the grenade held in the first-person mesh.
    SetBoneScale(1, 0.0, 'Grenade');

    if (Role < ROLE_Authority)
    {
        bGrenadeReleased = true;
        ServerReleaseGrenade(GrenadeFireMode);
    }
    else
        ReleaseGrenade(GrenadeFireMode);
}

simulated function Notify_GrenadePullOut()
{
    // Show the grenade held in the first-person mesh.
    SetBoneScale(1, 1.0, 'Grenade');
}

simulated function Notify_GrenadePinPull()
{
    class'BUtil'.static.PlayFullSound(self, GrenadePinPullSound);
}

simulated function Notify_GrenadePinPush()
{
    class'BUtil'.static.PlayFullSound(self, GrenadePinPushSound);
}

//=============================================================================
// AUTHORITATIVE RELEASE
//=============================================================================

function ReleaseGrenade(byte Mode)
{
    local BallisticHandGrenadeFire GrenadeFire;

    if (Role != ROLE_Authority)
        return;

    if (!bGrenadeThrowPending || bGrenadeReleased || Mode != GrenadeFireMode)
        return;

    if (Mode > 1 || AmmoAmount(0) < 1 || FireMode[Mode] == None)
    {
        bGrenadeThrowPending = false;
        return;
    }

    GrenadeFire = BallisticHandGrenadeFire(FireMode[Mode]);

    if (GrenadeFire == None)
    {
        bGrenadeThrowPending = false;
        return;
    }

    bGrenadeReleased = true;
    bGrenadeThrowPending = false;

    GrenadeFire.CacheGrenadeThrowPower(GrenadeChargeTime);

    ConsumeAmmo(0, 1);
    GrenadeFire.DoFireEffect();
}

function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
    Super.GiveAmmo(m, WP, bJustSpawned);

    // Hand grenades have no magazine, so KF1 initializes their ammo to zero.
    // Seed the ammo inventory object with its initial amount instead.
    if (!bNoAmmoInstances && m == 0 && bJustSpawned && Ammo[0] != None && Ammo[0].AmmoAmount < 1)
        Ammo[0].AddAmmo(Ammo[0].InitialAmount);
}

//=============================================================================
// ANIMATION END
//=============================================================================

simulated function AnimEnd(int Channel)
{
    local name AnimName;
    local float Frame;
    local float Rate;
    local BallisticHandGrenadeFire GrenadeFire;

    if (Channel == 0)
    {
        GetAnimParams(0, AnimName, Frame, Rate);

        if (GrenadeFireMode <= 1)
            GrenadeFire = BallisticHandGrenadeFire(FireMode[GrenadeFireMode]);

        if (bGrenadeCharging && GrenadeFire != None
            && AnimName == GrenadeFire.GrenadePrepareAnimation)
        {
            LoopAnim(GrenadeFire.GrenadePrepareAnimation, 0.0, 0.0);
            return;
        }

        if ((bGrenadeThrowPending || bGrenadeReleased)
            && GrenadeFire != None
            && AnimName == GrenadeFire.GrenadeThrowAnimation)
        {
            FinishGrenadeThrow();

            if (AmmoAmount(0) > 0)
            {
                if (SelectAnim != '' && HasAnim(SelectAnim))
                {
                    bGrenadePulloutPlaying = true;
                    PlayAnim(SelectAnim, SelectAnimRate, 0.0);
                }
                else
                    PlayIdle();
            }

            return;
        }

        if (bGrenadePulloutPlaying && AnimName == SelectAnim)
        {
            bGrenadePulloutPlaying = false;
            PlayIdle();
            return;
        }
    }

    Super.AnimEnd(Channel);
}

//=============================================================================
// SERVER RPCS
//=============================================================================

function ServerBeginGrenadeThrow(byte Mode)
{
    local BallisticHandGrenadeFire GrenadeFire;

    if (Mode > 1 || bGrenadeThrowPending || bGrenadeReleased || bGrenadeCharging
        || AmmoAmount(0) < 1)
        return;

    GrenadeFire = BallisticHandGrenadeFire(FireMode[Mode]);

    if (GrenadeFire == None || GrenadeFire.GrenadePrepareAnimation == ''
        || GrenadeFire.GrenadeThrowAnimation == '')
        return;

    GrenadeFireMode = Mode;
    bGrenadeCharging = true;
    GrenadeChargeStartTime = Level.TimeSeconds;
    GrenadeChargeTime = 0.0;
}

function ServerCommitGrenadeThrow(byte Mode, float ChargeTime)
{
    if (Role != ROLE_Authority || !bGrenadeCharging || Mode != GrenadeFireMode)
        return;

    GrenadeChargeTime = FMax(0.0, ChargeTime);
    bGrenadeCharging = false;

    BeginGrenadeThrow();
}

function ServerReleaseGrenade(byte Mode)
{
    ReleaseGrenade(Mode);
}

function ServerFinishGrenadeThrow(byte Mode)
{
    if (Mode != GrenadeFireMode)
        return;

    bGrenadeCharging = false;
    bGrenadeThrowPending = false;
    bGrenadeReleased = false;

    SwitchBackIfEmpty();
}

//=============================================================================
// CLEANUP
//=============================================================================

simulated function FinishGrenadeThrow()
{
    bGrenadeCharging = false;
    bGrenadeThrowPending = false;
    bGrenadeReleased = false;

    if (Role < ROLE_Authority)
        ServerFinishGrenadeThrow(GrenadeFireMode);
    else
        SwitchBackIfEmpty();
}

//=============================================================================
// RETURN TO PREVIOUS WEAPON
//=============================================================================

function SwitchBackIfEmpty()
{
    if (Role != ROLE_Authority || AmmoAmount(0) > 0 || Instigator == None)
        return;

    if (Instigator.Weapon != self || Instigator.PendingWeapon != None)
        return;

    bSkipGrenadePutDown = true;
    Instigator.SwitchToLastWeapon();
}

simulated function bool PutDown()
{
    local bool bResult;
    local name SavedPutDownAnim;

    if (!bSkipGrenadePutDown)
        return Super.PutDown();

    bSkipGrenadePutDown = false;
    bSkipPutAwaySound = true;

    SavedPutDownAnim = PutDownAnim;
    PutDownAnim = '';

    bResult = Super.PutDown();

    PutDownAnim = SavedPutDownAnim;

    return bResult;
}

//=============================================================================
// AMMO
//=============================================================================

function Ammunition GetGrenadeAmmo()
{
    return Ammo[0];
}

defaultproperties
{
    bRequireAmmoToSelect=True
    bNoAmmoInstances=False
    bHasAimingMode=False

    AmmoClass(0)=Class'BW_Core_KF.BallisticHandGrenadeAmmo'
    AmmoClass(1)=Class'BW_Core_KF.BallisticHandGrenadeAmmo'

    AmmoCharge(0)=5
    AmmoCharge(1)=5

    PulloutSound=(Sound=Sound'BWKF_Core_SN.NRP57.NRP57-Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_Core_SN.NRP57.NRP57-Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    GrenadePinPullSound=(Sound=Sound'BWKF_Core_SN.NRP57.NRP57-PinOut',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    GrenadePinPushSound=(Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)

    Weight=0.000000
    InventoryGroup=5
    GroupOffset=3
    Priority=4

    bKFNeverThrow=True

    WeaponModes(0)=(ModeName="Throw",ModeID="WM_SemiAuto")
    CurrentWeaponMode=0
}