class Weapon_M806DualPistol_Main extends BallisticWeapon;

#exec OBJ LOAD FILE="BWKF_M806_SN.uax"

//=============================================================================
// LASER POINTER
//=============================================================================

var() bool bHasLaser;
var() bool bLaserOn;

var() Sound LaserOnSound;
var() Sound LaserOffSound;

var() BallisticLaserActor_FPStandard Laser;
var() Emitter LaserDot;

var() bool bLaserBatteryProxy;
var() bool bLaserBatteryShutdown;

var bool bLaserToggleInProgress;

var() name LaserToggleAnim;

//=============================================================================
// REPLICATION
//=============================================================================

replication
{
    reliable if (Role == ROLE_Authority)
        bLaserOn;

    reliable if (Role < ROLE_Authority)
        ServerStartLaserToggle;
}

simulated function ZoomIn(bool bAnimateTransition)
{
	Super.ZoomIn(bAnimateTransition);

	if (bAnimateTransition)
	{
		UpdateM806AnimationSet();

		if (SightIronsAnim != '' && HasAnim(SightIronsAnim))
			PlayAnim(SightIronsAnim, 1.0, 0.1);
	}
}


simulated function ZoomOut(bool bAnimateTransition)
{
	local float AnimLength;
	local float AnimSpeed;

	Super.ZoomOut(false);

	if (bAnimateTransition)
	{
		UpdateM806AnimationSet();

		AnimLength = GetAnimDuration(SightHipAnim, 1.0);

		if (ZoomTime > 0 && AnimLength > 0)
			AnimSpeed = AnimLength / ZoomTime;
		else
			AnimSpeed = 1.0;

		if (SightHipAnim != '' && HasAnim(SightHipAnim))
			PlayAnim(SightHipAnim, AnimSpeed, 0.1);
	}
}

//=============================================================================
// M806 ANIMATION STATE
//=============================================================================

simulated function bool IsChamberOpen()
{
	return MagAmmoRemaining <= 2;
}

simulated function name GetDualFireAnim(bool bLeft)
{
	if (MagAmmoRemaining <= 0)
		return 'FireLeftOpen';

	if (MagAmmoRemaining == 1 && !bLeft)
		return 'FireRightOpen';

	if (bLeft)
		return 'FireLeft';

	return 'FireRight';
}

simulated function name GetDualSightFireAnim(bool bLeft)
{
	if (MagAmmoRemaining <= 0)
		return 'SightFireLeftOpen';

	if (MagAmmoRemaining == 1 && !bLeft)
		return 'SightFireRightOpen';

	if (bLeft)
		return 'SightFireLeft';

	return 'SightFireRight';
}

