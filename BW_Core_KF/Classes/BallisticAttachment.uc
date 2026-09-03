class BallisticAttachment extends KFWeaponAttachment;

var() float mMuzFlashScale;

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

defaultproperties
{
	mMuzFlashScale=1.000000
	DrawScale=0.7
    ShellEjectBoneName="Ejector"
	RelativeRotation=(Yaw=32768)
}