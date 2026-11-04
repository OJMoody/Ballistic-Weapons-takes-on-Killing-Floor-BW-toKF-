class Weapon_M50Rifle_Main extends BallisticWeapon;

var bool bM50GrenadePriming;
var bool bM50GrenadePrimed;
var bool bM50GrenadeLaunching;
var bool bM50GrenadeReloading;
var bool bM50AmmoInitialized;
var bool bM50EmptyReload;

var() Sound M50GrenadeLaunchSound;

var() Sound GrenOpenSound;
var() Sound GrenLoadSound;
var() Sound GrenCloseSound;

//=============================================================================
// Alt Grenade Firing
//=============================================================================

simulated function bool StartFire(int Mode)
{
    if (bM50GrenadePrimed)
    {
        if (bM50GrenadeLaunching)
            return false;

        if (Mode == 0 || Mode == 1)
        {
            LaunchM50Grenade();
            return true;
        }
    }

    if (Mode == 1)
	{
		if (MeleeState != MS_None)
			return false;

		if (bM50GrenadePriming || bM50GrenadeLaunching || bM50GrenadeReloading)
			return false;

		if (AltAmmoLoaded <= 0)
			return StartM46GrenadeReload();

		if (Super.StartFire(Mode))
		{
			bM50GrenadePriming = true;
			PlayAnim('GrenadePrep', 1.0, 0.0);
			return true;
		}

		return false;
	}

    return Super.StartFire(Mode);
}


simulated function StopFire(int Mode)
{
    Super.StopFire(Mode);
}

simulated function LaunchM50Grenade()
{
    local Weapon_M46A2Rifle_MineProjectile Mine;
    local Vector SpawnLocation;
    local Rotator SpawnRotation;

    if (!bM50GrenadePrimed)
        return;

    if (bM50GrenadeLaunching)
        return;

    if (Role == ROLE_Authority && AltAmmoLoaded <= 0)
    {
        bM50GrenadePriming = false;
        bM50GrenadePrimed = false;
        IdleAnim = default.IdleAnim;
        IdleAimAnim = default.IdleAimAnim;
        return;
    }

    bM50GrenadePriming = false;
    bM50GrenadePrimed = false;
    bM50GrenadeLaunching = true;

    IdleAimAnim = default.IdleAimAnim;

    if (bAimingRifle)
        PlayAnim('SightGrenadeFire', 1.0, 0.0);
    else
        PlayAnim('GrenadeFire', 1.0, 0.0);

    if (Instigator != None && Instigator.IsLocallyControlled() && FireMode[1] != None)
        Weapon_M50Rifle_SecondaryFire(FireMode[1]).TriggerGrenadeFlash();

    if (Role != ROLE_Authority)
        return;

    if (Instigator == None)
        return;

    SpawnRotation = Instigator.GetViewRotation();

    SpawnLocation = Instigator.Location
        + vect(0,0,1) * Instigator.EyeHeight
        + Vector(SpawnRotation) * (Instigator.CollisionRadius + 32.0);

    Mine = Spawn(class'Weapon_M46A2Rifle_MineProjectile', Instigator,, SpawnLocation, SpawnRotation);

    if (Mine == None)
        return;

    // Consume the chambered grenade after successfully spawning the projectile.
    AltAmmoLoaded = 0;

    if (M50GrenadeLaunchSound != None)
        PlaySound(M50GrenadeLaunchSound,, 1.0,, 256.0);

    Mine.Instigator = Instigator;
    Mine.InstigatorController = Instigator.Controller;

    Mine.Velocity = Vector(SpawnRotation) * 2700.0;
    Mine.SetPhysics(PHYS_Falling);
}

