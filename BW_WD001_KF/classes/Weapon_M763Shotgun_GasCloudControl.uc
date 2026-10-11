//=============================================================================
// Weapon_M763Shotgun_GasCloudControl
//
// Controls the M763 gas cloud system and applies periodic gas damage.
//=============================================================================

class Weapon_M763Shotgun_GasCloudControl extends Actor;

var array<Weapon_M763Shotgun_GasCloud> Clouds;

var() int Damage;
var() class<DamageType> DamageType;

var Vector CloudSpawnLoc;
var Vector OldCloudSpawnLoc;

var bool bNoMore;

var array<Vector> PendingCloudLocations;
var int NextCloudLocation;
var float CloudSpawnAccumulator;
var bool bVisualOnly;


replication
{
	reliable if (Role == ROLE_Authority)
		CloudSpawnLoc;
}


//=============================================================================
// POST BEGIN PLAY
//=============================================================================

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(0.15, True);

	ServerSpawnCloud();
}


//=============================================================================
// DAMAGE PAWNS INSIDE THE CLOUDS
//=============================================================================

function ServeCustomers()
{
	local int i;
	local int j;
	local int k;
	local array<Actor> Served;
	local Actor Victim;

	if (bVisualOnly)
		return;

	for (i = 0; i < Clouds.Length; i++)
	{
		if (Clouds[i] == None)
			continue;

		for (j = 0; j < Clouds[i].Touching.Length; j++)
		{
			Victim = Clouds[i].Touching[j];

			if (Victim == None || Pawn(Victim) == None)
				continue;

			for (k = 0; k < Served.Length; k++)
			{
				if (Served[k] == Victim)
					break;
			}

			if (k >= Served.Length)
			{
				class'BallisticDamageType'.static.GenericHurt
				(
					Victim,
					Clouds[i].Density * Damage,
					Instigator,
					Victim.Location,
					vect(0,0,0),
					DamageType
				);

				Served[Served.Length] = Victim;
			}
		}
	}
}


//=============================================================================
// CLOUD DENSITY AND CLEANUP
//=============================================================================

simulated function Tick(float DT)
{
    local int i;
    local int LastCloud;

    if (Role == ROLE_Authority && NextCloudLocation < PendingCloudLocations.Length)
    {
        CloudSpawnAccumulator += DT;

        if (CloudSpawnAccumulator >= 0.01)
        {
            CloudSpawnAccumulator -= 0.01;

            SpawnCloud(PendingCloudLocations[NextCloudLocation]);
            CloudSpawnLoc = PendingCloudLocations[NextCloudLocation];
            NextCloudLocation++;
        }
    }

    LastCloud = Clouds.Length - 1;

    if (LastCloud >= 0 && Clouds[LastCloud] != None && Clouds[LastCloud].Density < 1.5)
    {
        Clouds[LastCloud].Density = FMin(1.5, Clouds[LastCloud].Density + DT);

        if (Clouds[LastCloud].Emitters.Length > 0)
            Clouds[LastCloud].Emitters[0].InitialParticlesPerSecond = Clouds[LastCloud].Density * 0.7;
    }

    if (LifeSpan < 3 && !bNoMore)
    {
        bNoMore = True;

        for (i = 0; i < Clouds.Length; i++)
        {
            if (Clouds[i] != None)
                Clouds[i].Kill();
        }
    }
}

function SpawnCloudLine(Vector StartLocation, Vector EndLocation)
{
    local Vector Dir, SpawnLoc;
    local float Distance, Spacing;

    if (Role != ROLE_Authority)
        return;

    Dir = Normal(EndLocation - StartLocation);
    Distance = VSize(EndLocation - StartLocation);
    Spacing = 160.0;

    if (Distance <= 0)
        return;

    PendingCloudLocations.Length = 0;
    NextCloudLocation = 0;
    CloudSpawnAccumulator = 0;

    for (SpawnLoc = StartLocation;
        VSize(SpawnLoc - StartLocation) < Distance;
        SpawnLoc += Dir * Spacing)
    {
        PendingCloudLocations[PendingCloudLocations.Length] = SpawnLoc;
    }

    PendingCloudLocations[PendingCloudLocations.Length] = EndLocation;
}


//=============================================================================
// TIMER
//=============================================================================

function Timer()
{
	ServeCustomers();
}


//=============================================================================
// CLOUD REMOVAL
//=============================================================================

simulated function CloudDie(Weapon_M763Shotgun_GasCloud C)
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


//=============================================================================
// SPAWN CLOUD
//=============================================================================

simulated function SpawnCloud(Vector V)
{
	local Weapon_M763Shotgun_GasCloud C;
	local Actor Underneath;
	local Vector HitLoc;
	local Vector HitNorm;
	local Rotator CloudRotation;

	Underneath = Trace
	(
		HitLoc,
		HitNorm,
		V - vect(0,0,1536),
		V,
		False
	);

	if (Mover(Underneath) != None)
		return;

	if (Owner != None)
		CloudRotation = Rotator(Owner.Velocity);
	else if (Clouds.Length > 0 && Clouds[Clouds.Length - 1] != None)
		CloudRotation = Rotator(V - Clouds[Clouds.Length - 1].Location);
	else if (Instigator != None)
		CloudRotation = Rotator(V - Instigator.Location);

	C = Spawn
	(
		class'Weapon_M763Shotgun_GasCloud',
		self,
		,
		V,
		CloudRotation
	);

	if (C != None)
	{
		Clouds[Clouds.Length] = C;
		C.Instigator = Instigator;
	}
}


//=============================================================================
// SERVER CLOUD SPAWN
//=============================================================================

function ServerSpawnCloud()
{
	local Vector HitLoc;
	local Vector HitNorm;
	local Actor T;

	if (Owner == None)
		return;

	T = Trace
	(
		HitLoc,
		HitNorm,
		Owner.Location + vect(0,0,32),
		Owner.Location,
		False
	);

	if (T == None)
		HitLoc = Owner.Location + vect(0,0,32);

	CloudSpawnLoc = HitLoc;

	SpawnCloud(HitLoc);
}


//=============================================================================
// DESTROYED
//=============================================================================

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


//=============================================================================
// REPLICATION
//=============================================================================

simulated event PostNetReceive()
{
	if (CloudSpawnLoc != OldCloudSpawnLoc)
	{
		OldCloudSpawnLoc = CloudSpawnLoc;
		SpawnCloud(CloudSpawnLoc);
	}
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
	Damage=5
	DamageType=Class'BW_WD001_KF.Weapon_M763Shotgun_DamTypeM763Gas'

	bHidden=True
	bAlwaysRelevant=True
	bReplicateInstigator=True
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=10.000000
	bNetNotify=True
}