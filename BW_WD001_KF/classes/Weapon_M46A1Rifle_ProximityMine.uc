class Weapon_M46A1Rifle_ProximityMine extends Weapon_M46A1Rifle_MineBase;

var bool bDetonated;
var Pawn Stepper;
var float MDamage;
var float MDamageRadius;

var Weapon_M46A1Rifle_TeamLight TeamLight;
var byte TeamLightColor;

function InitProjectile()
{
    Super.InitProjectile();

    if (Role == ROLE_Authority)
    {
        Spawn(class'Weapon_M46A1Rifle_ProximityTrigger', self,, Location);
        TriggerStartTime = Level.TimeSeconds + 2.0;
    }
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        if (Instigator != None && Instigator.Controller != None)
            TeamLightColor = Instigator.Controller.GetTeamNum();

        if (Level.NetMode != NM_DedicatedServer)
        {
            TeamLight = Spawn(class'Weapon_M46A1Rifle_TeamLight', Self,, Location);
            if (TeamLight != None)
            {
                TeamLight.SetBase(Self);
                TeamLight.SetTeamColor(TeamLightColor);
            }
        }
    }
}

function SteppedOn(Actor Other)
{
    local Pawn P;

    if (Role != ROLE_Authority)
        return;

    if (bDetonated || Other == None)
        return;

    P = Pawn(Other);

    if (P == None)
        return;

    // Do not allow player-controlled pawns to trigger the mine.
    if (P.Controller != None && PlayerController(P.Controller) != None)
        return;

    // Only Zeds may trigger the proximity mine.
    if (KFMonster(P) == None)
        return;

    if (Level.TimeSeconds < TriggerStartTime || TriggerStartTime == 0)
        return;

    if (VSize(P.Velocity) <= 0)
        return;

    Stepper = P;
    bDetonated = True;

    if (DetonateSound != None)
        PlaySound(DetonateSound,, 2.0,, 256.0);

    SetTimer(1.0, False);
}

function Timer()
{
    if (Role != ROLE_Authority || !bDetonated)
        return;

    DetonateMine();
}

function DetonateMine()
{
    if (Role != ROLE_Authority)
        return;

    if (Stepper != None && Stepper.Health > 0)
    {
        Stepper.TakeDamage(
            MDamage,
            Instigator,
            Stepper.Location,
            vect(0,0,0),
            MyDamageType
        );
    }

    if (MDamageRadius > 0)
    {
        HurtRadius(
            MDamage,
            MDamageRadius,
            MyRadiusDamageType,
            MomentumTransfer,
            Location
        );
    }

    Destroy();
}

simulated function bool IsStationary()
{
    return True;
}

simulated event Destroyed()
{
    if (TeamLight != None)
        TeamLight.Destroy();

    Super.Destroyed();
}

defaultproperties
{
    MDamage=100.000000
    MDamageRadius=300.000000
    Damage=100.000000
    DamageRadius=300.000000
    MomentumTransfer=50000.000000

    MyDamageType=None
    MyRadiusDamageType=None

    bNetTemporary=False
    Physics=PHYS_None
    LifeSpan=0.000000
}