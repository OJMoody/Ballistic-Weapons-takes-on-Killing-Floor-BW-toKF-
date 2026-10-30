class Weapon_M46A2Rifle_Main extends BallisticWeapon;

var bool bM46MinePriming;
var bool bM46MinePrimed;
var bool bM46MineLaunching;
var bool bM46GrenadeReloading;
var bool bM46AmmoInitialized;
var bool bM46EmptyReload;

var() Sound M46MineLaunchSound;

var() Sound GrenOpenSound;
var() Sound GrenLoadSound;
var() Sound GrenCloseSound;

//=============================================================================
// Alt Grenade Firing
//=============================================================================

simulated function bool StartFire(int Mode)
{
    if (bM46MinePrimed)
    {
        if (bM46MineLaunching)
            return false;

        if (Mode == 0 || Mode == 1)
        {
            LaunchM46Mine();
            return true;
        }
    }

    if (Mode == 1)
    {
        if (bM46MinePriming || bM46MineLaunching || bM46GrenadeReloading)
            return false;

        if (AltAmmoLoaded <= 0)
            return StartM46GrenadeReload();

        if (Super.StartFire(Mode))
        {
            bM46MinePriming = true;
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

simulated function LaunchM46Mine()
{
    local Weapon_M46A2Rifle_MineProjectile Mine;
    local Vector SpawnLocation;
    local Rotator SpawnRotation;

    if (!bM46MinePrimed)
        return;

    if (bM46MineLaunching)
        return;

    if (Role == ROLE_Authority && AltAmmoLoaded <= 0)
    {
        bM46MinePriming = false;
        bM46MinePrimed = false;
        IdleAnim = default.IdleAnim;
        IdleAimAnim = default.IdleAimAnim;
        return;
    }

    bM46MinePriming = false;
    bM46MinePrimed = false;
    bM46MineLaunching = true;

    IdleAimAnim = default.IdleAimAnim;

    if (bAimingRifle)
        PlayAnim('SightGrenadeFire', 1.0, 0.0);
    else
        PlayAnim('GrenadeFire', 1.0, 0.0);

    if (Instigator != None && Instigator.IsLocallyControlled() && FireMode[1] != None)
        Weapon_M46A2Rifle_SecondaryFire(FireMode[1]).TriggerGrenadeFlash();

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

    if (M46MineLaunchSound != None)
        PlaySound(M46MineLaunchSound,, 1.0,, 256.0);

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
        if (bM46MinePriming)
        {
            bM46MinePriming = false;
            bM46MinePrimed = true;

            IdleAnim = 'GrenadeIdle';
            IdleAimAnim = 'GrenadeIdle';
            LoopAnim('GrenadeIdle', 1.0, 0.0);
            return;
        }

        // Grenade firing finished.
        if (bM46MineLaunching)
        {
            bM46MineLaunching = false;

            IdleAnim = default.IdleAnim;
            IdleAimAnim = default.IdleAimAnim;
            PlayIdle();
            return;
        }

        // Grenade reload finished.
        if (bM46GrenadeReloading)
        {
            bM46GrenadeReloading = false;

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

simulated function bool IsM46MineActionLocked()
{
    return bM46MinePriming || bM46MinePrimed || bM46MineLaunching;
}

exec function ReloadMeNow()
{
    local name SavedReloadAnim;

    if (IsM46MineActionLocked() || bM46GrenadeReloading)
        return;

    if (bIsReloading || bBallisticReload || bBallisticAltReload || bBallisticReloadClipIn || bReloadPending)
        return;

    // Primary ammunition always takes priority.
    if (MagAmmoRemaining < MagCapacity && AllowReload())
    {
        SavedReloadAnim = ReloadAnim;
        bM46EmptyReload = (MagAmmoRemaining <= 0);

        if (bM46EmptyReload)
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
    if (IsM46MineActionLocked())
        return;

    Super.ReloadAlt();
}

simulated function MeleeHoldImpl()
{
    if (IsM46MineActionLocked())
        return;

    Super.MeleeHoldImpl();
}

function InitializeM46GrenadeAmmo()
{
    if (Role != ROLE_Authority || bM46AmmoInitialized)
        return;

    if (AltAmmoLoaded > 0)
    {
        bM46AmmoInitialized = true;
        return;
    }

    if (AmmoAmount(1) > 0 && ConsumeAmmo(1, 1))
    {
        AltAmmoLoaded = 1;
        bM46AmmoInitialized = true;
    }
}

simulated function bool StartM46GrenadeReload()
{
    if (AltAmmoLoaded > 0 || bM46GrenadeReloading)
        return false;

    if (bM46MinePriming || bM46MinePrimed || bM46MineLaunching)
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

    bM46GrenadeReloading = true;
    PlayAnim('GrenadeReload', 1.0, 0.0);

    return true;
}

simulated function Notify_OAARGrenadeOpen()
{
    if (GrenOpenSound != None)
        PlaySound(GrenOpenSound,, 1.0,, 256.0);
}

simulated function Notify_OAARGrenadeIn()
{
    if (GrenLoadSound != None)
        PlaySound(GrenLoadSound,, 1.0,, 256.0);

    if (Role == ROLE_Authority && AltAmmoLoaded <= 0 && AmmoAmount(1) > 0)
    {
        if (ConsumeAmmo(1, 1))
            AltAmmoLoaded = 1;
    }
}

simulated function Notify_OAARGrenadeClose()
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

    bWasGrenadePrimed = bM46MinePrimed;

    bM46MinePriming = false;
    bM46MinePrimed = false;
    bM46MineLaunching = false;
    bM46GrenadeReloading = false;

    IdleAnim = default.IdleAnim;
    IdleAimAnim = default.IdleAimAnim;

    if (bWasGrenadePrimed)
        PutDownAnim = 'PutawayGrenade';
    else
        PutDownAnim = default.PutDownAnim;

    return Super.PutDown();
}


//=============================================================================
// M46A1 Cleanup
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    bM46GrenadeReloading = false;

    InitializeM46GrenadeAmmo();

    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 0.0, 'Scope');
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    M46MineLaunchSound=Sound'BWKF_M46_SN.M46.OA-AR_FireGren'
	GrenOpenSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenOpen'
	GrenLoadSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenLoad'
	GrenCloseSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenClose'

	bHasSecondaryAmmo=True
	AltAmmoLoaded=1
	bReduceMagAmmoOnSecondaryFire=False
	bShowAltAmmoChamber=True
	
	FireModeClass(0)=Class'BW_WD001_KF.Weapon_M46A2Rifle_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_M46A2Rifle_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_Attachment'
	
	WeaponReloadAnim=Reload_AK47
    ItemName="M46A2 'Jackal' Combat Rifle"
    Description="The M46 was one of Black & Wood's first forays into high powered assault weaponry, specifically rifles. As with all of Black & Wood's weapons, the 'Jackal' is incredibly reliable and tough. Used by certain Terran units, the M46 is typically equipped with a short-range optical scope and often various Grenade Launcher attachments. While not quite yet a widely used weapon, its reputation has grown in recent times as heroic stories of Armoured Squadron 190's use of it has spread amongst the bulk of the UTC troops."

    MagCapacity=24

    Mesh=Mesh'BWKF_M46_A.M46A1_FP_Mesh'

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

    PlayerViewOffset=(X=45.000000,Y=38.000000,Z=-15.000000)
	PlayerViewPivot=(Yaw=0)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    SightFXClass=Class'BW_WD001_KF.Weapon_M46A2Rifle_SightLEDs'
    SightFXBone="OA-AR"
    ClipHitSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipIn')
	CockSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Cock')
	
	bScoped=False
	ScopeTextureOverlay=Texture'BWKF_M46_T.Scope.M46ScopeView'
	ScopeMaskMaterial=Texture'BWKF_M46_T.Scope.M46ScopeViewRender'
	ScopeFallbackMaterial=Combiner'BWKF_M46_T.Scope.M46Lens_cmb'
	ScopeLensMaterialID=2
}