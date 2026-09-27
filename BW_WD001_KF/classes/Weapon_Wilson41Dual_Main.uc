class Weapon_Wilson41Dual_Main extends BallisticWeapon;

simulated function int GetAltAmmoChamber()
{
    return AltAmmoLoaded;
}

function DropFrom(vector StartLocation)
{
    local int m;
    local Pickup Pickup;
    local Inventory I;
    local int AmmoThrown, OtherAmmo;
    local int AltAmmoThrown, OtherAltAmmo;

    if (!bCanThrow)
        return;

    AmmoThrown = AmmoAmount(0);
    AltAmmoThrown = AmmoAmount(1);

    ClientWeaponThrown();

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m].bIsFiring)
            StopFire(m);
    }

    if (Instigator != None)
        DetachFromPawn(Instigator);

    if (Instigator.Health > 0)
    {
        OtherAmmo = AmmoThrown / 2;
        AmmoThrown -= OtherAmmo;

        OtherAltAmmo = AltAmmoThrown / 2;
        AltAmmoThrown -= OtherAltAmmo;

        I = Spawn(Class'Weapon_Wilson41_Main');

        if (I != None)
        {
            I.GiveTo(Instigator);

            Weapon(I).Ammo[0].AmmoAmount = OtherAmmo;
            Weapon(I).Ammo[1].AmmoAmount = OtherAltAmmo;

            Weapon_Wilson41_Main(I).MagAmmoRemaining = MagAmmoRemaining / 2;
            Weapon_Wilson41_Main(I).AltAmmoLoaded = 1;

            MagAmmoRemaining = Max(
                MagAmmoRemaining - Weapon_Wilson41_Main(I).MagAmmoRemaining,
                0
            );

            AltAmmoLoaded = Max(
                AltAmmoLoaded - Weapon_Wilson41_Main(I).AltAmmoLoaded,
                0
            );
        }
    }

    Pickup = Spawn(PickupClass,,, StartLocation);

    if (Pickup != None)
    {
        Pickup.InitDroppedPickupFor(self);
        Pickup.Velocity = Velocity;

        WeaponPickup(Pickup).AmmoAmount[0] = AmmoThrown;
        WeaponPickup(Pickup).AmmoAmount[1] = AltAmmoThrown;

        if (KFWeaponPickup(Pickup) != None)
            KFWeaponPickup(Pickup).MagAmmoRemaining = MagAmmoRemaining;

        if (Instigator.Health > 0)
            WeaponPickup(Pickup).bThrown = true;
    }

    Destroyed();
    Destroy();
}

function GiveTo(pawn Other, optional Pickup Pickup)
{
	local Inventory I;
	local int OldAmmo;
	local int OldAltAmmo;
	local bool bNoPickup;

	MagAmmoRemaining = 0;

	For (I = Other.Inventory; I != None; I = I.Inventory)
	{
		if (Weapon_Wilson41_Main(I) != None)
		{
			if (WeaponPickup(Pickup) != None)
			{
				WeaponPickup(Pickup).AmmoAmount[0] += Weapon(I).AmmoAmount(0);
				WeaponPickup(Pickup).AmmoAmount[1] += Weapon(I).AmmoAmount(1);
			}
			else
			{
				OldAmmo = Weapon(I).AmmoAmount(0);
				OldAltAmmo = Weapon(I).AmmoAmount(1);
				bNoPickup = true;
			}

			MagAmmoRemaining = Weapon_Wilson41_Main(I).MagAmmoRemaining;

			I.Destroyed();
			I.Destroy();

			Break;
		}
	}

	if (KFWeaponPickup(Pickup) != None && Pickup.bDropped)
		MagAmmoRemaining = Clamp(MagAmmoRemaining + KFWeaponPickup(Pickup).MagAmmoRemaining, 0, MagCapacity);
	else
		MagAmmoRemaining = Clamp(MagAmmoRemaining + Class'Weapon_Wilson41_Main'.Default.MagCapacity, 0, MagCapacity);

	Super(Weapon).GiveTo(Other, Pickup);

	if (bNoPickup)
	{
		AddAmmo(OldAmmo, 0);
		AddAmmo(OldAltAmmo, 1);
		Clamp(Ammo[0].AmmoAmount, 0, MaxAmmo(0));
		Clamp(Ammo[1].AmmoAmount, 0, MaxAmmo(1));
	}
}


simulated function ClientReload()
{
    if (MagAmmoRemaining == 17)
        ReloadAnim = 'ReloadRight';
    else if (MagAmmoRemaining == 0 && AmmoAmount(0) == 1)
        ReloadAnim = 'ReloadLeft';
    else
        ReloadAnim = 'Reload';

    Super.ClientReload();
}

simulated function bool AllowAltReload()
{
    return AltAmmoLoaded < 2 && AmmoAmount(1) > 0;
}

