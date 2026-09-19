//=============================================================================
// Knife Inventory class
//=============================================================================
class Weapon_A909Blades_Main extends BallisticMeleeWeapon;

defaultproperties
{

    WeaponRange=65.000000
    BloodyMaterial=Combiner'KF_Weapons_Trip_T.melee.knife_bloody_cmb'
    BloodSkinSwitchArray=100
    bSpeedMeUp=True
    Weight=0.000000
    bKFNeverThrow=True
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_A909Blades_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_A909Blades_SecondaryFire'
	MeleeFireClass=Class'BW_WD001_KF.Weapon_A909Blades_MeleeFire'
    SelectSound=Sound'KF_KnifeSnd.Knife_Select'
    Description="The A909 Skrith Blades are a common Skrith melee weapon. They were a terrible bane of the human armies during the first war. The Skrith used them ruthlessly and with great skill to viciously slice up their enemies. Though the blades are useless at range, they are capable of great harm if the user can sneak up on an opponent. All or most Skrith warriors seem to prefer melee battle, and as such hone their skill with close range weapons. The blades can be extremely deadly when close up, as they can jab and slice very fast."
    Priority=45
    SmallViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
    GroupOffset=1
    PickupClass=Class'BW_WD001_KF.Weapon_A909Blades_Pickup'
    BobDamping=8.000000
    AttachmentClass=Class'BW_WD001_KF.Weapon_A909Blades_Attachment'
    IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
    ItemName="A909 Skrith Blades"
    Mesh=SkeletalMesh'BWKF_A909_A.A909_FP_Mesh'
	PlayerViewOffset=(X=30.000000,Z=-15.000000)
    AmbientGlow=0

    AIRating=0.2
    CurrentRating=0.2

	PulloutSound=(Sound=Sound'BWKF_A909_SN.A909.A909Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_A909_SN.A909.A909Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)

    HudImage=texture'BWKF_A909_T.Icon.MedIcon_A909Unselected'
    SelectedHudImage=texture'BWKF_A909_T.Icon.MedIcon_A909Selected'
   	TraderInfoTexture=texture'BWKF_A909_T.Icon.MedIcon_A909'
}
