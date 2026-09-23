class BallisticAttachment extends KFWeaponAttachment;

#exec OBJ LOAD FILE="..\..\Animations\BWKF_Third_A.ukx" PACKAGE=BWKF_Third_A

var() float mMuzFlashScale;

var class<Actor> BallisticHitEffectClass;

var Pawn LinkedAnimPawn;

var() name MeleePrepAnim;
var() name MeleePrepIdleAnim;
var() name MeleeFireAnim;
var() name MeleePrepCrouchAnim;
var() name MeleePrepIdleCrouchAnim;
var() name MeleeFireCrouchAnim;

var bool bMeleePrepHolding;
var bool bMeleePrepPlaying;
var bool bMeleeFirePlaying;
var bool bMeleePrepIdle;

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Instigator != None)
    {
        LinkedAnimPawn = Instigator;
        Instigator.LinkSkelAnim(MeshAnimation'BWKF_Third_A.BWRig_TP_Anims');
    }
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (Instigator != None && Instigator != LinkedAnimPawn)
    {
        LinkedAnimPawn = Instigator;
        Instigator.LinkSkelAnim(MeshAnimation'BWKF_Third_A.BWRig_TP_Anims');
    }
}

simulated function SetDualMesh(bool bOffHand)
{
}

simulated function Timer()
{
    Super.Timer();

    if (bMeleePrepPlaying)
        CheckMeleePrep();
    else if (bMeleeFirePlaying)
        CheckMeleeFire();
}

simulated function PlayThirdPersonMeleePrep()
{
    local KFPawn KFPawnOwner;
    local name AnimName;

    if (Instigator == None)
    {
        return;
    }

    KFPawnOwner = KFPawn(Instigator);

    if (KFPawnOwner == None)
    {
        return;
    }

    if (KFPawnOwner.bIsCrouched)
        AnimName = MeleePrepCrouchAnim;
    else
        AnimName = MeleePrepAnim;

    if (AnimName == '' || !Instigator.HasAnim(AnimName))
    {
        return;
    }

    Instigator.AnimBlendParams(1, 1.0, 0.0, 0.2, 'CHR_Spine1');
    Instigator.PlayAnim(AnimName, 1.0, 0.0, 1);

    bMeleePrepHolding = true;
    bMeleePrepPlaying = true;
    bMeleePrepIdle = false;
    bMeleeFirePlaying = false;

    SetTimer(0.01, true);
}

simulated function PlayThirdPersonMeleeFire()
{
    local KFPawn KFPawnOwner;
    local name AnimName;

    if (Instigator == None)
        return;

    KFPawnOwner = KFPawn(Instigator);

    if (KFPawnOwner == None)
        return;

    bMeleePrepHolding = false;
	bMeleePrepPlaying = false;
	bMeleePrepIdle = false;
	bMeleeFirePlaying = false;

    if (KFPawnOwner.bIsCrouched)
        AnimName = MeleeFireCrouchAnim;
    else
        AnimName = MeleeFireAnim;

    if (AnimName == '' || !Instigator.HasAnim(AnimName))
        return;

    Instigator.AnimBlendParams(1, 1.0, 0.0, 0.2, 'CHR_Spine1');
    Instigator.PlayAnim(AnimName, 1.0, 0.0, 1);

    bMeleeFirePlaying = true;

    SetTimer(0.01, true);
}

simulated function CheckMeleePrep()
{
    local name AnimName;
    local name IdleAnimName;
    local float Frame;
    local float Rate;

    if (!bMeleePrepPlaying || !bMeleePrepHolding || Instigator == None)
    {
        bMeleePrepPlaying = false;

        if (!bMeleeFirePlaying)
            SetTimer(0.0, false);

        return;
    }

    Instigator.GetAnimParams(1, AnimName, Frame, Rate);

    if (AnimName != MeleePrepAnim && AnimName != MeleePrepCrouchAnim)
    {
        bMeleePrepPlaying = false;

        if (!bMeleeFirePlaying)
            SetTimer(0.0, false);

        return;
    }

    if (Frame >= 0.70)
	{
		if (AnimName == MeleePrepCrouchAnim)
			IdleAnimName = MeleePrepIdleCrouchAnim;
		else
			IdleAnimName = MeleePrepIdleAnim;

		if (IdleAnimName != '' && Instigator.HasAnim(IdleAnimName))
		{
			Instigator.PlayAnim(IdleAnimName, 1.0, 0.0, 1);
			Instigator.FreezeAnimAt(0.0, 1);

			bMeleePrepPlaying = false;
			bMeleePrepIdle = true;

			SetTimer(0.0, false);
		}
		else
		{
			bMeleePrepPlaying = false;
			bMeleePrepIdle = false;
			SetTimer(0.0, false);
		}
	}
}

