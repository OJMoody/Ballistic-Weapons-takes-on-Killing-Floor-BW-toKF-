class Weapon_59MachinePistol_Main extends BallisticWeapon;

var() name StockOpenAnim;
var() name StockCloseAnim;
var bool bStockOpen;
var float StockSwitchTime;
var bool bStockOpenRotated;

var() BUtil.FullSound StockOutSound1;
var() BUtil.FullSound StockOutSound2;
var() BUtil.FullSound StockInSound;

var() float StockRecoilModifier;
var() float StockReloadModifier;
var float BaseReloadRate;
var float BaseReloadAnimRate;
var float BaseMaxVerticalRecoilAngle;
var float BaseMaxHorizontalRecoilAngle;
var bool bStockBaseValuesCached;

var bool bStockSwitching;

replication
{
    reliable if (Role < ROLE_Authority)
        ServerSwitchStock;
}

exec function ReloadMeNow()
{
    if (MagAmmoRemaining <= 0)
    {
        ReloadAnim = 'ReloadEmpty';
        WeaponReloadResumeAnimation = 'ReloadResumeEmpty';
    }
    else
    {
        ReloadAnim = 'Reload';
        WeaponReloadResumeAnimation = 'ReloadResume';
    }

    Super.ReloadMeNow();
}

simulated function bool IsActionLocked()
{
    return Super.IsActionLocked() || bStockSwitching;
}

function ServerSwitchStock(bool bNewValue)
{
    bStockOpen = bNewValue;
    ApplyStockModifiers();
    NetUpdateTime = Level.TimeSeconds - 1;
}

simulated function SwitchStock(bool bNewValue)
{
    bStockSwitching = true;

    ApplyStockModifiers();

    SetBoneRotation('Stock', rot(0,0,0));

    if (bNewValue)
        PlayAnim(StockOpenAnim);
    else
        PlayAnim(StockCloseAnim);
}

simulated function ToggleStock()
{
    if (Level.TimeSeconds < StockSwitchTime)
        return;

    if (ClientState != WS_ReadyToFire)
        return;

    if (MeleeState != MS_None)
        return;

    if (bIsReloading || bBallisticReload || bBallisticReloadClipIn || bShovelReload)
        return;

    if (bStockSwitching)
        return;

    bStockOpen = !bStockOpen;
    StockSwitchTime = Level.TimeSeconds + 1.5;

    SwitchStock(bStockOpen);

    if (Role < ROLE_Authority)
        ServerSwitchStock(bStockOpen);
}

simulated function bool StartFire(int Mode)
{
    if (bStockSwitching && Mode == 0)
        return false;

    if (Mode == 1)
    {
        if (bAimingRifle)
            PerformZoom(false);

        ToggleStock();
        return true;
    }

    return Super.StartFire(Mode);
}

simulated function SetStockRotation()
{
    if (bStockOpen)
    {
        SetBoneRotation('Stock', rot(32768,0,0));
        bStockOpenRotated = true;
    }
    else
    {
        SetBoneRotation('Stock', rot(0,0,0));
        bStockOpenRotated = false;
    }
}

simulated function PlayIdle()
{
    if (bStockOpen && !bStockOpenRotated)
        SetStockRotation();
    else if (!bStockOpen && bStockOpenRotated)
        SetStockRotation();

    if (bAimingRifle)
        LoopAnim(IdleAimAnim, IdleAnimRate, 0.0);
    else
        LoopAnim(IdleAnim, IdleAnimRate, 0.0);
}

simulated function AnimEnd(int Channel)
{
    if (Channel == 0)
    {
        if (bStockSwitching)
            bStockSwitching = false;

        if (bStockOpen)
            SetStockRotation();
        else if (bStockOpenRotated)
            SetStockRotation();
    }

    Super.AnimEnd(Channel);
}

simulated function Notify_Fifty9StockOut1()
{
    class'BUtil'.static.PlayFullSound(self, StockOutSound1, true);
}

simulated function Notify_Fifty9StockOut2()
{
    class'BUtil'.static.PlayFullSound(self, StockOutSound2, true);
}

simulated function Notify_Fifty9StockIn()
{
    class'BUtil'.static.PlayFullSound(self, StockInSound, true);
}

simulated function CacheStockBaseValues()
{
    local BallisticInstantFire PrimaryFire;

    if (bStockBaseValuesCached || FireMode[0] == None)
        return;

    BaseReloadRate = ReloadRate;
    BaseReloadAnimRate = ReloadAnimRate;

    PrimaryFire = BallisticInstantFire(FireMode[0]);

    if (PrimaryFire != None)
    {
        BaseMaxVerticalRecoilAngle = PrimaryFire.maxVerticalRecoilAngle;
        BaseMaxHorizontalRecoilAngle = PrimaryFire.maxHorizontalRecoilAngle;
    }

    bStockBaseValuesCached = true;
}

