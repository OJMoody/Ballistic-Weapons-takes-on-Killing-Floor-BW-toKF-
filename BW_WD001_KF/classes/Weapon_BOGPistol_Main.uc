class Weapon_BOGPistol_Main extends BallisticShotgun;

var bool bBOGReloadAnimFinished;

//=============================================================================
// SERVER FIRE
//=============================================================================

function ServerStopFire(byte Mode)
{
	Super(KFWeapon).ServerStopFire(Mode);

	if (MagCapacity == 1)
		MagAmmoRemaining = 0;
}

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
	BallisticReloadStage = 0;
	bBallisticReload = true;
	bIsReloading = true;
	bBOGReloadAnimFinished = false;
	ReloadTimer = Level.TimeSeconds;

	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);
}

simulated function ActuallyFinishReloading()
{
	if (bIsReloading && !bBOGReloadAnimFinished)
		return;

	Super.ActuallyFinishReloading();
}

simulated function AnimEnd(int Channel)
{
	local name AnimName;
	local float Frame;
	local float Rate;

	if (Channel == 0)
	{
		GetAnimParams(0, AnimName, Frame, Rate);

		if (bIsReloading && AnimName == ReloadAnim)
		{
			bBOGReloadAnimFinished = true;
			ActuallyFinishReloading();
			return;
		}
	}

	Super.AnimEnd(Channel);
}

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_BOGPistol_PrimaryFire'
    FireModeClass(1)=Class'KFMod.NoFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_BOGPistol_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_BOGPistol_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M806Pistol_Attachment'
	
	WeaponReloadAnim=Reload_Crossbow
	ItemName="BORT-85 Grenade Pistol"
	Description="BORT-85 Break Open Grenade Pistol||Manufacturer: NDTR Industries|Primary: Launch Grenade / Shot|Secondary: Switch Grenade type||The need for a simple and easy to use grenade launcher arose towards the end of the first war, especially in the large industrial zones of various Outworld colonies. Skrith favoured these areas, as they were perfect for the aliens which prefered to be hidden and strike with surprise. The simple design had several benefits, as it was relatively compact, and could fire many different types of ammunition."
    Mesh=Mesh'BWKF_BOGP_A.BOGP_FP_Mesh'
	bShovelLoad=False
    MagCapacity=1
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.650000
    CurrentRating=0.650000
    Priority=210
    InventoryGroup=2
    GroupOffset=3
    BobDamping=6.000000
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
    AmbientGlow=0
    ZoomInRotation=(Pitch=-910,Yaw=0,Roll=2910)
    bHasAimingMode=true
	bModeZeroCanDryFire=True
	Weight=4.000000
	
	//HudImageRef="KillingFloor2HUD.WeaponSelect.M32_unselected"
	//SelectedHudImageRef="KillingFloor2HUD.WeaponSelect.M32"
	//TraderInfoTexture=texture'KillingFloor2HUD.Trader_Weapon_Icons.Trader_M32'
	bHoldToReload=False
	PlayerViewOffset=(X=2.000000,Y=11.000000,Z=-7.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
	PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	//SightFXClass=Class'BW_WD001_KF.Weapon_M806Pistol_SightLEDs'
    SightFXBone="GrenadePistolBarrel"
    ClipOutSound=(Sound=Sound'BWKF_M806_SN.M806-ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M806_SN.M806-ClipIn')
	SkinRefs(0)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(1)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
	SkinRefs(2)=Texture'BWKF_BOGP_T.Weapon.BOGP_Main'
}