simulated function CheckMeleeFire()
{
    local name AnimName;
    local float Frame;
    local float Rate;

    if (Instigator == None)
    {
        bMeleeFirePlaying = false;
        SetTimer(0.0, false);
        return;
    }

    Instigator.GetAnimParams(1, AnimName, Frame, Rate);

    if (AnimName != MeleeFireAnim && AnimName != MeleeFireCrouchAnim)
    {
        bMeleeFirePlaying = false;
        SetTimer(0.0, false);
        return;
    }

    if (Frame >= 0.95)
    {
        Instigator.AnimBlendToAlpha(1, 0.0, 0.12);

        bMeleeFirePlaying = false;
        SetTimer(0.0, false);
    }
}

simulated function DoFlashEmitter()
{
    if (mMuzFlash3rd == None)
    {
        mMuzFlash3rd = Spawn(mMuzFlashClass);
        AttachToBone(mMuzFlash3rd, 'tip');

        if (mMuzFlashScale != 1.0 && BallisticEmitter(mMuzFlash3rd) != None)
            BallisticEmitter(mMuzFlash3rd).ScaleEmitter(mMuzFlash3rd, mMuzFlashScale);
    }

    if (mMuzFlash3rd != None)
        mMuzFlash3rd.SpawnParticle(1);
}

simulated event ThirdPersonEffects()
{
	local PlayerController PC;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (FiringMode == 0 || FiringMode == 1)
	{
		if (OldSpawnHitCount != SpawnHitCount)
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();

			PC = Level.GetLocalPlayerController();

			if (((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000))
			{
				if (mHitActor != None && BallisticHitEffectClass != None)
					Spawn(BallisticHitEffectClass,,, mHitLocation, Rotator(-mHitNormal));

				CheckForSplash();
				SpawnTracer();
			}
		}
	}

	if (FlashCount > 0)
	{
		if (KFPawn(Instigator) != None)
		{
			if (FiringMode == 0)
				KFPawn(Instigator).StartFiringX(false, bRapidFire);
			else
				KFPawn(Instigator).StartFiringX(true, bRapidFire);
		}

		if (bDoFiringEffects)
		{
			PC = Level.GetLocalPlayerController();

			if ((Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC))
				return;

			WeaponLight();

			DoFlashEmitter();

			if ((mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail)
			{
				mShellCaseEmitter = Spawn(mShellCaseEmitterClass);

				if (mShellCaseEmitter != None)
					AttachToBone(mShellCaseEmitter, ShellEjectBoneName);
			}

			if (mShellCaseEmitter != None)
				mShellCaseEmitter.mStartParticles++;
		}
	}
	else
	{
		GotoState('');

		if (KFPawn(Instigator) != None)
			KFPawn(Instigator).StopFiring();
	}
}

defaultproperties
{
	mMuzFlashScale=1.000000
	DrawScale=0.7
    ShellEjectBoneName="Ejector"
	RelativeRotation=(Yaw=32768)
	MeleePrepAnim="Pistols_BW_MeleePrep1"
    MeleePrepIdleAnim="Pistols_BW_MeleePrepIdle1"
    MeleeFireAnim="Pistols_BW_MeleeFire1"
    MeleePrepCrouchAnim="Pistols_BW_CHMeleePrep1"
    MeleePrepIdleCrouchAnim="Pistols_BW_CHMeleePrepIdle1"
    MeleeFireCrouchAnim="Pistols_BW_CHMeleeFire1"
}