class Utility_NRXGrenade_Main extends BallisticHandGrenade;

defaultproperties
{
    FireModeClass(0)=Class'BW_WD000_KF.Utility_NRXGrenade_PrimaryFire'
    FireModeClass(1)=Class'BW_WD000_KF.Utility_NRXGrenade_SecondaryFire'
	PickupClass=Class'BW_WD000_KF.Utility_NRXGrenade_Pickup'
	MeleeFireClass=Class'Utility_NRXGrenade_MeleeFire'
	AttachmentClass=Class'BW_WD000_KF.Utility_NRXGrenade_Attachment'
	
	AmmoClass(0)=Class'BW_WD000_KF.Utility_NRXGrenade_Ammo'
	AmmoClass(1)=Class'BW_WD000_KF.Utility_NRXGrenade_Ammo'

    bKFNeverThrow=True
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-40.000000)
	PlayerViewPivot=(Yaw=0)
	
	Mesh=Mesh'BWKF_NRXS_A.NRXS_FP_Mesh'
	ItemName="NRX-82 'Scarab' Cluster Grenade"
	Description="Black and Woods has been seeing massive success during the Skrith Wars, their weapons and devices being used across the galaxy to drive back the alien hordes and even against their fellow man in some cases.  They could rest on their laurels, but they're still going strong with a sidegrade to their long-standing hand grenade. Recently unveiled is the NRX-82 Cluster Grenade, known affectionately as the ''Scarab.'' It has earned that moniker thanks to the cluster bombs it spews out after the main explosion, wiping out small crowds of Skrith or anyone in the blast zone. While it hasn't been out in the field quite yet, they're getting painted yellow to match their older models, tricking Skrith into thinking they're pineapples just like before."
    
    GrenadePinPullSound=(Sound=Sound'BWKF_NRXS_SN.NRXS.NRXS-PullRingOut',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
    GrenadePinPushSound=(Sound=Sound'BWKF_NRXS_SN.NRXS.NRXS-PutRingIn',Volume=1.000000,Radius=24.000000,Slot=SLOT_Interact,Pitch=1.000000,bAtten=True)
	
	HudImage=texture'BWKF_NRXS_T.Icons.MedIcon_NRXS_Unselected'
    SelectedHudImage=texture'BWKF_NRXS_T.Icons.MedIcon_NRXS_Selected'
   	TraderInfoTexture=texture'BWKF_NRXS_T.Icons.MedIcon_NRXS'
}