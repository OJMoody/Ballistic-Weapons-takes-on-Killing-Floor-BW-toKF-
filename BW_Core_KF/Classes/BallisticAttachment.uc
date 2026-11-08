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

var() name TPBrassBone;

//=============================================================================
// THIRD-PERSON GRENADE ANIMATIONS
//=============================================================================

var bool bGrenadePrepPlaying;
var bool bGrenadePrepHolding;
var bool bGrenadeThrowPlaying;

var byte GrenadeTPFireMode;

var name ActiveGrenadePrepAnim;
var name ActiveGrenadePrepIdleAnim;
var name ActiveGrenadeThrowAnim;

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Instigator != None)
    {
        LinkedAnimPawn = Instigator;
        Instigator.LinkSkelAnim(MeshAnimation'BWKF_Third_A.BWRig_TP_Anims');
        Instigator.BoneRefresh();
        Instigator.bForceSkelUpdate = True;
    }
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (Instigator != None && Instigator != LinkedAnimPawn)
    {
        LinkedAnimPawn = Instigator;
        Instigator.LinkSkelAnim(MeshAnimation'BWKF_Third_A.BWRig_TP_Anims');
        Instigator.bForceSkelUpdate = True;
    }
}

simulated function EjectBrass()
{
    local BallisticWeapon BW;
    local BallisticInstantFire BIF;
    local PlayerController PC;
    local Coords C;
    local Actor BrassActor;
    local vector Start;
    local vector X, Y, Z;
    local rotator BrassRotation;

    if (Instigator == None)
        return;

    BW = BallisticWeapon(Instigator.Weapon);
    if (BW == None)
        return;

    BIF = BW.GetBallisticFireMode(FiringMode);
    if (BIF == None || BIF.BrassClass == None)
        return;

    if (Level.DetailMode < DM_High)
        return;

    // The local first-person weapon handles its own brass.
    PC = Level.GetLocalPlayerController();
    if (PC != None && Instigator.Controller == PC && Instigator.IsFirstPerson() && PC.ViewTarget == Instigator)
        return;

    // Get the brass-ejection transform from the third-person attachment.
    BrassRotation = GetBoneRotation(TPBrassBone);
    C = GetBoneCoords(TPBrassBone);
    Start = C.Origin;

    // Apply the weapon's configurable brass offset in bone-local axes.
    GetAxes(BrassRotation, X, Y, Z);
    Start += X * BIF.BrassOffset.X;
    Start += Y * BIF.BrassOffset.Y;
    Start += Z * BIF.BrassOffset.Z;

    BrassActor = Spawn(BIF.BrassClass,,, Start, BrassRotation);
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
    else if (bGrenadePrepPlaying)
        CheckGrenadePrep();
    else if (bGrenadeThrowPlaying)
        CheckGrenadeThrow();
}

simulated function PlayThirdPersonGrenadePrep(byte Mode)
{
    local BallisticHandGrenade GrenadeWeapon;
    local BallisticHandGrenadeFire GrenadeFire;

    if (Instigator == None || Mode > 1)
        return;

    GrenadeWeapon = BallisticHandGrenade(Instigator.Weapon);

    if (GrenadeWeapon == None)
        return;

    GrenadeFire = GrenadeWeapon.GetGrenadeFireMode(Mode);

    if (GrenadeFire == None)
        return;

    GrenadeTPFireMode = Mode;

    if (KFPawn(Instigator) != None && KFPawn(Instigator).bIsCrouched)
    {
        ActiveGrenadePrepAnim = GrenadeFire.GrenadePrepareCrouchAnimTP;
        ActiveGrenadePrepIdleAnim = GrenadeFire.GrenadePrepareCrouchIdleAnimTP;
    }
    else
    {
        ActiveGrenadePrepAnim = GrenadeFire.GrenadePrepareAnimTP;
        ActiveGrenadePrepIdleAnim = GrenadeFire.GrenadePrepareIdleAnimTP;
    }

    if (ActiveGrenadePrepAnim == '' || !Instigator.HasAnim(ActiveGrenadePrepAnim))
        return;

    bMeleePrepHolding = false;
    bMeleePrepPlaying = false;
    bMeleePrepIdle = false;
    bMeleeFirePlaying = false;

    bGrenadePrepHolding = true;
    bGrenadeThrowPlaying = false;
    bGrenadePrepPlaying = true;

    Instigator.AnimBlendParams(1, 1.0, 0.0, 0.2, 'CHR_Spine1');
    Instigator.PlayAnim(ActiveGrenadePrepAnim, 1.0, 0.0, 1);

    SetTimer(0.01, true);
}

simulated function CheckGrenadePrep()
{
    local name AnimName;
    local float Frame;
    local float Rate;

    if (!bGrenadePrepPlaying || !bGrenadePrepHolding || Instigator == None)
    {
        bGrenadePrepPlaying = false;

        if (!bGrenadeThrowPlaying)
            SetTimer(0.0, false);

        return;
    }

    Instigator.GetAnimParams(1, AnimName, Frame, Rate);

    if (AnimName != ActiveGrenadePrepAnim)
    {
        bGrenadePrepPlaying = false;

        if (!bGrenadeThrowPlaying)
            SetTimer(0.0, false);

        return;
    }

    if (Frame >= 0.70)
    {
        if (ActiveGrenadePrepIdleAnim != ''
            && Instigator.HasAnim(ActiveGrenadePrepIdleAnim))
        {
            Instigator.PlayAnim(ActiveGrenadePrepIdleAnim, 1.0, 0.0, 1);
            Instigator.FreezeAnimAt(0.0, 1);

            bGrenadePrepPlaying = false;
            bGrenadePrepHolding = true;

            SetTimer(0.0, false);
        }
        else
        {
            bGrenadePrepPlaying = false;
            bGrenadePrepHolding = false;

            SetTimer(0.0, false);
        }
    }
}

