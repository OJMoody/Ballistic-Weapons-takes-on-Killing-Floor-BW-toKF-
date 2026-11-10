class Weapon_RX22AFlamer_PrimaryFire extends BallisticInstantFire;

var Actor Ignition;
var Actor MuzzleFlame;
var Actor Heater;
var bool bIgnited;
var() Sound FireSoundLoop;

function float MaxRange()
{
    return 1800;
}

function Weapon_RX22AFlamer_FireControl GetFireControl()
{
    return Weapon_RX22AFlamer_Main(Weapon).GetFireControl();
}

function DoFireEffect()
{
    local vector TraceStart, Start, Dir, End, HitLocation, HitNormal;
    local rotator Aim;
    local Actor Other;
    local float Dist, NodeDist, DR;
    local int i;

    TraceStart = Instigator.Location + Instigator.EyePosition();
    Aim = Instigator.GetViewRotation();
    Dir = Vector(Aim);
    End = TraceStart + Dir * MaxRange();

    Weapon.bTraceWater = true;
    Start = TraceStart;

    for (i = 0; i < 20; i++)
    {
        Other = Trace(HitLocation, HitNormal, End, Start, true);

        if (Other == None || Other.bWorldGeometry || Mover(Other) != None || Vehicle(Other) != None || FluidSurfaceInfo(Other) != None || (PhysicsVolume(Other) != None && PhysicsVolume(Other).bWaterVolume))
            break;

        Start = HitLocation + Dir * FMax(32, Other.CollisionRadius * 2 + 4);
    }

    Weapon.bTraceWater = false;

    if (Other == None)
        HitLocation = End;

    if (FluidSurfaceInfo(Other) != None || (PhysicsVolume(Other) != None && PhysicsVolume(Other).bWaterVolume))
		Other = None;

	if (GetFireControl() != None)
	{
		for (i = 0; i < GetFireControl().GasNodes.Length; i++)
		{
			// Keep your existing gas-node loop unchanged.
		}

		if (Other != None && (Other.bWorldGeometry || Mover(Other) != None))
		{
			if (KFPawn(Instigator) != None &&
				Weapon_RX22AFlamer_Attachment(KFPawn(Instigator).WeaponAttachment) != None)
				Weapon_RX22AFlamer_Attachment(KFPawn(Instigator).WeaponAttachment).QueueFlameHit(HitLocation, HitNormal);

			GetFireControl().FireShot(Start, HitLocation, Dist, true, HitNormal, Instigator, Other);
		}
		else
			GetFireControl().FireShot(Start, HitLocation, Dist, Other != None, HitNormal, Instigator, None);
	}

	Dist = VSize(HitLocation - Start);

    if (GetFireControl() != None)
    {
        for (i = 0; i < GetFireControl().GasNodes.Length; i++)
        {
            if (GetFireControl().GasNodes[i] == None)
                continue;

            if (Weapon_RX22AFlamer_GasCloud(GetFireControl().GasNodes[i]) == None &&
                Weapon_RX22AFlamer_GasPatch(GetFireControl().GasNodes[i]) == None &&
                Weapon_RX22AFlamer_GasSoak(GetFireControl().GasNodes[i]) == None)
                continue;

            NodeDist = VSize(GetFireControl().GasNodes[i].Location - Start);

            if (NodeDist > Dist)
                continue;

            DR = Dir Dot Normal(GetFireControl().GasNodes[i].Location - Start);

            if (DR < 0.75)
                continue;

            NodeDist = VSize(GetFireControl().GasNodes[i].Location - (Start + Dir * (DR * NodeDist)));

            if (NodeDist < 128)
                GetFireControl().GasNodes[i].TakeDamage(5, Instigator, GetFireControl().GasNodes[i].Location, vect(0,0,0), class'Weapon_RX22AFlamer_DTBurned');
        }

        if (Other != None && (Other.bWorldGeometry || Mover(Other) != None))
            GetFireControl().FireShot(Start, HitLocation, Dist, true, HitNormal, Instigator, Other);
        else
            GetFireControl().FireShot(Start, HitLocation, Dist, Other != None, HitNormal, Instigator, None);
    }

    Super.DoFireEffect();
}

