class Tool_WD200_Main extends BallisticMeleeWeapon;

defaultproperties
{
	FireModeClass(0)=Class'Tool_WD200_PrimaryFire'
	FireModeClass(1)=Class'Tool_WD200_SecondaryFire'
	AttachmentClass=None
	MeleeFireClass=Class'Tool_WD200_MeleeFire'
	PickupClass=Class'BW_WD000_KF.Tool_WD200_Pickup'
	
	Mesh=SkeletalMesh'BWKF_WD200_A.CombatWelder_FP_Mesh'
	PlayerViewOffset=(X=10.000000,Y=-2.000000,Z=-15.000000)
	InventoryGroup=5
    GroupOffset=1
	
	WeaponModes(0)=(ModeName="Semi",ModeID="WM_SemiAuto",Value=1.000000,bUnavailable=True)
    WeaponModes(1)=(ModeName="Burst",ModeID="WM_Burst",Value=3.000000,bUnavailable=True)
    WeaponModes(2)=(ModeName="Weld",ModeID="WM_FullAuto")
	CurrentWeaponMode=2
	
	PulloutSound=(Sound=Sound'BWKF_A909_SN.A909.A909Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_A909_SN.A909.A909Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	Description=""
	
	bKFNeverThrow=True
	bAmmoHUDAsBar=False
	bShowChargingBar=False
}