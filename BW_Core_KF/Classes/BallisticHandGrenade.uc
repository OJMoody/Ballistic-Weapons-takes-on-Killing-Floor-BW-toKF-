class BallisticHandGrenade extends BallisticWeapon
    abstract;

var bool bGrenadeThrowPending;
var bool bGrenadeReleased;
var bool bGrenadeCharging;

var float GrenadeChargeStartTime;
var float GrenadeChargeTime;

var() name GrenadePrepareAnimation;
var() name GrenadeThrowAnimation;

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
    log("NRP57: StartFire Mode="$Mode);
    log("NRP57: ClientState="$ClientState);
    log("NRP57: AmmoAmount="$AmmoAmount(0));
    log("NRP57: PrepareAnim="$GrenadePrepareAnimation$" ThrowAnim="$GrenadeThrowAnimation);

    if (Mode != 0)
        return false;

    if (ClientState == WS_BringUp)
    {
        log("NRP57: Blocked by WS_BringUp");
        return false;
    }

    if (bGrenadeThrowPending || bGrenadeReleased || bGrenadeCharging)
    {
        log("NRP57: Blocked by grenade state");
        return false;
    }

    if (AmmoAmount(0) < 1 || GrenadePrepareAnimation == '' || GrenadeThrowAnimation == '')
    {
        log("NRP57: Blocked by ammo or animation configuration");
        return false;
    }

    bGrenadeCharging = true;
	FireMode[Mode].bIsFiring = true;
    GrenadeChargeStartTime = Level.TimeSeconds;
    GrenadeChargeTime = 0.0;

    log("NRP57: Playing preparation animation");
    LoopAnim(GrenadePrepareAnimation, 1.0, 0.0);

    if (Role < ROLE_Authority)
        ServerBeginGrenadeThrow();

    return true;
}

simulated event StopFire(int Mode)
{
    log("NRP57: StopFire Mode="$Mode$" Charging="$bGrenadeCharging);

    if (Mode != 0 || !bGrenadeCharging)
    {
        Super.StopFire(Mode);
        return;
    }

    FireMode[Mode].bIsFiring = false;
	bGrenadeCharging = false;
	GrenadeChargeTime = FMax(0.0, Level.TimeSeconds - GrenadeChargeStartTime);

    log("NRP57: Starting throw, ChargeTime="$GrenadeChargeTime);

    if (Role == ROLE_Authority)
        BeginGrenadeThrow();
    else
    {
        BeginGrenadeThrow();
        ServerCommitGrenadeThrow(GrenadeChargeTime);
    }
}

//=============================================================================
// THROW ANIMATION
//=============================================================================

simulated function BeginGrenadeThrow()
{
    log("NRP57: BeginGrenadeThrow Pending="$bGrenadeThrowPending$" Released="$bGrenadeReleased);

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

    log("NRP57: ReleaseGrenade Role="$Role$" Pending="$bGrenadeThrowPending$" Released="$bGrenadeReleased$" Ammo="$AmmoAmount(0));

    if (Role != ROLE_Authority)
        return;

    if (!bGrenadeThrowPending || bGrenadeReleased)
    {
        log("NRP57: Release rejected by state");
        return;
    }

    if (AmmoAmount(0) < 1 || FireMode[0] == None)
    {
        log("NRP57: Release rejected by ammo or fire mode");
        bGrenadeThrowPending = false;
        return;
    }

    GrenadeFire = BallisticHandGrenadeFire(FireMode[0]);

    if (GrenadeFire == None)
    {
        log("NRP57: Release rejected by fire class");
        bGrenadeThrowPending = false;
        return;
    }

    bGrenadeReleased = true;
    bGrenadeThrowPending = false;

    GrenadeFire.CacheThrowPower(GrenadeChargeTime);
    ConsumeAmmo(0, 1);
    log("NRP57: Ammo after consume="$AmmoAmount(0));
    GrenadeFire.DoFireEffect();
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

        if (bGrenadeThrowPending && AnimName == GrenadeThrowAnimation)
        {
            FinishGrenadeThrow();
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
}

defaultproperties
{
	bNoAmmoInstances=True
	AmmoClass(0)=Class'KFMod.FragAmmo'
	AmmoClass(1)=Class'KFMod.FragAmmo'
	AmmoCharge(0)=4
	AmmoCharge(1)=4
}