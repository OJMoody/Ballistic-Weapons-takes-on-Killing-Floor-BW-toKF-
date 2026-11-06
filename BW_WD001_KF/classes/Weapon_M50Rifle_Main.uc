class Weapon_M50Rifle_Main extends BallisticWeapon;

//=============================================================================
// Grenade
//=============================================================================

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
// LASER POINTER
//=============================================================================

var() BallisticLaserActor_FPStandard Laser;
var() Emitter LaserDot;


//=============================================================================
// Alt Grenade Firing
//=============================================================================

simulated function bool StartFire(int Mode)
{
	if (bLaserToggleInProgress)
		return false;
	
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
			return StartM50GrenadeReload();

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
    local Weapon_M50Rifle_Grenade Mine;
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
	
	IncrementFlashCount(1);

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

    Mine = Spawn(class'Weapon_M50Rifle_Grenade', Instigator,, SpawnLocation, SpawnRotation);

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

simulated function bool IsM50GrenadeActionLocked()
{
    return bM50GrenadePriming || bM50GrenadePrimed || bM50GrenadeLaunching;
}

exec function ReloadMeNow()
{
    local name SavedReloadAnim;

    if (IsM50GrenadeActionLocked() || bM50GrenadeReloading)
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
    StartM50GrenadeReload();
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
    if (IsM50GrenadeActionLocked())
        return;

    Super.ReloadAlt();
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

simulated function bool StartM50GrenadeReload()
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
// LASER TOGGLE
//=============================================================================

simulated function RequestLaserToggle()
{
    if (!bHasLaser ||
        bM50GrenadeReloading ||
        IsM50GrenadeActionLocked())
        return;

    Super.RequestLaserToggle();
}

simulated function PlayIdle()
{
    if (bLaserToggleInProgress)
        return;

    Super.PlayIdle();
}

simulated function ClientReload()
{
    if (bLaserToggleInProgress)
        return;

    Super.ClientReload();
}

simulated function MeleeHoldImpl()
{
    if (bLaserToggleInProgress || IsM50GrenadeActionLocked() || MeleeState != MS_None)
        return;

    Super.MeleeHoldImpl();
}

function ServerToggleLaser()
{
    if (bM50GrenadeReloading || IsM50GrenadeActionLocked())
        return;

    Super.ServerToggleLaser();
}


//=============================================================================
// CLIENT LASER SWITCH
//=============================================================================

simulated function ClientSwitchLaser()
{
    if (ThirdPersonActor != None)
        Weapon_M50Rifle_Attachment(ThirdPersonActor).bLaserOn = bLaserOn;

    if (bLaserOn)
        SpawnLaserDot();
    else
        KillLaserDot();
}

//=============================================================================
// LASER DOT
//=============================================================================

simulated function SpawnLaserDot(optional Vector Loc)
{
    if (LaserDot == None)
    {
        LaserDot = Spawn(
            class'Weapon_M806Pistol_LaserDot',
            ,
            ,
            Loc
        );
    }
}

simulated function KillLaserDot()
{
    if (LaserDot != None)
    {
        LaserDot.Kill();
        LaserDot = None;
    }
}


//=============================================================================
// FOV CONVERSION
//=============================================================================

simulated function Vector ConvertFOVs(
    Vector InVec,
    float InFOV,
    float OutFOV,
    float Distance
)
{
    local Vector ViewLoc;
    local Vector OutVec;
    local Vector Dir;
    local Vector X;
    local Vector Y;
    local Vector Z;
    local Rotator ViewRot;

    ViewLoc = Instigator.Location + Instigator.EyePosition();
    ViewRot = Instigator.GetViewRotation();

    Dir = InVec - ViewLoc;

    GetAxes(ViewRot, X, Y, Z);

    OutVec.X = Distance / Tan(OutFOV * PI / 360);

    OutVec.Y =
        (Dir dot Y) *
        (Distance / Tan(InFOV * PI / 360)) /
        (Dir dot X);

    OutVec.Z =
        (Dir dot Z) *
        (Distance / Tan(InFOV * PI / 360)) /
        (Dir dot X);

    OutVec = OutVec >> ViewRot;

    return OutVec + ViewLoc;
}


//=============================================================================
// FIRST PERSON LASER
//=============================================================================

simulated function DrawLaserSight(Canvas Canvas)
{
    local Vector HitLocation;
    local Vector Start;
    local Vector End;
    local Vector HitNormal;
    local Vector Scale3D;
    local Vector Loc;

    local Coords LaserCoords;
    local Actor Other;

    if (ClientState == WS_Hidden ||
        !bLaserOn ||
        Instigator == None ||
        Instigator.Controller == None ||
        Laser == None)
        return;

    // Laser origin on the M50 first-person mesh.
    LaserCoords = GetBoneCoords('lasertip');

    Loc = LaserCoords.Origin;
    Start = Loc;

    End = Start + Normal(LaserCoords.XAxis) * 5000;

    Other = FireMode[0].Trace(
        HitLocation,
        HitNormal,
        End,
        Start,
        true
    );

    if (Other == None)
        HitLocation = End;

    if (LaserDot == None)
        SpawnLaserDot(HitLocation);

    if (LaserDot != None)
    {
        LaserDot.SetLocation(HitLocation);

        Canvas.DrawActor(
            LaserDot,
            false,
            false,
            Instigator.Controller.FovAngle
        );
    }

    Laser.SetLocation(Loc);

    HitLocation = ConvertFOVs(
        HitLocation,
        Instigator.Controller.FovAngle,
        DisplayFOV,
        400
    );

    Laser.SetRotation(Rotator(HitLocation - Loc));

    Scale3D.X = VSize(HitLocation - Loc) / 128;
    Scale3D.Y = 1.0;
    Scale3D.Z = 1.0;

    Laser.SetDrawScale3D(Scale3D);

    Canvas.DrawActor(
        Laser,
        false,
        false,
        DisplayFOV
    );
}

simulated event RenderOverlays(Canvas Canvas)
{
    Super.RenderOverlays(Canvas);

    if (!IsInState('Lowered'))
        DrawLaserSight(Canvas);
}


//=============================================================================
// LASER CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (Laser != None)
        Laser.Destroy();

    if (LaserDot != None)
        LaserDot.Destroy();

    Super.Destroyed();
}


//=============================================================================
// M50 Cleanup
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    bM50GrenadeReloading = false;

    InitializeM50GrenadeAmmo();

    if (Instigator != None &&
        Laser == None &&
        PlayerController(Instigator.Controller) != None)
    {
        Laser = Spawn(class'BallisticLaserActor_FPStandard');
    }

    if (ThirdPersonActor != None)
        Weapon_M50Rifle_Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	bHasLaser=True
	LaserBatteryClass=class'Weapon_M806Pistol_LaserBattery'
    LaserToggleAnim=LightOnOff
    LaserOnSound=Sound'BWKF_M806_SN.M806.M806LSight'
    LaserOffSound=Sound'BWKF_M806_SN.M806.M806LSight'
	
	M50GrenadeLaunchSound=Sound'BWKF_M50_SN.M50.M50GrenFire'
	GrenOpenSound=Sound'BWKF_M50_SN.M50.M50GrenOpen'
	GrenLoadSound=Sound'BWKF_M50_SN.M50.M50GrenLoad'
	GrenCloseSound=Sound'BWKF_M50_SN.M50.M50GrenClose'

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
    Weight=7.000000

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True
	bModeZeroCanDryFire=True

	HudImage=Texture'BWKF_M50_T.Icons.MedIcon_M50_Unselected'
    SelectedHudImage=Texture'BWKF_M50_T.Icons.MedIcon_M50_Selected'
	TraderInfoTexture=Texture'BWKF_M50_T.Icons.MedIcon_M50'

    PlayerViewOffset=(X=2.000000,Y=13.000000,Z=-5.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M50_SN.M50.M50Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M50_SN.M50.M50Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    SightFXClass=Class'BW_WD001_KF.Weapon_M50Rifle_SightLEDS'
    SightFXBone="M50"
    ClipHitSound=(Sound=Sound'BWKF_M50_SN.M50.M50ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M50_SN.M50.M50ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M50_SN.M50.M50ClipIn')
	CockSound=(Sound=Sound'BWKF_M50_SN.M50.M50Cock')
}