class Weapon_RX22AFlamer_SecondaryFire extends BallisticInstantFire;

var bool bAltFireAnimPlaying;

function Weapon_RX22AFlamer_FireControl GetFireControl()
{
    return Weapon_RX22AFlamer_Main(Weapon).GetFireControl();
}

function float MaxRange()
{
    return 800;
}

function bool HookFire(vector Start, vector Dir, float Dist, out vector HitLoc)
{
    local int i;
    local bool bFoundFire;
    local float NodeDist, DR;
    local vector HL;

    HL = HitLoc;

    if (GetFireControl() == None)
        return false;

    for (i = 0; i < GetFireControl().GasNodes.Length; i++)
    {
        if (GetFireControl().GasNodes[i] == None)
            continue;

        if (Weapon_RX22AFlamer_GasCloud(GetFireControl().GasNodes[i]) != None ||
            Weapon_RX22AFlamer_GasPatch(GetFireControl().GasNodes[i]) != None ||
            Weapon_RX22AFlamer_GasSoak(GetFireControl().GasNodes[i]) != None)
            continue;

        NodeDist = VSize(GetFireControl().GasNodes[i].Location - Start);

        if (NodeDist > Dist)
            continue;

        DR = Dir Dot Normal(GetFireControl().GasNodes[i].Location - Start);

        if (DR < 0.75)
            continue;

        HL = Start + Dir * NodeDist;
        NodeDist = VSize(GetFireControl().GasNodes[i].Location - (Start + Dir * (DR * NodeDist)));

        if (NodeDist > 96)
            continue;

        HitLoc = Start + Dir * NodeDist;
        GetFireControl().GasNodes[i].AddFuel(1);
        bFoundFire = true;
    }

    HitLoc = HL;
    return bFoundFire;
}

function DoFireEffect()
{
    local vector Start, Dir, End, HitLoc, HitNorm;
    local Actor T;
    local int i;

    Start = Instigator.Location + Instigator.EyePosition();
    Dir = Vector(Instigator.GetViewRotation());
    End = Start + Dir * MaxRange();

    Weapon.bTraceWater = true;

    for (i = 0; i < 20; i++)
    {
        T = Trace(HitLoc, HitNorm, End, Start, true);

        if (T == None || (T != Instigator && T.Base != Instigator))
            break;

        Start = HitLoc + Dir * FMax(32, T.CollisionRadius * 2 + 4);
    }

    Weapon.bTraceWater = false;

    if (T == None)
    {
        HitLoc = End;

        if (GetFireControl() != None && !HookFire(Start, Dir, MaxRange() + 128, HitLoc))
            GetFireControl().SprayAir(HitLoc, Instigator);
    }
    else if (Pawn(T) != None)
    {
        if (GetFireControl() != None && !HookFire(Start, Dir, VSize(HitLoc - Start), HitLoc))
            GetFireControl().SpraySoak(T, Instigator);
    }
    else
    {
        if (GetFireControl() != None && !HookFire(Start, Dir, VSize(HitLoc - Start), HitLoc))
            GetFireControl().SprayWall(HitLoc, HitNorm, Instigator, T);
    }
}

function PlayFiring()
{
    ClientPlayForceFeedback(FireForce);
    FireCount++;

    if (!bAltFireAnimPlaying)
    {
        Weapon.LoopAnim(FireLoopAnim, FireAnimRate, TweenTime);
        bAltFireAnimPlaying = true;
    }

    if (FireSound != None)
        Weapon.AmbientSound = FireSound;
}

function ServerPlayFiring()
{
    if (FireSound != None)
        Weapon.AmbientSound = FireSound;
}

function StopFiring()
{
    bAltFireAnimPlaying = false;
    Weapon_RX22AFlamer_Main(Weapon).AmbientSound = None;
}

simulated function bool AllowFire()
{
    if (!Super.AllowFire() || Instigator.HeadVolume.bWaterVolume ||
        Weapon.GetFireMode(0).NextFireTime > Level.TimeSeconds - 0.2)
    {
        if (IsFiring())
            StopFiring();

        return false;
    }

    return true;
}

defaultproperties
{  
    FireSound=Sound'BWKF_RX22A_SN.RX22A.RX22A-FuelLoop'
    bPawnRapidFireAnim=True
    FireRate=0.100000
    AmmoClass=Class'BW_WD001_KF.Weapon_RX22AFlamer_FlamerGasAmmo'
    AmmoPerFire=1
    ShakeRotMag=(X=64.000000,Y=64.000000,Z=64.000000)
    ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
    ShakeRotTime=2.000000
    ShakeOffsetMag=(X=-8.000000)
    ShakeOffsetRate=(X=-1000.000000)
    ShakeOffsetTime=1.500000
    WarnTargetPct=0.500000
	bWaitForRelease=False
	FlashEmitterClass=None
}