simulated function PlayAltReloadAnimation()
{
    if (AltAmmoLoaded == 0 && AmmoAmount(1) == 1)
    {
        WeaponReloadAltAnimation = 'ReloadAltLeft';
        WeaponReloadAltResumeAnimation = 'ReloadAltResumeLeft';
    }
    else if (AltAmmoLoaded == 1)
    {
        WeaponReloadAltAnimation = 'ReloadAltRight';
        WeaponReloadAltResumeAnimation = 'ReloadAltResume';
    }
    else
    {
        WeaponReloadAltAnimation = 'ReloadAlt';
        WeaponReloadAltResumeAnimation = 'ReloadAltResume';
    }

    Super.PlayAltReloadAnimation();
}

simulated function PlayAltReloadResumeAnimation()
{
    if (BallisticReloadStage >= 2 || (AltAmmoLoaded == 0 && AmmoAmount(1) == 1))
        WeaponReloadAltResumeAnimation = 'ReloadAltResumeLeft';
    else
        WeaponReloadAltResumeAnimation = 'ReloadAltResume';

    Super.PlayAltReloadResumeAnimation();
}

simulated function name GetDualAltFireAnim(bool bLeft)
{
    if (bLeft)
        return 'FireLeftAlt';

    return 'FireRightAlt';
}

simulated function name GetDualAltSightFireAnim(bool bLeft)
{
    if (bLeft)
        return 'SightFireLeftAlt';

    return 'SightFireRightAlt';
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_Wilson41Dual_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_Wilson41Dual_SecondaryFire'
    MeleeFireClass=Class'BW_WD001_KF.Weapon_Wilson41Dual_MeleeFire'
    PickupClass=Class'BW_WD001_KF.Weapon_Wilson41Dual_Pickup'
    AttachmentClass=Class'BW_WD001_KF.Weapon_Wilson41Dual_Attachment'
	
	bHasSecondaryAmmo=True
	AltAmmoLoaded=2
	bReduceMagAmmoOnSecondaryFire=False
	WeaponReloadAnim=Reload_DualFlare
    ItemName="Dual Wilson 41-DB LeMat Revolvers"
    Description="An expensive remake of an exceptionally old weapon, the Wilson 41-DB was designed for collectors and procurers of rare items from the early days of human firearms. Manufactured by the Edwinson & Sons arms co, this firearm is of high quality, sparse quantity and very high price. Never used in any military or law enforcement organisation, the Wilson 'DiamondBack', is still capable of causing damage. With a 9 cylinder revolver and single 16 gauge shotgun chamber for desperate moments, this weapon can still stop many opponents.""

    bShovelLoad=False
    MagCapacity=18

    Mesh=Mesh'BWKF_Wilson_A.WilsonDual_FP_Mesh'

	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000)
	WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
	WeaponModes(2)=(ModeName="Auto",ModeID="WM_FullAuto",bUnavailable=True)
	CurrentWeaponMode=0

    Priority=3
    InventoryGroup=2
    GroupOffset=100
    Weight=4.000000
    bModeZeroCanDryFire=True
    SellValue=300

    PlayerIronSightFOV=65
    ZoomTime=0.25
    FastZoomOutTime=0.2
    bHasAimingMode=True
	bShowAltAmmoChamber=True
	
	bDualWeapon=True
	
	HudImage=Texture'BWKF_Wilson_T.Icons.MedIcon_Wilson41DBDual_Unselected'
    SelectedHudImage=Texture'BWKF_Wilson_T.Icons.MedIcon_Wilson41DBDual_Selected'
	TraderInfoTexture=Texture'BWKF_Wilson_T.Icons.MedIcon_Wilson41DBDual'
	AltAmmoIcon=Texture'BWKF_Wilson_T.Icons.Hud_ShotgunShell'

    ClipOutSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-BulletsOut')
    ClipInSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-BulletsIn')
	CockSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-Cock')
	SlideInSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-Close')
	SlideOutSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-Open')
	
	ClipOutAltSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-ShellOut')
	ClipInAltSound=(Sound=Sound'BWKF_Wilson_SN.Wilson.LM-ShellIn')

	ZoomInRotation=(Pitch=0,Yaw=0,Roll=0)
    PlayerViewOffset=(X=7.000000,Y=0.000000,Z=-7.000000)
    SelectSoundRef="BWKF_M806_SN.M806Pullout"
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    SightFXClass=Class'BW_WD001_KF.Weapon_Wilson41_SightLEDs'
    SightFXBone="Front"
	LeftSightFXClass=Class'BW_WD001_KF.Weapon_Wilson41_SightLEDs'
    LeftSightFXBone="Front-2"
    SkinRefs(0)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(1)=Texture'BWKF_Core_T.Misc.Invisible-Tex'
    SkinRefs(2)=Shader'BWKF_Wilson_T.Weapon.leMat_Shine'
    SkinRefs(3)=Texture'BWKF_Wilson_T.Weapon.leMat_Shield'
    SkinRefs(4)=Texture'BWKF_Wilson_T.Weapon.leMat_Speed'
}