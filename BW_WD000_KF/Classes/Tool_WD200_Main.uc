class Tool_WD200_Main extends BallisticMeleeWeapon;

var() float AmmoRegenRate;
var float AmmoRegenCount;

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if( AmmoAmount(0) < FireMode[0].AmmoClass.Default.MaxAmmo )
	{
		AmmoRegenCount += DeltaTime * AmmoRegenRate;
		ConsumeAmmo(0, -1 * int(AmmoRegenCount));
		AmmoRegenCount -= int(AmmoRegenCount);
	}
}

simulated function float ChargeBar()
{
	return FMin(1, (AmmoAmount(0))/(FireMode[0].AmmoClass.Default.MaxAmmo));
}

defaultproperties
{
	FireModeClass(0)=Class'Tool_WD200_PrimaryFire'
	FireModeClass(1)=Class'Tool_WD200_SecondaryFire'
	AttachmentClass=Class'Tool_WD200_Attachment'
	MeleeFireClass=Class'Tool_WD200_MeleeFire'
	PickupClass=Class'BW_WD000_KF.Tool_WD200_Pickup'
	
	Mesh=SkeletalMesh'BWKF_WD200_A.CombatWelder_FP_Mesh'
	PlayerViewOffset=(X=10.000000,Y=-2.000000,Z=-15.000000)
	InventoryGroup=5
	GroupOffset=1
	
	WeaponModes(2)=(ModeName="Weld",ModeID="WM_FullAuto")
	CurrentWeaponMode=2
	
    PulloutSound=(Sound=Sound'BWKF_M806_SN.M806Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_M806_SN.M806Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	ItemName="WD-200 Combat Welder"
	Description="The WD-200 Combat Welder is a heavy-duty industrial welding tool that has found an unexpected place on the battlefield. Originally designed for emergency repairs, cutting through damaged machinery, and sealing breaches, its rugged construction and powerful welding arc made it surprisingly effective in close combat. The WD-200 produces an intense electrical arc capable of inflicting severe burns at close range. Though useless at distance, it can be devastating against heavily armoured targets, while its reinforced housing allows it to withstand considerable punishment. What began as an improvised weapon for desperate engineers eventually became a recognised battlefield tool, favoured by those willing to get dangerously close to their enemies."
	HudImage=Texture'BWKF_WD200_T.Icons.MedIcon_WD200_Unselected'
	SelectedHudImage=Texture'BWKF_WD200_T.Icons.MedIcon_WD200_Selected'
	
	Weight=0.000000
	bKFNeverThrow=True
	bAmmoHUDAsBar=True
	bShowChargingBar=True
	bConsumesPhysicalAmmo=False
	AmmoRegenRate=40.000000
}