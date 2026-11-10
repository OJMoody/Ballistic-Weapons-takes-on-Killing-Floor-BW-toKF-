//=============================================================================
// EKS-43 Katana
//=============================================================================
class Weapon_EKS43Katana_Main extends BallisticMeleeWeapon;

defaultproperties
{

    WeaponRange=110.000000
    BloodyMaterial=Combiner'KF_Weapons_Trip_T.melee.knife_bloody_cmb'
    BloodSkinSwitchArray=100
    bSpeedMeUp=True
    Weight=6.000000
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_EKS43Katana_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_EKS43Katana_SecondaryFire'
	MeleeFireClass=Class'BW_WD001_KF.Weapon_EKS43Katana_MeleeFire'
    SelectSound=Sound'BWKF_EKS43_SN.EKS43.EKS-Putaway'
    Description="The EKS-43 sword is one of a few weapons produced by Enravion, not designed for widescale military use. It is an expenisve artefact preferred by collectors and other rare procurers. The blade is forged by the use of both ancient techniques and the most modern technology, making it a mighty weapon with incredible sharpness and legendary Enravion strength. Civilians use the weapon for various training and other personal purposes, while several mercenary groups, most notably, the highly skilled 'Apocalytes', adopted the weapon for use with their more skilled warriors."
    Priority=45
    SmallViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
    GroupOffset=1
    PickupClass=Class'BW_WD001_KF.Weapon_EKS43Katana_Pickup'
    BobDamping=8.000000
    AttachmentClass=Class'BW_WD001_KF.Weapon_EKS43Katana_Attachment'
    IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
    ItemName="EKS-43 Katana"
    Mesh=SkeletalMesh'BWKF_EKS43_A.EKS43_FP_Mesh'
	PlayerViewOffset=(X=20.000000,Z=-10.000000)
    AmbientGlow=0

    AIRating=0.2
    CurrentRating=0.2

	PulloutSound=(Sound=Sound'BWKF_EKS43_SN.EKS43.EKS-Pullout',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    PutAwaySound=(Sound=Sound'BWKF_EKS43_SN.EKS43.EKS-Putaway',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)

    HudImage=texture'BWKF_EKS43_T.Icon.MedIcon_EKS43_Unselected'
    SelectedHudImage=texture'BWKF_EKS43_T.Icon.MedIcon_EKS43_Selected'
   	TraderInfoTexture=texture'BWKF_EKS43_T.Icon.MedIcon_EKS43'
}
