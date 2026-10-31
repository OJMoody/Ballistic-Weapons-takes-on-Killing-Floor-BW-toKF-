class BallisticMachinegun extends BallisticWeapon abstract;

/*
	ReloadStart:		Open, ClipOut, BoxOff
	ReloadStartFew:		Open, BoxOff, ClipOut
	ReloadStartNone:	Open
	ReloadStartShell:	Open, ClipOut
	ReloadStartBox:		Open, BoxOff
	ReloadFinish:		BoxOn, ClipIn, Close
	ReloadFinishFew:	ClipIn Close
*/

var() Array<name>		BeltBones;		// List of the names of all the bullets
var() int				BeltLength;		// Number of bullets outside of belt(including hidden one in chamber)
var() name				BoxBone;		// Name of the ammo box bone
var   bool				bNoBox;			// Is the Ammo box not being used currently
var() BUtil.FullSound	BoxOnSound;		// Sound to play when box clips on
var() BUtil.FullSound	BoxOffSound;	// Sound to play when box comes off
var() BUtil.FullSound	FlapUpSound;	// Sound to play when cover opens
var() BUtil.FullSound	FlapDownSound;	// Sound to play when cover closes
var() Sound				HandleOnSound;	//
var() Sound				HandleOffSound;	//

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);
    SetBeltVisibility(MagAmmoRemaining);
}

simulated event AnimEnd(int Channel)
{
    if (Channel == 0 && bBallisticReload && BallisticReloadStage == 1)
    {
        PlayReloadFinish();
        return;
    }

    Super(BallisticWeapon).AnimEnd(Channel);
}

// Play different reload starting anims depending on the situation
simulated function PlayReload()
{
    if (bNoBox)
    {
        if (MagAmmoRemaining < 2)        // No Box, No Belt
            PlayAnim('ReloadStartNone', ReloadAnimRate, , 0.25);
        else                             // No Box, Belt present
            PlayAnim('ReloadStartShell', ReloadAnimRate, , 0.25);
    }
    else
    {
        if (MagAmmoRemaining < 2)        // Box Present, No Belt
            PlayAnim('ReloadStartBox', ReloadAnimRate, , 0.25);
        else if (MagAmmoRemaining < 12)   // Box Present, Belt too short
            PlayAnim('ReloadStartFew', ReloadAnimRate, , 0.25);
        else                             // Box and Belt Present
            PlayAnim('ReloadStart', ReloadAnimRate, , 0.25);
    }
}

// Play second half of reload anim. It will be different depending on how many bullets are being loaded
simulated function PlayReloadFinish()
{
    SetBoxVisibility();
    SetBeltVisibility(AmmoAmount(0) + 1);

    if (AmmoAmount(0) < BeltLength + 1)
        PlayAnim('ReloadFinishFew', ReloadAnimRate, , 0.0);
    else
        PlayAnim('ReloadFinish', ReloadAnimRate, , 0.0);
}

// Remove tween when playing idle
simulated function PlayIdle()
{
	IdleAnim = default.IdleAnim;
	Super.PlayIdle();
}

//Hides the ammo box if needed
simulated function SetBoxVisibility()
{
    if (AmmoAmount(0) < BeltLength + 1)
        bNoBox = true;
    else
        bNoBox = false;

    if (bNoBox)
        SetBoneScale(1, 0.0, BoxBone);
    else
        SetBoneScale(1, 1.0, BoxBone);
}

// Hides bullets on the visible belt
simulated function SetBeltVisibility(int Amount)
{
	if (Amount < BeltLength)
		SetBoneScale(0, 0.0, BeltBones[Max(0,Amount-1)]);
	else
		SetBoneScale(0, 1.0, BeltBones[0]);
}

// Run to give hand opportinity to go to stand mode handle instead of playing to end of normal reload anim
/*simulated function Notify_MachinegunGoToHandle()
{
	if (bNeedCock && MagAmmo > 0)
		CommonCockGun(2);
}*/

simulated function Notify_CockGoToHandle()
{
}
// Run when cover is opened
simulated function Notify_MachinegunOpen()
{
	if (Level.NetMode != NM_Client)
		PlayOwnedSound(FlapUpSound.Sound,FlapUpSound.Slot,FlapUpSound.Volume,FlapUpSound.bNoOverride,FlapUpSound.Radius,FlapUpSound.Pitch,FlapUpSound.bAtten);
	else
	    class'BUtil'.static.PlayFullSound(self, FlapUpSound);
}
// Run when cover is closed
simulated function Notify_MachinegunClose()
{
	if (Level.NetMode != NM_Client)
		PlayOwnedSound(FlapDownSound.Sound,FlapDownSound.Slot,FlapDownSound.Volume,FlapDownSound.bNoOverride,FlapDownSound.Radius,FlapDownSound.Pitch,FlapDownSound.bAtten);
	else
		class'BUtil'.static.PlayFullSound(self, FlapDownSound);
}
// Run ammo Box is pulled off
simulated function Notify_MachinegunBoxOff()
{
	if (Level.NetMode != NM_Client)
		PlayOwnedSound(BoxOffSound.Sound,BoxOffSound.Slot,BoxOffSound.Volume,BoxOffSound.bNoOverride,BoxOffSound.Radius,BoxOffSound.Pitch,BoxOffSound.bAtten);
	else
		class'BUtil'.static.PlayFullSound(self, BoxOffSound);
}
// Run when ammo box is clipped on
simulated function Notify_MachinegunBoxOn()
{
	if (Level.NetMode != NM_Client)
		PlayOwnedSound(BoxOnSound.Sound,BoxOnSound.Slot,BoxOnSound.Volume,BoxOnSound.bNoOverride,BoxOnSound.Radius,BoxOnSound.Pitch,BoxOnSound.bAtten);
	else
		class'BUtil'.static.PlayFullSound(self, BoxOnSound);
}

simulated function bool HasAmmo()
{
    if (FireMode[0] == None)
        return false;

    if (AmmoAmount(0) >= FireMode[0].AmmoPerFire)
        return true;

    return false;
}

defaultproperties
{
     BeltBones(0)="Bullet1"
     BeltBones(1)="Bullet2"
     BeltBones(2)="Bullet3"
     BeltBones(3)="Bullet4"
     BeltBones(4)="Bullet5"
     BeltBones(5)="Bullet6"
     BeltBones(6)="Bullet7"
     BeltBones(7)="Bullet8"
     BeltBones(8)="Bullet9"
     BeltBones(9)="Bullet10"
     BeltLength=11
     BoxBone="AmmoBox"
     BoxOnSound=(Volume=0.500000,Radius=24.000000,Pitch=1.000000,bAtten=True)
     BoxOffSound=(Volume=0.500000,Radius=24.000000,Pitch=1.000000,bAtten=True)
     FlapUpSound=(Volume=0.500000,Radius=24.000000,Pitch=1.000000,bAtten=True)
     FlapDownSound=(Volume=0.500000,Radius=24.000000,Pitch=1.000000,bAtten=True)
}