simulated function ApplyStockModifiers()
{
    local BallisticInstantFire PrimaryFire;
    local float RecoilScale;
    local float ReloadScale;

    CacheStockBaseValues();

    if (!bStockBaseValuesCached)
        return;

    PrimaryFire = BallisticInstantFire(FireMode[0]);

    RecoilScale = StockRecoilModifier;
    ReloadScale = StockReloadModifier;

    if (RecoilScale <= 0)
        RecoilScale = 1.0;

    if (ReloadScale <= 0)
        ReloadScale = 1.0;

    if (bStockOpen)
    {
        ReloadRate = BaseReloadRate * ReloadScale;
        ReloadAnimRate = BaseReloadAnimRate / ReloadScale;

        if (PrimaryFire != None)
        {
            PrimaryFire.maxVerticalRecoilAngle = BaseMaxVerticalRecoilAngle * RecoilScale;
            PrimaryFire.maxHorizontalRecoilAngle = BaseMaxHorizontalRecoilAngle * RecoilScale;
        }
    }
    else
    {
        ReloadRate = BaseReloadRate;
        ReloadAnimRate = BaseReloadAnimRate;

        if (PrimaryFire != None)
        {
            PrimaryFire.maxVerticalRecoilAngle = BaseMaxVerticalRecoilAngle;
            PrimaryFire.maxHorizontalRecoilAngle = BaseMaxHorizontalRecoilAngle;
        }
    }
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD002_KF.Weapon_59MachinePistol_PrimaryFire'
    FireModeClass(1)=Class'BW_WD002_KF.Weapon_59MachinePistol_SecondaryFire'
    MeleeFireClass=Class'BW_WD002_KF.Weapon_59MachinePistol_MeleeFire'
    PickupClass=Class'BW_WD002_KF.Weapon_59MachinePistol_Pickup'
    AttachmentClass=Class'BW_WD002_KF.Weapon_59MachinePistol_Attachment'
	
	StockOutSound1=(Sound=Sound'BWKF_59M_SN.UZI.UZI-StockOut1',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	StockOutSound2=(Sound=Sound'BWKF_59M_SN.UZI.UZI-StockOut2',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	StockInSound=(Sound=Sound'BWKF_59M_SN.UZI.UZI-StockIn',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	SelectSoundRef="BWKF_59M_SN.UZI.UZI-Pullout"
    PulloutSound=(Sound=Sound'BWKF_59M_SN.UZI.UZI-Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_59M_SN.UZI.UZI-Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	CockSound=(Sound=Sound'BWKF_59M_SN.UZI.UZI-Cock')
    ClipOutSound=(Sound=Sound'BWKF_59M_SN.UZI.UZI-ClipOut')
    ClipInSound=(Sound=Sound'BWKF_59M_SN.UZI.UZI-ClipIn')
	
	WeaponReloadAnim=Reload_Single9mm
    ItemName="Fifty-9 Machine Pistol"
    Description="Krome Firepower is a relatively new arms company created with the aim of producing guns with 'style'. The Fifty-9 is one such weapon. Taking an original small arm, and replacing certain parts, adding new attachments, custom paint jobs, etc. Krome weapons are designed for civilian purposes, self defense, bounty hunters, enthusiasts, and collectors. This particular model comes with attached Krome blades, to add some extra flair to the weapon."

    MagCapacity=25
	StockRecoilModifier=0.900000
	StockReloadModifier=1.250000
	StockOpenAnim="StockOut"
	StockCloseAnim="StockIn"

    Mesh=Mesh'BWKF_59M_A.59M_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto")
	CurrentWeaponMode=2

    Priority=3
    InventoryGroup=3
    GroupOffset=1
    Weight=4.000000
    bModeZeroCanDryFire=True
    SellValue=200
	bPlusOne=True

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True

	HudImage=Texture'BWKF_59M_T.Icons.MedIcon_Fifty9_Unselected'
    SelectedHudImage=Texture'BWKF_59M_T.Icons.MedIcon_Fifty9_Selected'
	TraderInfoTexture=Texture'BWKF_59M_T.Icons.MedIcon_Fifty9'

    PlayerViewOffset=(X=80.000000,Y=60.000000,Z=-20.000000)
	PlayerViewPivot=(Yaw=0)
    SightFXClass=Class'BW_WD002_KF.Weapon_59MachinePistol_SightLEDs'
    SightFXBone="tip"
}