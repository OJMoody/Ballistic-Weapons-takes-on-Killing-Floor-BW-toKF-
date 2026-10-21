class BallisticHandGrenadeFire extends RocketFire
    abstract;

var float CachedThrowPower;

//=============================================================================
// THROW POWER
//=============================================================================

function float CalculateThrowPower()
{
    return 0.2 + FClamp(HoldTime - 0.2, 0.0, 1.0) * 0.8;
}

function CacheThrowPower(float ChargeTime)
{
    CachedThrowPower = 0.2 + FClamp(ChargeTime - 0.2, 0.0, 1.0) * 0.8;
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
    local float PawnSpeed, ThrowPower;

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

    ThrowPower = CachedThrowPower;

    if (ThrowPower <= 0.0)
        ThrowPower = CalculateThrowPower();

    CachedThrowPower = 0.0;

    Weapon.GetViewAxes(X, Y, Z);
    PawnSpeed = X dot Instigator.Velocity;

    G.Speed = G.Speed * FClamp(ThrowPower, 0.2, 1.0);
    G.Speed += PawnSpeed;
    G.Velocity = G.Speed * Vector(G.Rotation);

    Super.PostSpawnProjectile(G);
}

defaultproperties
{
    ProjSpawnOffset=(X=25.0,Y=-10.0,Z=0.0)
    AmmoPerFire=0
    bWaitForRelease=False
    bFireOnRelease=False
}