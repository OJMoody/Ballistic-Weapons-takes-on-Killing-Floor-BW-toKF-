class Weapon_RX22AFlamer_Main extends BallisticWeapon;

var float HeatLevel;
var Weapon_RX22AFlamer_Heater Heater;

var() BUtil.FullSound PackOnSound;
var() BUtil.FullSound LeverOnSound;
var() BUtil.FullSound LeverOffSound;

var Weapon_RX22AFlamer_FireControl FireControl;

var Weapon_RX22AFlamer_Spray Flame;
var Weapon_RX22AFlamer_GasSpray GasSpray;

var() name ValveAnim;

replication
{
    reliable if (Role == ROLE_Authority)
        FireControl;
}

simulated function PostNetBeginPlay()
{
    local Weapon_RX22AFlamer_FireControl FC;

    Super.PostNetBeginPlay();

    if (Role == ROLE_Authority && FireControl == None)
    {
        foreach DynamicActors(class'Weapon_RX22AFlamer_FireControl', FC)
        {
            if (FC.Class == class'Weapon_RX22AFlamer_FireControl')
            {
                FireControl = FC;
                return;
            }
        }

        FireControl = Spawn(class'Weapon_RX22AFlamer_FireControl');
    }
}

function Weapon_RX22AFlamer_FireControl GetFireControl()
{
    return FireControl;
}

simulated function Notify_RX22APackOn()
{
    class'BUtil'.static.PlayFullSound(self, PackOnSound);
}

simulated function Notify_RX22ALeverOn()
{
    class'BUtil'.static.PlayFullSound(self, LeverOnSound);
}

simulated function Notify_RX22ALeverOff()
{
    class'BUtil'.static.PlayFullSound(self, LeverOffSound);
}

simulated function vector ConvertFOVs(vector InVec, float InFOV, float OutFOV, float Distance)
{
    local vector ViewLoc, OutVec, Dir, X, Y, Z;
    local rotator ViewRot;

    ViewLoc = Instigator.Location + Instigator.EyePosition();
    ViewRot = Instigator.GetViewRotation();
    Dir = InVec - ViewLoc;

    GetAxes(ViewRot, X, Y, Z);

    OutVec.X = Distance / Tan(OutFOV * PI / 360);
    OutVec.Y = (Dir dot Y) * (Distance / Tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec.Z = (Dir dot Z) * (Distance / Tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec = OutVec >> ViewRot;

    return OutVec + ViewLoc;
}

simulated event RenderOverlays(Canvas C)
{
    Super.RenderOverlays(C);

    if (Instigator == None || Instigator.Controller == None)
        return;

    if (Flame != None)
    {
        Flame.SetLocation(ConvertFOVs(GetBoneCoords('tip').Origin, DisplayFOV, Instigator.Controller.FovAngle, 32));
        Flame.SetRotation(Instigator.GetViewRotation());
        C.DrawActor(Flame, false, false, Instigator.Controller.FovAngle);
    }
    else if (GasSpray != None)
    {
        GasSpray.SetLocation(ConvertFOVs(GetBoneCoords('tip').Origin + vector(Instigator.GetViewRotation()) * 32, DisplayFOV, Instigator.Controller.FovAngle, 32));
        GasSpray.SetRotation(Instigator.GetViewRotation());
        C.DrawActor(GasSpray, false, false, Instigator.Controller.FovAngle);
    }
}

simulated event Tick(float DT)
{
    Super.Tick(DT);

    if (HeatLevel > 0)
    {
        if (PhysicsVolume != None)
        {
            if (PhysicsVolume.bWaterVolume)
            {
                HeatLevel = FMax(0, HeatLevel - DT * 5);
            }
            else
            {
                if (BallisticInstantFire(FireMode[0]).LastFireTime < Level.TimeSeconds - 4)
                    HeatLevel = FMax(0, HeatLevel - DT / 10);
            }
        }
        else
        {
            if (BallisticInstantFire(FireMode[0]).LastFireTime < Level.TimeSeconds - 4)
                HeatLevel = FMax(0, HeatLevel - DT / 10);
        }
    }
}

simulated function WeaponTick(float DT)
{
    Super.WeaponTick(DT);

    if (FireMode[0] != None && FireMode[0].IsFiring() && Weapon_RX22AFlamer_PrimaryFire(FireMode[0]) != None && Weapon_RX22AFlamer_PrimaryFire(FireMode[0]).bIgnited)
        HeatLevel = FMin(1, HeatLevel + DT / 6);

    if (Heater != None)
        Heater.SetHeat(HeatLevel);
}

simulated event Destroyed()
{
    if (Flame != None)
        Flame.bHidden = false;

    if (GasSpray != None)
        GasSpray.bHidden = false;

    if (Heater != None)
        Heater.Destroy();

    Super.Destroyed();
}

defaultproperties
{
    PackOnSound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-PackOn',Volume=0.600000,Radius=24.000000,Pitch=1.000000)
    LeverOnSound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-LeverOn',Volume=0.600000,Radius=24.000000,Pitch=1.000000)
    LeverOffSound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-LeverOff',Volume=0.600000,Radius=24.000000,Pitch=1.000000)

    ValveAnim="TurnValve"
	
	HudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A2_Unselected'
    SelectedHudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A2_Selected'
	TraderInfoTexture=Texture'BWKF_M46_T.Icons.MedIcon_M46A2'

    SelectSoundRef="BWKF_RX22A_SN.RX22A.RX22A-Pullout"
	PulloutSound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-Pullout')
    PutAwaySound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-Putaway')
    ClipOutSound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-PipeOut')
    ClipInSound=(Sound=Sound'BWKF_RX22A_SN.RX22A.RX22A-PipeIn')

    FireModeClass(0)=Class'BW_WD001_KF.Weapon_RX22AFlamer_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_RX22AFlamer_SecondaryFire'
	PickupClass=Class'BW_WD001_KF.Weapon_RX22AFlamer_Pickup'
	//MeleeFireClass=Class'BW_WD001_KF.Weapon_RX22AFlamer_MeleeFire'
    //AttachmentClass=Class'BW_WD001_KF.Weapon_RX22AFlamer_Attachment'
	
	//SightFXClass=Class'BW_WD001_KF.Weapon_RX22AFlamer_SightLEDs'
    //SightFXBone="Weapon"
	
	MagCapacity=90
	
	Priority=4
    InventoryGroup=4
    GroupOffset=1
	Weight=12.000000
	
	PlayerIronSightFOV=65
    ZoomTime=0.4
	FastZoomOutTime=0.3
	bHasAimingMode=True
	bModeZeroCanDryFire=True

    PlayerViewOffset=(X=4.000000,Y=6.000000,Z=-2.000000)
	PlayerViewPivot=(Yaw=0)

    ItemName="RX-22A Flamethrower"

    LightType=LT_Pulse
    LightEffect=LE_NonIncidence
    LightHue=30
    LightSaturation=150
    LightBrightness=150.000000
    LightRadius=4.000000

    Mesh=SkeletalMesh'BWKF_RX22A_A.RX22A_FP_Mesh'
    DrawScale=0.300000

    bFullVolume=True
    SoundRadius=128.000000
}