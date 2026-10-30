class Weapon_M46A1Rifle_Main extends BallisticWeapon;

var bool bM46MinePriming;
var bool bM46MinePrimed;
var bool bM46MineLaunching;
var() Sound M46MineLaunchSound;

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
        if (bM46MinePriming || bM46MineLaunching)
            return false;

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
    local Weapon_M46A1Rifle_MineProjectile Mine;
    local Vector SpawnLocation;
    local Rotator SpawnRotation;

    Log("M46 DEBUG: LaunchM46Mine called. Role="$Role$" Primed="$bM46MinePrimed$" Launching="$bM46MineLaunching);

    if (!bM46MinePrimed)
    {
        Log("M46 DEBUG: Launch rejected - not primed.");
        return;
    }

    if (bM46MineLaunching)
    {
        Log("M46 DEBUG: Launch rejected - already launching.");
        return;
    }

    bM46MinePriming = False;
    bM46MinePrimed = False;
    bM46MineLaunching = True;

    if (bAimingRifle)
        PlayAnim('SightGrenadeFire', 1.0, 0.0);
    else
        PlayAnim('GrenadeFire', 1.0, 0.0);

    if (Role != ROLE_Authority)
    {
        Log("M46 DEBUG: Spawn skipped - not authority.");
        return;
    }

    if (Instigator == None)
    {
        Log("M46 DEBUG: Spawn failed - no Instigator.");
        return;
    }

    SpawnRotation = Instigator.GetViewRotation();

    SpawnLocation = Instigator.Location
        + vect(0,0,1) * Instigator.EyeHeight
        + Vector(SpawnRotation) * (Instigator.CollisionRadius + 32.0);

    Log("M46 DEBUG: Attempting projectile spawn at "$SpawnLocation);

    Mine = Spawn(
        class'Weapon_M46A1Rifle_MineProjectile',
        Instigator,
        ,
        SpawnLocation,
        SpawnRotation
    );

    if (Mine == None)
        return;
		
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
    local float Frame;
    local float Rate;

    if (Channel == 0)
    {
        GetAnimParams(0, AnimName, Frame, Rate);

        if (AnimName == 'GrenadePrep' && bM46MinePriming)
        {
            bM46MinePriming = false;
            bM46MinePrimed = true;
            LoopAnim('GrenadeIdle', 1.0, 0.0);
            return;
        }

        if ((AnimName == 'GrenadeFire' || AnimName == 'SightGrenadeFire') && bM46MineLaunching)
		{
			bM46MineLaunching = false;
			PlayIdle();
			return;
		}
    }

    Super.AnimEnd(Channel);
}

simulated function bool IsM46MineActionLocked()
{
    return bM46MinePriming || bM46MinePrimed || bM46MineLaunching;
}

exec function ReloadMeNow()
{
    if (IsM46MineActionLocked())
        return;

    Super.ReloadMeNow();
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

//=============================================================================
// M46A1 Cleanup
//=============================================================================

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    if (Instigator != None && Instigator.IsLocallyControlled())
        SetBoneScale(0, 0.0, 'RDS');
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    M46MineLaunchSound=Sound'BWKF_M46_SN.M46.OA-AR_FireGren'
	
	FireModeClass(0)=Class'BW_WD001_KF.Weapon_M46A1Rifle_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_M46A1Rifle_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_Attachment'
	
	WeaponReloadAnim=Reload_AK47
    ItemName="M46A1 'Jackal' Combat Rifle"
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

	HudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A1_Unselected'
    SelectedHudImage=Texture'BWKF_M46_T.Icons.MedIcon_M46A1_Selected'
	TraderInfoTexture=Texture'BWKF_M46_T.Icons.MedIcon_M46A1'

    PlayerViewOffset=(X=45.000000,Y=38.000000,Z=-15.000000)
	PlayerViewPivot=(Yaw=0)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    //SightFXClass=Class'BW_WD001_KF.Weapon_M46A1Rifle_SightLEDs'
    SightFXBone="OA-AR"
    ClipHitSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipHit')
    ClipOutSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipOut')
    ClipInSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_ClipIn')
	CockSound=(Sound=Sound'BWKF_M46_SN.M46.OA-AR_Cock')
	
	bScoped=True
	ScopeTextureOverlay=Texture'BWKF_M46_T.Scope.M46ScopeView'
	ScopeMaskMaterial=Texture'BWKF_M46_T.Scope.M46ScopeViewRender'
	ScopeFallbackMaterial=Combiner'BWKF_M46_T.Scope.M46Lens_cmb'
	ScopeLensMaterialID=2
}