simulated function AnimEnd(int Channel)
{
    local name AnimName;
    local name SavedReloadAnim;
    local name SavedResumeAnim;
    local float AnimFrame;
    local float AnimRate;

    if (Channel == 0)
    {
        GetAnimParams(0, AnimName, AnimFrame, AnimRate);

        // Grenade preparation finished.
        if (bM50GrenadePriming)
        {
            bM50GrenadePriming = false;
            bM50GrenadePrimed = true;

            IdleAnim = 'GrenadeIdle';
            IdleAimAnim = 'GrenadeIdle';
            LoopAnim('GrenadeIdle', 1.0, 0.0);
            return;
        }

        // Grenade firing finished.
        if (bM50GrenadeLaunching)
        {
            bM50GrenadeLaunching = false;

            IdleAnim = default.IdleAnim;
            IdleAimAnim = default.IdleAimAnim;
            PlayIdle();
            return;
        }

        // Grenade reload finished.
        if (bM50GrenadeReloading)
        {
            bM50GrenadeReloading = false;

            IdleAnim = 'Idle';
            IdleAimAnim = default.IdleAimAnim;
            PlayIdle();
            return;
        }

        SavedReloadAnim = ReloadAnim;
        SavedResumeAnim = WeaponReloadResumeAnimation;

        // Allow the inherited reload completion logic to recognise ReloadEmpty.
        if (AnimName == 'ReloadEmpty')
            ReloadAnim = 'ReloadEmpty';

        // Allow the inherited resume completion logic to recognise ReloadResumeEmpty.
        if (AnimName == 'ReloadResumeEmpty')
            WeaponReloadResumeAnimation = 'ReloadResumeEmpty';

        Super.AnimEnd(Channel);

        ReloadAnim = SavedReloadAnim;
        WeaponReloadResumeAnimation = SavedResumeAnim;
        return;
    }

    Super.AnimEnd(Channel);
}

simulated function bool IsM46GrenadeActionLocked()
{
    return bM50GrenadePriming || bM50GrenadePrimed || bM50GrenadeLaunching;
}

exec function ReloadMeNow()
{
    local name SavedReloadAnim;

    if (IsM46GrenadeActionLocked() || bM50GrenadeReloading)
        return;

    if (bIsReloading || bBallisticReload || bBallisticAltReload || bBallisticReloadClipIn || bReloadPending)
        return;

    // Primary ammunition always takes priority.
    if (MagAmmoRemaining < MagCapacity && AllowReload())
    {
        SavedReloadAnim = ReloadAnim;
        bM50EmptyReload = (MagAmmoRemaining <= 0);

        if (bM50EmptyReload)
            ReloadAnim = 'ReloadEmpty';

        Super.ReloadMeNow();

        ReloadAnim = SavedReloadAnim;
        return;
    }

    // If primary ammunition cannot be reloaded, try the grenade launcher.
    StartM46GrenadeReload();
}

simulated function bool InterruptReload()
{
    if (MagAmmoRemaining <= 0)
        WeaponReloadResumeAnimation = 'ReloadResumeEmpty';
    else
        WeaponReloadResumeAnimation = 'ReloadResume';

    return Super.InterruptReload();
}

exec function ReloadAlt()
{
    if (IsM46GrenadeActionLocked())
        return;

    Super.ReloadAlt();
}

simulated function MeleeHoldImpl()
{
    if (IsM46GrenadeActionLocked() || MeleeState != MS_None)
        return;

    Super.MeleeHoldImpl();
}

function InitializeM50GrenadeAmmo()
{
    if (Role != ROLE_Authority || bM50AmmoInitialized)
        return;

    if (AltAmmoLoaded > 0)
    {
        bM50AmmoInitialized = true;
        return;
    }

    if (AmmoAmount(1) > 0 && ConsumeAmmo(1, 1))
    {
        AltAmmoLoaded = 1;
        bM50AmmoInitialized = true;
    }
}

