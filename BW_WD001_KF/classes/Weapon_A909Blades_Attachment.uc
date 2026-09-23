class Weapon_A909Blades_Attachment extends BallisticAttachment ;

var Actor LeftOne;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (Instigator != None)
	{
		LeftOne = Spawn(class'Weapon_A909Blades_AttachmentLeft');
		Instigator.AttachToBone(LeftOne,'lefthand');
	}
}

simulated function Destroyed()
{
	if (LeftOne != None)
		LeftOne.Destroy();

	super.Destroyed();
}

defaultproperties
{
	Mesh=SkeletalMesh'BWKF_A909_A.A909_TPRight_Mesh'
	DrawScale=0.150000
	bDoFiringEffects=False

    MovementAnims(0)=JogF_Knife 
    MovementAnims(1)=JogB_Knife
    MovementAnims(2)=JogL_Knife
    MovementAnims(3)=JogR_Knife
    CrouchAnims(0)=CHwalkF_Knife
    CrouchAnims(1)=CHwalkB_Knife
    CrouchAnims(2)=CHwalkL_Knife
    CrouchAnims(3)=CHwalkR_Knife
    AirStillAnim=JumpF_Mid
    AirAnims(0)=JumpF_Mid
    AirAnims(1)=JumpF_Mid
    AirAnims(2)=JumpL_Mid
    AirAnims(3)=JumpR_Mid
    TakeoffStillAnim=JumpF_Takeoff
    TakeoffAnims(0)=JumpF_Takeoff
    TakeoffAnims(1)=JumpF_Takeoff
    TakeoffAnims(2)=JumpL_Takeoff
    TakeoffAnims(3)=JumpR_Takeoff
    LandAnims(0)=JumpF_Land
    LandAnims(1)=JumpF_Land
    LandAnims(2)=JumpL_Land
    LandAnims(3)=JumpR_Land

    TurnRightAnim=TurnR_Knife
    TurnLeftAnim=TurnL_Knife
    CrouchTurnRightAnim=CH_TurnR_Knife
    CrouchTurnLeftAnim=CH_TurnL_Knife
    IdleRestAnim=Idle_Knife//Idle_Rest
    IdleCrouchAnim=CHIdle_Knife
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_Knife//Idle_Rifle
    IdleHeavyAnim=Idle_Knife//Idle_Biggun
    IdleRifleAnim=Idle_Knife//Idle_Rifle
    IdleChatAnim=Idle_Knife
    FireAnims(0)=A909_BW_AttackLight1
    FireAnims(1)=A909_BW_AttackLight1
    FireAnims(2)=A909_BW_AttackLight2
    FireAnims(3)=A909_BW_AttackLight2
    FireAltAnims(0)=A909_BW_AttackHeavy1
    FireAltAnims(1)=A909_BW_AttackHeavy1
    FireAltAnims(2)=A909_BW_AttackHeavy1
    FireAltAnims(3)=A909_BW_AttackHeavy1
    FireCrouchAnims(0)=A909_BW_CHAttackLight1
    FireCrouchAnims(1)=A909_BW_CHAttackLight1
    FireCrouchAnims(2)=A909_BW_CHAttackLight2
    FireCrouchAnims(3)=A909_BW_CHAttackLight2
    FireCrouchAltAnims(0)=A909_BW_CHAttackHeavy1
    FireCrouchAltAnims(1)=A909_BW_CHAttackHeavy1
    FireCrouchAltAnims(2)=A909_BW_CHAttackHeavy1
    FireCrouchAltAnims(3)=A909_BW_CHAttackHeavy1
    HitAnims(0)=HitF_Knife
    HitAnims(1)=HitB_Knife
    HitAnims(2)=HitL_Knife
    HitAnims(3)=HitR_Knife
    PostFireBlendStandAnim=Blend_Knife
    PostFireBlendCrouchAnim=CHBlend_Knife
	
	MeleePrepAnim="A909_BW_MeleePrep1"
    MeleePrepIdleAnim="A909_BW_MeleePrepIdle1"
    MeleeFireAnim="A909_BW_MeleeFire1"
    MeleePrepCrouchAnim="A909_BW_CHMeleePrep1"
    MeleePrepIdleCrouchAnim="A909_BW_CHMeleePrepIdle1"
    MeleeFireCrouchAnim="A909_BW_CHMeleeFire1"
}
