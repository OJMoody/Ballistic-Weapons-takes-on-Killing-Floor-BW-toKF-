class Utility_T10Grenade_CloudControl extends Actor;

var array<Utility_T10Grenade_GasCloud> Clouds;

var() int Damage;
var() class<DamageType> DamageType;

var vector CloudSpawnLoc;
var vector OldCloudSpawnLoc;

var vector SprayLocation;
var rotator SprayRotation;
var bool bSprayDataReady;
var bool bClientEffectsStarted;
var bool bClientEffectsStopped;
var Utility_T10Grenade_Spray T10Spray;

var bool bNoMore;
var Controller InstigatorController;

replication
{
    reliable if (Role == ROLE_Authority)
        CloudSpawnLoc, SprayLocation, SprayRotation, bSprayDataReady;
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

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    StartClientEffects();
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (CloudSpawnLoc != OldCloudSpawnLoc)
    {
        OldCloudSpawnLoc = CloudSpawnLoc;
        SpawnCloud(CloudSpawnLoc);
    }

    StartClientEffects();
}

simulated function StartClientEffects()
{
    if (Level.NetMode == NM_DedicatedServer || !bSprayDataReady || bClientEffectsStarted)
		return;

    bClientEffectsStarted = True;

    T10Spray = Spawn(class'Utility_T10Grenade_Spray', Self,, SprayLocation, SprayRotation);

    if (T10Spray != None && Owner != None)
		Owner.AttachToBone(T10Spray, 'Tip');

    PlaySound(Sound'BWKF_T10_SN.T10.T10-Ignite',, 0.7,, 128, 1.0, True);
    AmbientSound = Sound'BWKF_T10_SN.T10.T10-toxinLoop';
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

    // Gradually increase the density of the newest gas cloud.
    if (Clouds.Length > 0 && Clouds[Clouds.Length - 1] != None && Clouds[Clouds.Length - 1].Density < 1.5)
    {
        Clouds[Clouds.Length - 1].Density = FMin(1.5, Clouds[Clouds.Length - 1].Density + DeltaTime);

        if (Clouds[Clouds.Length - 1].Emitters.Length > 0)
            Clouds[Clouds.Length - 1].Emitters[0].InitialParticlesPerSecond = Clouds[Clouds.Length - 1].Density * 0.7;
    }

    // Stop client effects when the gas cloud is ending.
    if (Level.NetMode == NM_Client && LifeSpan < 3.0 && !bClientEffectsStopped)
    {
        bClientEffectsStopped = True;

        AmbientSound = None;

        if (T10Spray != None)
        {
            T10Spray.Destroy();
            T10Spray = None;
        }
    }

    // Stop producing gas and kill existing clouds near the end of the effect.
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

simulated function Destroyed()
{
    local int i;

    AmbientSound = None;

    if (T10Spray != None)
    {
        T10Spray.Destroy();
        T10Spray = None;
    }

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