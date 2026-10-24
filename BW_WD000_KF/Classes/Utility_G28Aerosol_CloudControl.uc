class Utility_G28Aerosol_CloudControl extends Actor;

var array<Utility_G28Aerosol_GasCloud> Clouds;

var() int HealAmount;
var vector CloudSpawnLoc;
var vector OldCloudSpawnLoc;
var bool bNoMore;

replication
{
    reliable if (Role == ROLE_Authority)
        CloudSpawnLoc;
}

//=============================================================================
// INITIALIZATION
//=============================================================================

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Role == ROLE_Authority)
    {
        SetTimer(0.2, true);
        ServerSpawnCloud();
    }
}

//=============================================================================
// HEALING
//=============================================================================

function ServeCustomers()
{
    local int i, j, k, HealthCap;
    local KFHumanPawn TargetHuman;
    local array<KFHumanPawn> Served;

    if (Role != ROLE_Authority)
        return;

    for (i = 0; i < Clouds.Length; i++)
    {
        if (Clouds[i] == None)
            continue;

        for (j = 0; j < Clouds[i].Touching.Length; j++)
        {
            TargetHuman = KFHumanPawn(Clouds[i].Touching[j]);

            // Only living human players can be healed.
            if (TargetHuman == None || TargetHuman.Health <= 0)
                continue;

            // Do not heal the same player more than once per cycle,
            // even if multiple cloud sections overlap.
            for (k = 0; k < Served.Length; k++)
            {
                if (Served[k] == TargetHuman)
                    break;
            }

            if (k < Served.Length)
                continue;

            // Heal the thrower and their teammates only.
            if (TargetHuman == Instigator
                || (Instigator != None
                && Instigator.Controller != None
                && TargetHuman.Controller != None
                && TargetHuman.Controller.SameTeamAs(Instigator.Controller)))
            {
                HealthCap = TargetHuman.SuperHealthMax;
                TargetHuman.GiveHealth(HealAmount, HealthCap);
                Served[Served.Length] = TargetHuman;
            }
        }
    }
}

//=============================================================================
// CLOUD LIFECYCLE
//=============================================================================

simulated function Tick(float DeltaTime)
{
    local int LastCloud;

    if (Clouds.Length > 0)
    {
        LastCloud = Clouds.Length - 1;

        if (Clouds[LastCloud] != None && Clouds[LastCloud].Density < 4.0)
        {
            Clouds[LastCloud].Density = FMin(3.0, Clouds[LastCloud].Density + DeltaTime);

            if (Clouds[LastCloud].Emitters.Length > 0
                && Clouds[LastCloud].Emitters[0] != None)
            {
                Clouds[LastCloud].Emitters[0].InitialParticlesPerSecond =
                    Clouds[LastCloud].Density * 0.7;
            }
        }
    }

    if (LifeSpan < 3.0 && !bNoMore)
    {
        bNoMore = true;
        KillClouds();
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
    local int LastCloud;

    if (Owner == None)
        return;

    LastCloud = Clouds.Length - 1;

    if (LastCloud < 0 || Clouds[LastCloud] == None
        || VSize(Clouds[LastCloud].Location - Owner.Location) > 192.0)
    {
        if (LastCloud >= 0 && Clouds[LastCloud] != None)
            Clouds[LastCloud].Terminate(3.0);

        if (!bNoMore)
            ServerSpawnCloud();
    }
}

//=============================================================================
// SPAWNING AND REMOVAL
//=============================================================================

simulated function SpawnCloud(Vector SpawnLocation)
{
    local Utility_G28Aerosol_GasCloud C;
    local int LastCloud;
    local Rotator CloudRotation;

    if (Owner != None)
        CloudRotation = Rotator(Owner.Velocity);
    else if (Clouds.Length > 0)
    {
        LastCloud = Clouds.Length - 1;

        if (Clouds[LastCloud] != None)
            CloudRotation = Rotator(SpawnLocation - Clouds[LastCloud].Location);
        else if (Instigator != None)
            CloudRotation = Rotator(SpawnLocation - Instigator.Location);
    }
    else if (Instigator != None)
        CloudRotation = Rotator(SpawnLocation - Instigator.Location);

    C = Spawn(
        class'BW_WD000_KF.Utility_G28Aerosol_GasCloud',
        self,
        ,
        SpawnLocation,
        CloudRotation
    );

    if (C != None)
    {
        Clouds[Clouds.Length] = C;
        C.Instigator = Instigator;
    }
}

function ServerSpawnCloud()
{
    local Vector HitLocation, HitNormal;
    local Actor HitActor;

    if (Role != ROLE_Authority || Owner == None || bNoMore)
        return;

    HitActor = Trace(
        HitLocation,
        HitNormal,
        Owner.Location + vect(0,0,32),
        Owner.Location,
        false
    );

    if (HitActor == None)
        HitLocation = Owner.Location + vect(0,0,32);

    CloudSpawnLoc = HitLocation;
    SpawnCloud(HitLocation);
}

simulated function CloudDie(Utility_G28Aerosol_GasCloud C)
{
    local int i;

    for (i = 0; i < Clouds.Length; i++)
    {
        if (Clouds[i] == C)
        {
            Clouds.Remove(i, 1);
            break;
        }
    }
}

simulated function KillClouds()
{
    local int i;

    for (i = 0; i < Clouds.Length; i++)
    {
        if (Clouds[i] != None)
            Clouds[i].Kill();
    }
}

//=============================================================================
// REPLICATION AND CLEANUP
//=============================================================================

simulated event PostNetReceive()
{
    if (CloudSpawnLoc != OldCloudSpawnLoc)
    {
        OldCloudSpawnLoc = CloudSpawnLoc;
        SpawnCloud(CloudSpawnLoc);
    }
}

simulated function Destroyed()
{
    KillClouds();
    Super.Destroyed();
}

defaultproperties
{
    HealAmount=3
    bHidden=True
    bAlwaysRelevant=True
    bReplicateInstigator=True
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=7.000000
    bNetNotify=True
}