function PlayFiring()
{
    local name CurrentAnim;
    local float CurrentFrame, CurrentRate;

    Weapon.GetAnimParams(0, CurrentAnim, CurrentFrame, CurrentRate);

    if (CurrentAnim != FireLoopAnim)
        Weapon.LoopAnim(FireLoopAnim, FireAnimRate, 0.0);

    ClientPlayForceFeedback(FireForce);
    FireCount++;

    if (FireSoundLoop != None)
        Weapon.AmbientSound = FireSoundLoop;

    if (Ignition != None && !bIgnited)
    {
        Ignition.Trigger(Weapon, Instigator);

        if (FireSound != None)
            Weapon.PlayOwnedSound(FireSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius);

        bIgnited = true;
    }

    if (MuzzleFlame == None)
        class'BUtil'.static.InitMuzzleFlash(MuzzleFlame, class'Weapon_RX22AFlamer_MuzzleFlame', Weapon.DrawScale, Weapon, 'tip');
}

function ServerPlayFiring()
{
    if (!bIgnited)
    {
        bIgnited = true;

        if (FireSound != None)
            Weapon.PlayOwnedSound(FireSound, SLOT_Interact, TransientSoundVolume,, TransientSoundRadius);
    }
}

simulated function bool AllowFire()
{
    if (Instigator.HeadVolume.bWaterVolume)
    {
        if (bIgnited)
        {
            StopFiring();
            PlayFireEnd();
        }

        return false;
    }

    // Stop the firing loop when the magazine is empty.
    if (KFWeapon(Weapon).MagAmmoRemaining < 1)
    {
        if (bIgnited)
        {
            StopFiring();
            PlayFireEnd();
        }

        return false;
    }

    return Super.AllowFire();
}

function StopFiring()
{
	bIgnited = false;
    Weapon_RX22AFlamer_Main(Weapon).AmbientSound = None;

    if (MuzzleFlame != None)
    {
        Emitter(MuzzleFlame).Kill();
        MuzzleFlame = None;
    }
}

simulated function DestroyEffects()
{
    Super.DestroyEffects();

    if (Ignition != None)
        Ignition.Destroy();

    if (Heater != None)
        Heater.Destroy();

    if (MuzzleFlame != None)
        MuzzleFlame.Destroy();
}

simulated function InitEffects()
{
    if (AIController(Instigator.Controller) != None)
        return;

    if (Heater == None || Heater.bDeleteMe)
        class'BUtil'.static.InitMuzzleFlash(Heater, class'Weapon_RX22AFlamer_Heater', Weapon.DrawScale, Weapon, 'muzzle');

    Weapon_RX22AFlamer_Heater(Heater).SetHeat(0.0);
    Weapon_RX22AFlamer_Main(Weapon).Heater = Weapon_RX22AFlamer_Heater(Heater);

    if (Ignition == None || Ignition.bDeleteMe)
        class'BUtil'.static.InitMuzzleFlash(Ignition, class'Weapon_RX22AFlamer_Igniter', Weapon.DrawScale, Weapon, 'tip2');
}

defaultproperties
{
    bFiringDoesntAffectMovement=True
	FireLoopAnim="FireLoop"
	DamageMin=14.000000
    DamageMax=14.000000
    FireSoundLoop=Sound'BWKF_RX22A_SN.RX22A.RX22A-FireLoop'
    TraceRange=(Min=1800.000000,Max=1800.000000)
    FireSound=Sound'BWKF_RX22A_SN.RX22A.RX22A-Ignite'
    bPawnRapidFireAnim=True
    FireAnim="FireLoop"
    FireRate=0.090000
    AmmoClass=Class'BW_WD001_KF.Weapon_RX22AFlamer_FlamerGasAmmo'
    AmmoPerFire=1
    ShakeRotMag=(X=64.000000,Y=64.000000,Z=64.000000)
    ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
    ShakeRotTime=2.000000
    ShakeOffsetMag=(X=-8.000000)
    ShakeOffsetRate=(X=-1000.000000)
    ShakeOffsetTime=1.500000
    bInstantHit=True
    bLeadTarget=False
    bTossed=False
    bSplashDamage=True
    bRecommendSplashDamage=False
    BotRefireRate=0.99
}