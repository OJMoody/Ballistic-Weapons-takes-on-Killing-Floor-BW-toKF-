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

    if (vector(Rotation) Dot Normal(EndPoint - Location) < 0.0)
        Destroy();
}

simulated singular function Touch(Actor Other)
{
    local int i;

    if (Other == None)
        return;

    if (Other.Base == Instigator)
        return;

    for (i = 0; i < AlreadyHit.Length; i++)
    {
        if (AlreadyHit[i] == Other)
            return;
    }

    Super.Touch(Other);
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    local int i;

    if (Other == None)
        return;

    for (i = 0; i < AlreadyHit.Length; i++)
    {
        if (AlreadyHit[i] == Other)
            return;
    }

    i = AlreadyHit.Length;
    AlreadyHit.Length = i + 1;
    AlreadyHit[i] = Other;

    Super.ProcessTouch(Other, HitLocation);
}

simulated function DoDamage(Actor Other, vector HitLocation)
{
    local vector Dummy;

    if (Instigator == None || Instigator.Controller == None)
        Other.SetDelayedDamageInstigatorController(InstigatorController);

    class'BallisticDamageType'.static.GenericHurt(Other, Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

    if (KFHumanPawn(Other) != None && Level.Game.ReduceDamage(10, KFHumanPawn(Other), Instigator, HitLocation, Dummy, MyDamageType) > 0)
        FireControl.FireSinge(Pawn(Other), Instigator);
}

simulated function Explode(vector a, vector b)
{
    Destroy();
}

defaultproperties
{
    //WeaponClass=class'Weapon_RX22AFlamer_Main'
    bPenetrate=True
    Speed=3000.000000
    MyDamageType=Class'BW_WD001_KF.Weapon_RX22AFlamer_DTBurned'
    bHidden=True
    RemoteRole=ROLE_None
    LifeSpan=0.350000
    CollisionRadius=15.000000
    CollisionHeight=15.000000
    bCollideActors=True
    bCollideWorld=False
    bBlockZeroExtentTraces=False
}