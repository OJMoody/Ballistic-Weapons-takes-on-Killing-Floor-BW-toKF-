class Weapon_RX22AFlamer_Projectile extends BallisticProjectile;

var Weapon_RX22AFlamer_FireControl FireControl;
var vector EndPoint, StartPoint;
var array<Actor> AlreadyHit;

simulated event PreBeginPlay()
{
    if (Owner != None && Pawn(Owner) != None)
        Instigator = Pawn(Owner);

    Super.PreBeginPlay();
}

function InitFlame(vector End)
{
    EndPoint = End;
    StartPoint = Location;
}

event Tick(float DT)
{
    Super.Tick(DT);

    if (Vector(Rotation) Dot Normal(EndPoint - Location) < 0.0)
        Destroy();
}

simulated function Timer()
{
    if (StartDelay > 0)
    {
        SetCollision(true, false, false);
        StartDelay = 0;
        SetPhysics(default.Physics);
        bDynamicLight = default.bDynamicLight;
        bHidden = default.bHidden;
        InitProjectile();
    }
    else
        Super.Timer();
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local int i;

    if (Other == None || (!bCanHitOwner && (Other == Instigator || Other == Owner || Other.Base == Instigator)))
        return;

    if (KFBulletWhipAttachment(Other) != None)
        return;

    if (KFHumanPawn(Other) != None && Instigator != None
        && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex)
        return;

    for (i = 0; i < AlreadyHit.Length; i++)
        if (AlreadyHit[i] == Other)
            return;

    if (Role == ROLE_Authority)
	{
		DoDamage(Other, HitLocation);
	}

    if (CanPenetrate(Other) && Other != HitActor)
    {
        AlreadyHit[AlreadyHit.Length] = Other;
        HitActor = Other;
    }
    else
        Destroy();

    if (Pawn(Other) != None && FireControl != None)
        FireControl.FireSinge(Pawn(Other), Instigator);
}

defaultproperties
{
    bPenetrate=True
    StartDelay=0.050000
    Speed=3000.000000
    Damage=8.000000
    MyDamageType=Class'BW_WD001_KF.Weapon_RX22AFlamer_DTBurned'
    bHidden=True
    RemoteRole=ROLE_None
    LifeSpan=0.600000
    CollisionRadius=32.000000
    CollisionHeight=32.000000
    bCollideActors=False
    bCollideWorld=False
    bBlockZeroExtentTraces=False
    bBlockNonZeroExtentTraces=False
}