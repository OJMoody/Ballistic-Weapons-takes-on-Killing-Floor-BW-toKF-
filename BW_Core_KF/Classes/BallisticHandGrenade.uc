class BallisticHandGrenade extends BallisticWeapon
    abstract;

var bool bGrenadeThrowPending;
var bool bGrenadeReleased;
var bool bGrenadeCharging;

var float GrenadeChargeStartTime;
var float GrenadeChargeTime;

var() name GrenadePrepareAnimation;
var() name GrenadeThrowAnimation;

var bool bSkipGrenadePutDown;

var bool bGrenadePulloutPlaying;

var() bool bRequireAmmoToSelect;

replication
{
    reliable if (Role < ROLE_Authority)
        ServerBeginGrenadeThrow, ServerCommitGrenadeThrow, ServerReleaseGrenade, ServerFinishGrenadeThrow;
}

//=============================================================================
// INPUT
//=============================================================================

simulated function bool StartFire(int Mode)
{

	log("NRP57 TRACE StartFire: Mode="$Mode
    $" AmmoAmount="$AmmoAmount(0)
    $" AmmoCharge="$AmmoCharge[0]
    $" AmmoActor="$Ammo[0]
    $" ClientState="$ClientState
    $" Charging="$bGrenadeCharging
    $" Pending="$bGrenadeThrowPending
    $" Released="$bGrenadeReleased);

    if (Mode != 0)
        return false;

    if (ClientState == WS_BringUp)
    {
        return false;
    }

    if (bGrenadeThrowPending || bGrenadeReleased || bGrenadeCharging || bGrenadePulloutPlaying)
	{
		return false;
	}

    if (AmmoAmount(0) < 1 || GrenadePrepareAnimation == '' || GrenadeThrowAnimation == '')
    {
        return false;
    }

    bGrenadeCharging = true;
	FireMode[Mode].bIsFiring = true;
    GrenadeChargeStartTime = Level.TimeSeconds;
    GrenadeChargeTime = 0.0;

    LoopAnim(GrenadePrepareAnimation, 1.0, 0.0);

    if (Role < ROLE_Authority)
        ServerBeginGrenadeThrow();

    return true;
}

simulated event StopFire(int Mode)
{
    if (Mode != 0 || !bGrenadeCharging)
    {
        Super.StopFire(Mode);
        return;
    }

    FireMode[Mode].bIsFiring = false;
	bGrenadeCharging = false;
	GrenadeChargeTime = FMax(0.0, Level.TimeSeconds - GrenadeChargeStartTime);

    if (Role == ROLE_Authority)
        BeginGrenadeThrow();
    else
    {
        BeginGrenadeThrow();
        ServerCommitGrenadeThrow(GrenadeChargeTime);
    }
}

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
    if (bGrenadeThrowPending || bGrenadeReleased)
        return;

    bGrenadeThrowPending = true;
    PlayAnim(GrenadeThrowAnimation, 1.0, 0.0);
}

//=============================================================================
// GRENADE NOTIFIER
//=============================================================================

simulated function Notify_GrenadeLeaveHand()
{
    if (!bGrenadeThrowPending || bGrenadeReleased)
        return;

    if (Role < ROLE_Authority)
    {
        bGrenadeReleased = true;
        ServerReleaseGrenade();
    }
    else
        ReleaseGrenade();
}

//=============================================================================
// AUTHORITATIVE RELEASE
//=============================================================================

function ReleaseGrenade()
{
    local BallisticHandGrenadeFire GrenadeFire;

	log("NRP57 TRACE ReleaseGrenade: AmmoAmount="$AmmoAmount(0)
    $" AmmoCharge="$AmmoCharge[0]
    $" AmmoActor="$Ammo[0]);

    if (Role != ROLE_Authority)
        return;

    if (!bGrenadeThrowPending || bGrenadeReleased)
    {
        return;
    }

    if (AmmoAmount(0) < 1 || FireMode[0] == None)
    {
        bGrenadeThrowPending = false;
        return;
    }

    GrenadeFire = BallisticHandGrenadeFire(FireMode[0]);

    if (GrenadeFire == None)
    {
        bGrenadeThrowPending = false;
        return;
    }

    bGrenadeReleased = true;
    bGrenadeThrowPending = false;

    GrenadeFire.CacheThrowPower(GrenadeChargeTime);
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

    if (Channel == 0)
    {
        GetAnimParams(0, AnimName, Frame, Rate);

        if (bGrenadeCharging && AnimName == GrenadePrepareAnimation)
        {
            LoopAnim(GrenadePrepareAnimation, 0.0, 0.0);
            return;
        }

        if ((bGrenadeThrowPending || bGrenadeReleased) && AnimName == GrenadeThrowAnimation)
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

function ServerBeginGrenadeThrow()
{
    if (bGrenadeThrowPending || bGrenadeReleased || bGrenadeCharging || AmmoAmount(0) < 1)
        return;

    bGrenadeCharging = true;
    GrenadeChargeStartTime = Level.TimeSeconds;
    GrenadeChargeTime = 0.0;
}

function ServerCommitGrenadeThrow(float ChargeTime)
{
    if (Role != ROLE_Authority || !bGrenadeCharging)
        return;

    GrenadeChargeTime = FMax(0.0, ChargeTime);
    bGrenadeCharging = false;
    BeginGrenadeThrow();
}

function ServerReleaseGrenade()
{
    ReleaseGrenade();
}

function ServerFinishGrenadeThrow()
{
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
        ServerFinishGrenadeThrow();
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

    SavedPutDownAnim = PutDownAnim;
    PutDownAnim = '';

    bResult = Super.PutDown();

    PutDownAnim = SavedPutDownAnim;

    return bResult;
}

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
	Weight=0.000000
	InventoryGroup=5
	GroupOffset=3
	Priority=4
	
	bKFNeverThrow=True
	
	WeaponModes(0)=(ModeName="Throw",ModeID="WM_SemiAuto")
	CurrentWeaponMode=0
}