//=============================================================================
// Knife Inventory class
//=============================================================================
class Weapon_M909Blades_Main extends BallisticMeleeWeapon;

defaultproperties
{

    WeaponRange=65.000000
    BloodyMaterial=Combiner'KF_Weapons_Trip_T.melee.knife_bloody_cmb'
    BloodSkinSwitchArray=3
    bSpeedMeUp=True
    Weight=0.000000
    bKFNeverThrow=True
    FireModeClass(0)=Class'BW_WD001_KF.Weapon_M909Blades_PrimaryFire'
    FireModeClass(1)=Class'BW_WD001_KF.Weapon_M909Blades_SecondaryFire'
	MeleeFireClass=Class'BW_WD001_KF.Weapon_M909Blades_MeleeFire'
    SelectSound=Sound'KF_KnifeSnd.Knife_Select'
    Description="Military Combat Knife"
    Priority=45
    SmallViewOffset=(X=0.000000,Y=0.000000,Z=0.000000)
    GroupOffset=1
    PickupClass=Class'BW_WD001_KF.Weapon_M909Blades_Pickup'
    BobDamping=8.000000
    AttachmentClass=Class'BW_WD001_KF.Weapon_M909Blades_Attachment'
    IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
    ItemName="Knife"
    Mesh=SkeletalMesh'BWKF_M909_A.M909_FP_Mesh'
	PlayerViewOffset=(X=30.000000,Z=-15.000000)
    AmbientGlow=0

    AIRating=0.2
    CurrentRating=0.2

    //HudImage=texture'KillingFloorHUD.WeaponSelect.knife_unselected'
    //SelectedHudImage=texture'KillingFloorHUD.WeaponSelect.knife'
   	//TraderInfoTexture=texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Knife'
}