simulated function UpdateM806AnimationSet()
{
	//=========================================================================
	// IDLE
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		IdleAnim = 'IdleOpen';
	else if (MagAmmoRemaining == 1)
		IdleAnim = 'IdleOpenRight';
	else
		IdleAnim = 'Idle';


	//=========================================================================
	// IDLE AIM
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		IdleAimAnim = 'SightIdleOpen';
	else if (MagAmmoRemaining == 1)
		IdleAimAnim = 'SightIdleOpenRight';
	else
		IdleAimAnim = 'SightIdle';


	//=========================================================================
	// RELOAD
	//=========================================================================
	// To be added.


	//=========================================================================
	// FIRE
	//=========================================================================

	if (MagAmmoRemaining <= 0)
	{
		FireAnimLeft = 'FireLeftOpen';
		FireAnimRight = 'FireRightOpen';
	}
	else
	{
		FireAnimLeft = 'FireLeft';
		FireAnimRight = 'FireRight';
	}


	//=========================================================================
	// SIGHT FIRE
	//=========================================================================

	if (MagAmmoRemaining <= 0)
	{
		SightFireAnimLeft = 'SightFireLeftOpen';
		SightFireAnimRight = 'SightFireRightOpen';
	}
	else
	{
		SightFireAnimLeft = 'SightFireLeft';
		SightFireAnimRight = 'SightFireRight';
	}


	//=========================================================================
	// SIGHT FIRE
	//=========================================================================
	// To be added.


	//=============================================================================
	// SIGHT HIP
	//=============================================================================

	if (MagAmmoRemaining <= 0)
		SightHipAnim = 'SightHipOpen';
	else if (MagAmmoRemaining == 1)
		SightHipAnim = 'SightHipOpenRight';
	else
		SightHipAnim = 'SightHip';


	//=============================================================================
	// SIGHT IDLE
	//=============================================================================

	if (MagAmmoRemaining <= 0)
		IdleAimAnim = 'SightIdleOpen';
	else if (MagAmmoRemaining == 1)
		IdleAimAnim = 'SightIdleOpenRight';
	else
		IdleAimAnim = 'SightIdle';


	//=============================================================================
	// SIGHT IRONS
	//=============================================================================

	if (MagAmmoRemaining <= 0)
		SightIronsAnim = 'SightIronsOpen';
	else if (MagAmmoRemaining == 1)
		SightIronsAnim = 'SightIronsOpenRight';
	else
		SightIronsAnim = 'SightIrons';


	//=========================================================================
	// PULLOUT
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		SelectAnim = 'PulloutOpen';
	else if (MagAmmoRemaining == 1)
		SelectAnim = 'PulloutOpenRight';
	else
		SelectAnim = 'Pullout';


	//=========================================================================
	// PUTAWAY
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		PutDownAnim = 'PutawayOpen';
	else if (MagAmmoRemaining == 1)
		PutDownAnim = 'PutawayOpenRight';
	else
		PutDownAnim = 'Putaway';


	//=========================================================================
	// LASER
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		LaserToggleAnim = 'LightOnOffOpen';
	else if (MagAmmoRemaining == 1)
		LaserToggleAnim = 'LightOnOffOpenRight';
	else
		LaserToggleAnim = 'LightOnOff';
		
		
	//=========================================================================
	// MELEE FIRE
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		MeleeFireAnim = 'MeleeFireOpen';
	else if (MagAmmoRemaining == 1)
		MeleeFireAnim = 'MeleeFireOpenRight';
	else
		MeleeFireAnim = 'MeleeFire';


	//=========================================================================
	// MELEE PREP
	//=========================================================================

	if (MagAmmoRemaining <= 0)
		MeleePrepAnim = 'MeleePrepOpen';
	else if (MagAmmoRemaining == 1)
		MeleePrepAnim = 'MeleePrepOpenRight';
	else
		MeleePrepAnim = 'MeleePrep';

	if (MeleeFireMode != None)
	{
		MeleeFireMode.FireAnim = MeleeFireAnim;
		MeleeFireMode.PreFireAnim = MeleePrepAnim;
	}


	//=========================================================================
	// RELOAD RESUME
	//=========================================================================
	// To be added.
}


simulated function PlayIdle()
{
	UpdateM806AnimationSet();

	Super.PlayIdle();
}


simulated function ClientReload()
{
	UpdateM806AnimationSet();

	Super.ClientReload();
}


simulated function bool IsActionLocked()
{
	return bLaserToggleInProgress;
}


//=============================================================================
// SERVER LASER TOGGLE
//=============================================================================

function ServerStartLaserToggle()
{
    if (!bHasLaser)
        return;

    if (bIsReloading)
        return;

    if (Instigator != None && Instigator.IsLocallyControlled())
        StartLaserToggleAnimation();
}

simulated function RequestLaserToggle()
{
    if (!bHasLaser)
        return;

    if (bIsReloading)
        return;

    if (bLaserToggleInProgress)
        return;

    if (KFHumanPawn(Instigator) != None)
    {
        if (KFHumanPawn(Instigator).TorchBatteryLife <= 0)
            return;
    }

    StartLaserToggleAnimation();
}


//=============================================================================
// CLIENT ANIMATION
//=============================================================================

simulated function StartLaserToggleAnimation()
{
    if (ClientState == WS_Hidden)
        return;

    if (bLaserToggleInProgress)
        return;

    UpdateM806AnimationSet();

    bLaserToggleInProgress = true;

    PlayAnim(LaserToggleAnim, 1.000000, 0.000000);
}