simulated function PlayThirdPersonGrenadeThrow(byte Mode)
{
    local BallisticHandGrenade GrenadeWeapon;
    local BallisticHandGrenadeFire GrenadeFire;

    if (Instigator == None || Mode > 1)
        return;

    GrenadeWeapon = BallisticHandGrenade(Instigator.Weapon);

    if (GrenadeWeapon == None)
        return;

    GrenadeFire = GrenadeWeapon.GetGrenadeFireMode(Mode);

    if (GrenadeFire == None)
        return;

    GrenadeTPFireMode = Mode;

    bGrenadePrepPlaying = false;
    bGrenadePrepHolding = false;
    bGrenadeThrowPlaying = false;

    if (KFPawn(Instigator) != None && KFPawn(Instigator).bIsCrouched)
		ActiveGrenadeThrowAnim = GrenadeFire.GrenadeThrowCrouchAnimTP;
	else
		ActiveGrenadeThrowAnim = GrenadeFire.GrenadeThrowAnimTP;

    if (ActiveGrenadeThrowAnim == '' || !Instigator.HasAnim(ActiveGrenadeThrowAnim))
        return;

    Instigator.AnimBlendParams(1, 1.0, 0.0, 0.2, 'CHR_Spine1');
    Instigator.PlayAnim(ActiveGrenadeThrowAnim, 1.0, 0.0, 1);

    bGrenadeThrowPlaying = true;

    SetTimer(0.01, true);
}

simulated function CheckGrenadeThrow()
{
    local name AnimName;
    local float Frame;
    local float Rate;

    if (!bGrenadeThrowPlaying || Instigator == None)
    {
        bGrenadeThrowPlaying = false;
        SetTimer(0.0, false);
        return;
    }

    Instigator.GetAnimParams(1, AnimName, Frame, Rate);

    if (AnimName != ActiveGrenadeThrowAnim)
    {
        bGrenadeThrowPlaying = false;
        SetTimer(0.0, false);
        return;
    }

    if (Frame >= 0.95)
    {
        Instigator.AnimBlendToAlpha(1, 0.0, 0.12);

        bGrenadeThrowPlaying = false;
        SetTimer(0.0, false);
    }
}

simulated function CancelThirdPersonGrenade()
{
    if (Instigator != None
        && (bGrenadePrepPlaying || bGrenadePrepHolding || bGrenadeThrowPlaying))
    {
        Instigator.AnimBlendToAlpha(1, 0.0, 0.12);
    }

    bGrenadePrepPlaying = false;
    bGrenadePrepHolding = false;
    bGrenadeThrowPlaying = false;

    ActiveGrenadePrepAnim = '';
    ActiveGrenadePrepIdleAnim = '';
    ActiveGrenadeThrowAnim = '';

    if (!bMeleePrepPlaying && !bMeleeFirePlaying)
        SetTimer(0.0, false);
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
        if (mMuzFlashClass == None)
            return;

        mMuzFlash3rd = Spawn(mMuzFlashClass);

        if (mMuzFlash3rd == None)
            return;

        AttachToBone(mMuzFlash3rd, 'tip');

        if (mMuzFlashScale != 1.0 && BallisticEmitter(mMuzFlash3rd) != None)
            BallisticEmitter(mMuzFlash3rd).ScaleEmitter(mMuzFlash3rd, mMuzFlashScale);
    }

    if (mMuzFlash3rd != None)
        mMuzFlash3rd.SpawnParticle(1);
}

simulated function SpawnTracer()
{
    local BCTraceEmitter Tracer;
    local vector SpawnLoc;
    local float Dist;

    if (!bDoFiringEffects)
        return;

    SpawnLoc = GetTracerStart();
    Dist = VSize(mHitLocation - SpawnLoc);

    if (Dist > mTracerMinDistance)
    {
        Tracer = BCTraceEmitter(Spawn(mTracerClass, self,, SpawnLoc, Rotator(mHitLocation - SpawnLoc)));

        if (Tracer != None)
            Tracer.Initialize(Dist);
    }
}

simulated function vector GetTracerStart()
{
    local Pawn P;

    P = Pawn(Owner);

    // Preserve the original first-person muzzle position.
    if ((P != None) && P.IsFirstPerson() && P.Weapon != None)
        return P.Weapon.GetEffectStart();

    // Preserve vanilla handling for attachments that haven't been rendered.
    if (Instigator != None && (Level.TimeSeconds - LastRenderTime) > 2)
        return Instigator.Location;

    // Use the actual third-person weapon muzzle bone.
    return GetBoneCoords('tip').Origin;
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

			EjectBrass();
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
	TPBrassBone="Ejector"
	bForceSkelUpdate=True
}