class BallisticHandGrenadeFire extends RocketFire
    abstract;

var() float GrenadeBaseThrowSpeed;
var() float GrenadeThrowChargeTime;
var() float GrenadeMaxThrowBonus;

var() name GrenadePrepareAnimation;
var() name GrenadeThrowAnimation;

var float CachedThrowPower;

//=============================================================================
// THROW POWER
//=============================================================================

function float CalculateGrenadeThrowPower()
{
    if (GrenadeThrowChargeTime <= 0.0)
        return 1.0 + FMax(0.0, GrenadeMaxThrowBonus);

    return 1.0 + FClamp(HoldTime / GrenadeThrowChargeTime, 0.0, 1.0)
        * FMax(0.0, GrenadeMaxThrowBonus);
}

function CacheGrenadeThrowPower(float ChargeTime)
{
    if (GrenadeThrowChargeTime <= 0.0)
        CachedThrowPower = 1.0 + FMax(0.0, GrenadeMaxThrowBonus);
    else
        CachedThrowPower = 1.0 + FClamp(ChargeTime / GrenadeThrowChargeTime, 0.0, 1.0)
            * FMax(0.0, GrenadeMaxThrowBonus);
}

//=============================================================================
// PROJECTILE SPAWNING
//=============================================================================

simulated event ModeDoFire()
{
}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X, Y, Z;
    local Rotator Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int Hand;

    if (Instigator == None || Weapon == None)
        return;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X, Y, Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = StartTrace + X * ProjSpawnOffset.X;

    if (PlayerController(Instigator.Controller) != None)
    {
        Hand = int(PlayerController(Instigator.Controller).Handedness);

        if (Hand == -1 || Hand == 1)
            StartProj = StartProj + Hand * Y * ProjSpawnOffset.Y + Z * ProjSpawnOffset.Z;
    }

    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if (Other != None)
        StartProj = HitLocation;

    Aim = AdjustAim(StartProj, AimError);

    SpawnProjectile(StartProj, Aim);
}

function PostSpawnProjectile(Projectile P)
{
    local Grenade G;
    local Vector X, Y, Z;
    local float PawnSpeed, ThrowPower, BaseThrowSpeed;

    G = Grenade(P);

    if (G == None)
    {
        Super.PostSpawnProjectile(P);
        return;
    }

    if (Instigator == None || Weapon == None)
    {
        Super.PostSpawnProjectile(P);
        return;
    }

    BaseThrowSpeed = GrenadeBaseThrowSpeed;

    if (BaseThrowSpeed <= 0.0)
        BaseThrowSpeed = G.Speed;

    ThrowPower = CachedThrowPower;

    if (ThrowPower <= 0.0)
        ThrowPower = CalculateGrenadeThrowPower();

    CachedThrowPower = 0.0;

    Weapon.GetViewAxes(X, Y, Z);
    PawnSpeed = X dot Instigator.Velocity;

    G.Speed = BaseThrowSpeed * FMax(1.0, ThrowPower);
    G.Speed += PawnSpeed;
    G.Velocity = G.Speed * Vector(G.Rotation);

    Super.PostSpawnProjectile(G);
}

defaultproperties
{
    GrenadeBaseThrowSpeed=850.000000
    GrenadeThrowChargeTime=2.500000
    GrenadeMaxThrowBonus=0.250000

    ProjSpawnOffset=(X=25.0,Y=-10.0,Z=0.0)
    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}