class BallisticAttachment extends KFWeaponAttachment;

var() float mMuzFlashScale;

var class<Actor> BallisticHitEffectClass;

simulated function SetDualMesh(bool bOffHand)
{
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

simulated function PlayThirdPersonFire()
{
	if (Mesh != None && HasAnim('Fire'))
		PlayAnim('Fire', 1.0, 0.0);
}

simulated function PlayThirdPersonAnim(name AnimName)
{
	if (Mesh != None && AnimName != '' && HasAnim(AnimName))
		PlayAnim(AnimName, 1.0, 0.0);
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
}