simulated function MeleeHoldImpl()
{
    if (bLaserToggleInProgress)
        return;

    Super.MeleeHoldImpl();
}

simulated function AnimEnd(int Channel)
{
    if (Channel == 0 && bLaserToggleInProgress)
    {
        bLaserToggleInProgress = false;
    }

    Super.AnimEnd(Channel);
}

//=============================================================================
// ANIMATION NOTIFIER
//=============================================================================

simulated function Notify_LaserToggle()
{
    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (bLaserBatteryShutdown)
    {
        bLaserOn = false;
        bLaserBatteryShutdown = false;

        if (FlashLight != None)
            FlashLight.bHasLight = false;

        if (ThirdPersonActor != None)
            Weapon_M806DualPistol_Attachment(ThirdPersonActor).bLaserOn = false;

        ClientSwitchLaser();

        PlaySound(Sound'BWKF_M806_SN.M806.M806LSight',, 0.7,, 32);

        return;
    }

    bLaserOn = !bLaserOn;

    EnsureLaserBatteryProxy();

    if (FlashLight != None)
        FlashLight.bHasLight = bLaserOn;

    if (ThirdPersonActor != None)
        Weapon_M806DualPistol_Attachment(ThirdPersonActor).bLaserOn = bLaserOn;

    ClientSwitchLaser();

    PlaySound(Sound'BWKF_M806_SN.M806.M806LSight',, 0.7,, 32);
}


//=============================================================================
// NETWORK LASER UPDATE
//=============================================================================

simulated event PostNetReceive()
{
    if (Level.NetMode == NM_Client)
    {
        if (bLaserOn != default.bLaserOn)
        {
            default.bLaserOn = bLaserOn;

            ClientSwitchLaser();
        }
    }

    Super.PostNetReceive();
}


//=============================================================================
// CLIENT LASER SWITCH
//=============================================================================

simulated function ClientSwitchLaser()
{
    if (bLaserOn)
    {
        SpawnLaserDot();
    }
    else
    {
        KillLaserDot();
    }
}

simulated function EnsureLaserBatteryProxy()
{
    if (FlashLight == None)
    {
        FlashLight = Spawn(
            class'Weapon_M806Pistol_LaserBattery',
            Instigator
        );
    }
}

function LightFire()
{
    RequestLaserToggle();
}


//=============================================================================
// LASER BATTERY
//=============================================================================

simulated function CheckLaserBattery()
{
    local KFHumanPawn KFPawn;

    if (!bLaserOn)
        return;

    KFPawn = KFHumanPawn(Instigator);

    if (KFPawn == None)
        return;

    if (KFPawn.TorchBatteryLife <= 0 && !bLaserBatteryShutdown)
    {
        bLaserBatteryShutdown = true;

        if (FlashLight != None)
            FlashLight.bHasLight = false;

        StartLaserToggleAnimation();
    }
}

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    CheckLaserBattery();
}


//=============================================================================
// BRING UP
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    UpdateM806AnimationSet();

    Super.BringUp(PrevWeapon);

    UpdateM806AnimationSet();

    if (Instigator != None &&
        Laser == None &&
        PlayerController(Instigator.Controller) != None)
    {
        Laser = Spawn(
            class'BallisticLaserActor_FPStandard'
        );
    }

    if (ThirdPersonActor != None)
    {
        Weapon_M806DualPistol_Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
    }
}


//=============================================================================
// PUT DOWN
//=============================================================================