simulated function bool StartM46GrenadeReload()
{
    if (AltAmmoLoaded > 0 || bM50GrenadeReloading)
        return false;
		
	if (MeleeState != MS_None)
		return false;

    if (bM50GrenadePriming || bM50GrenadePrimed || bM50GrenadeLaunching)
        return false;

    if (bIsReloading || bBallisticReload || bBallisticAltReload || bBallisticReloadClipIn)
        return false;

    if (AmmoAmount(1) <= 0)
        return false;

    // Exit iron sights before starting the grenade reload.
    if (bAimingRifle)
    {
        ZoomOut(true);

        if (KFHumanPawn(Instigator) != None)
            KFHumanPawn(Instigator).SetAiming(false);

        bAimingRifle = false;
    }

    bM50GrenadeReloading = true;
    PlayAnim('GrenadeReload', 1.0, 0.0);

    return true;
}

simulated function Notify_GrenadeOpen()
{
    if (GrenOpenSound != None)
        PlaySound(GrenOpenSound,, 1.0,, 256.0);
}

simulated function Notify_GrenadeIn()
{
    if (GrenLoadSound != None)
        PlaySound(GrenLoadSound,, 1.0,, 256.0);

    if (Role == ROLE_Authority && AltAmmoLoaded <= 0 && AmmoAmount(1) > 0)
    {
        if (ConsumeAmmo(1, 1))
            AltAmmoLoaded = 1;
    }
}

simulated function Notify_GrenadeClose()
{
    if (GrenCloseSound != None)
        PlaySound(GrenCloseSound,, 1.0,, 256.0);
}

simulated function int GetAltAmmoChamber()
{
    return AltAmmoLoaded;
}

simulated function bool PutDown()
{
    local bool bWasGrenadePrimed;

    bWasGrenadePrimed = bM50GrenadePrimed;

    bM50GrenadePriming = false;
    bM50GrenadePrimed = false;
    bM50GrenadeLaunching = false;
    bM50GrenadeReloading = false;

    IdleAnim = default.IdleAnim;
    IdleAimAnim = default.IdleAimAnim;

    if (bWasGrenadePrimed)
        PutDownAnim = 'PutawayGrenade';
    else
        PutDownAnim = default.PutDownAnim;

    return Super.PutDown();
}


//=============================================================================
// M50 Cleanup
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    bM50GrenadeReloading = false;

    InitializeM50GrenadeAmmo();
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    M50GrenadeLaunchSound=Sound'BWKF_M46_SN.M46.OA-AR_FireGren'
	GrenOpenSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenOpen'
	GrenLoadSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenLoad'
	GrenCloseSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenClose'

	bHasSecondaryAmmo=True
	AltAmmoLoaded=1
	bReduceMagAmmoOnSecondaryFire=False
	bShowAltAmmoChamber=True
	
	FireModeClass(0)=Class'BW_WD001_KF.Weapon_M50Rifle_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_M50Rifle_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_M50Rifle_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_M50Rifle_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M50Rifle_Attachment'
	
	WeaponReloadAnim=Reload_AK47
    ItemName="M50 Assault Rifle"
    Description="Enravion's crowning achievement, the M50 is the most extensively used weapon in the UTC military corps. The M50 is renowned for its accuracy, damage and reliability in the field. The sturdy M50 was extensively used in both wars and has helped annihilate countless Skrith, Krao and Cryon warriors. The weapon also has the advantage of launching a grenade from the attached M900, for flushing out enemies."
	
    MagCapacity=30

    Mesh=Mesh'BWKF_M50_A.M50_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
	CurrentWeaponMode=2

    Priority=3
    InventoryGroup=3
    GroupOffset=2
    Weight=8.000000

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True
	bModeZeroCanDryFire=True

	HudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A2_Unselected'
    SelectedHudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A2_Selected'
	TraderInfoTexture=Texture'BWKF_M46_T.Icons.MedIcon_M46A2'

    PlayerViewOffset=(X=2.000000,Y=13.000000,Z=-5.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    //SightFXClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_SightLEDs'
    SightFXBone="M50"
    ClipHitSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipIn')
	CockSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Cock')
}