class Utility_T10Grenade_CloudControl extends Actor;

var array<Utility_T10Grenade_GasCloud> Clouds;

var() int Damage;
var() class<DamageType> DamageType;

var vector CloudSpawnLoc;
var vector OldCloudSpawnLoc;

var bool bNoMore;
var Controller InstigatorController;

replication
{
    reliable if (Role == ROLE_Authority)
        CloudSpawnLoc;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        SetTimer(0.15, True);
        ServerSpawnCloud();
    }
}

function ServeCustomers()
{
    local int i, j, k;
    local array<Actor> Served;
    local Actor A;

    for (i = 0; i < Clouds.Length; i++)
    {
        if (Clouds[i] == None)
            continue;

        for (j = 0; j < Clouds[i].Touching.Length; j++)
        {
            A = Clouds[i].Touching[j];

            if (A == None || Pawn(A) == None || Pawn(A).Health <= 0)
                continue;

            for (k = 0; k < Served.Length; k++)
            {
                if (Served[k] == A)
                    break;
            }

            if (k >= Served.Length)
            {
                if (Instigator == None || Instigator.Controller == None)
                    A.SetDelayedDamageInstigatorController(InstigatorController);

                class'BallisticDamageType'.static.GenericHurt(A, Clouds[i].Density * Damage, Instigator, A.Location, vect(0,0,0), DamageType);

                Served[Served.Length] = A;
            }
        }
    }
}

simulated function Tick(float DeltaTime)
{
    local int i;

    Super.Tick(DeltaTime);

    if (Clouds.Length > 0 && Clouds[Clouds.Length - 1] != None && Clouds[Clouds.Length - 1].Density < 1.5)
    {
        Clouds[Clouds.Length - 1].Density = FMin(1.5, Clouds[Clouds.Length - 1].Density + DeltaTime);

        if (Clouds[Clouds.Length - 1].Emitters.Length > 0)
            Clouds[Clouds.Length - 1].Emitters[0].InitialParticlesPerSecond = Clouds[Clouds.Length - 1].Density * 0.7;
    }

    if (LifeSpan < 3.0 && !bNoMore)
    {
        bNoMore = True;

        for (i = 0; i < Clouds.Length; i++)
        {
            if (Clouds[i] != None)
                Clouds[i].Kill();
        }
    }
}

function Timer()
{
    if (Role != ROLE_Authority)
        return;

    CloudTravel();
    ServeCustomers();
}

function CloudTravel()
{
    if (Owner != None && (Clouds.Length < 1 || Clouds[Clouds.Length - 1] == None || VSize(Clouds[Clouds.Length - 1].Location - Owner.Location) > 192.0))
    {
        if (Clouds.Length > 0 && Clouds[Clouds.Length - 1] != None)
            Clouds[Clouds.Length - 1].Terminate(3.0);

        if (!bNoMore)
            ServerSpawnCloud();
    }
}

simulated function CloudDie(Utility_T10Grenade_GasCloud C)
{
    local int i;

    for (i = 0; i < Clouds.Length; i++)
    {
        if (Clouds[i] == C)
        {
            Clouds.Remove(i, 1);
            return;
        }
    }
}

simulated function SpawnCloud(vector V)
{
    local Utility_T10Grenade_GasCloud C;
    local Actor Underneath;
    local vector HitLocation, HitNormal;
    local rotator CloudRotation;

    Underneath = Trace(HitLocation, HitNormal, V - vect(0,0,1536), V, False);

    if (Mover(Underneath) != None)
        return;

    if (Owner != None)
        CloudRotation = Rotator(Owner.Velocity);
    else if (Clouds.Length > 0 && Clouds[Clouds.Length - 1] != None)
        CloudRotation = Rotator(V - Clouds[Clouds.Length - 1].Location);
    else if (Instigator != None)
        CloudRotation = Rotator(V - Instigator.Location);

    C = Spawn(class'Utility_T10Grenade_GasCloud', Self,, V, CloudRotation);

    if (C != None)
    {
        Clouds[Clouds.Length] = C;
        C.Instigator = Instigator;
        C.MyControl = Self;
    }
}

function ServerSpawnCloud()
{
    local vector HitLocation, HitNormal;
    local Actor HitActor;

    if (Owner == None || bNoMore)
        return;

    HitActor = Trace(HitLocation, HitNormal, Owner.Location + vect(0,0,32), Owner.Location, False);

    if (HitActor == None)
        HitLocation = Owner.Location + vect(0,0,32);

    CloudSpawnLoc = HitLocation;
    SpawnCloud(HitLocation);
}

simulated function PostNetReceive()
{
    if (CloudSpawnLoc != OldCloudSpawnLoc)
    {
        OldCloudSpawnLoc = CloudSpawnLoc;
        SpawnCloud(CloudSpawnLoc);
    }
}

simulated function Destroyed()
{
    local int i;

    for (i = 0; i < Clouds.Length; i++)
    {
        if (Clouds[i] != None)
            Clouds[i].Kill();
    }

    Super.Destroyed();
}

defaultproperties
{
    Damage=6
    DamageType=Class'BW_WD000_KF.Utility_T10Grenade_GasDamage'
    bHidden=True
    bAlwaysRelevant=True
    bReplicateInstigator=True
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=8.0
    bNetNotify=True
}