simulated function bool PutDown()
{
    UpdateM806AnimationSet();

    if (Super.PutDown())
    {
        bLaserToggleInProgress = false;
        bLaserOn = false;

        if (FlashLight != None)
            FlashLight.bHasLight = false;

        KillLaserDot();

        if (ThirdPersonActor != None)
        {
            Weapon_M806DualPistol_Attachment(ThirdPersonActor).bLaserOn = false;
        }

        return true;
    }

    return false;
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

    GetAxes(
        ViewRot,
        X,
        Y,
        Z
    );

    OutVec.X =
        Distance /
        Tan(OutFOV * PI / 360);

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

    if (ClientState == WS_Hidden || !bLaserOn || Instigator == None || Instigator.Controller == None || Laser == None)
        return;

    //=========================================================================
    // LASER BONE
    //=========================================================================

    LaserCoords = GetBoneCoords('laserPoint');

    Loc = LaserCoords.Origin;

    Start = Loc;

    //=========================================================================
    // LASER AIM
    //=========================================================================

    End = Start + Normal(LaserCoords.XAxis) * 5000;

    //=========================================================================
    // TRACE
    //=========================================================================

    Other = FireMode[0].Trace(
        HitLocation,
        HitNormal,
        End,
        Start,
        true
    );

    if (Other == None)
        HitLocation = End;

    //=========================================================================
    // LASER DOT
    //=========================================================================

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

    //=========================================================================
    // LASER BEAM
    //=========================================================================

    Laser.SetLocation(Loc);

    HitLocation = ConvertFOVs(
        HitLocation,
        Instigator.Controller.FovAngle,
        DisplayFOV,
        400
    );

    Laser.SetRotation(
        Rotator(HitLocation - Loc)
    );

    Scale3D.X = VSize(HitLocation - Loc) / 128;
    Scale3D.Y = 1.000000;
    Scale3D.Z = 1.000000;

    Laser.SetDrawScale3D(Scale3D);

    Canvas.DrawActor(
        Laser,
        false,
        false,
        DisplayFOV
    );
}


//=============================================================================
// RENDER
//=============================================================================

simulated event RenderOverlays(Canvas Canvas)
{
    Super.RenderOverlays(Canvas);

    if (!IsInState('Lowered'))
        DrawLaserSight(Canvas);
}


//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    default.bLaserOn = false;

    if (Laser != None)
        Laser.Destroy();

    if (LaserDot != None)
        LaserDot.Destroy();

    Super.Destroyed();
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    bHasLaser=True

    LaserOnSound=Sound'BWKF_M806_SN.M806.M806LSight'
    LaserOffSound=Sound'BWKF_M806_SN.M806.M806LSight'

    FireModeClass(0)=Class'BW_WD001_KF.Weapon_M806DualPistol_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_M806DualPistol_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_M806DualPistol_MeleeFire'

    PickupClass=Class'BW_WD001_KF.Weapon_M806DualPistol_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M806DualPistol_Attachment'

    ItemName="M806A2 Pistol"
    Description=""

    bShovelLoad=False
    MagCapacity=16
    bShowChargingBar=True
    bTorchEnabled=True

    Mesh=Mesh'BWKF_M806_A.M806Dual_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
	CurrentWeaponMode=0
	
    Priority=3
    InventoryGroup=2
    GroupOffset=100
    Weight=0.000000
    bModeZeroCanDryFire=True
    SellValue=-1
	bDualWeapon=True
    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True

	HudImage=Texture'BWKF_M806_T.Icons.MedIcon_M806_Unselected'
    SelectedHudImage=Texture'BWKF_M806_T.Icons.MedIcon_M806'
	ZoomInRotation=(Pitch=0,Yaw=0,Roll=0)
    PlayerViewOffset=(X=3.000000,Y=0.500000,Z=-2.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    SightFXClass=Class'BW_WD001_KF.Weapon_M806Pistol_SightLEDs'
    SightFXBone="Slide"
	LeftSightFXClass=Class'BW_WD001_KF.Weapon_M806Pistol_SightLEDs'
    LeftSightFXBone="Slide-2"
    ClipHitSound=(Sound=Sound'BWKF_M806_SN.M806-ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M806_SN.M806-ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M806_SN.M806-ClipIn')
    SkinRefs(0)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(1)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(2)=Shader'BWKF_M806_T.Weapon.M806Weapon-Shine'
    SkinRefs(3)=Texture'BWKF_M806_T.Weapon.M806-Laser-Tex'
}