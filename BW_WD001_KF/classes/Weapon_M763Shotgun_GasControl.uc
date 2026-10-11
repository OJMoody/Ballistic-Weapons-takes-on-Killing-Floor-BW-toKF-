class Weapon_M763Shotgun_GasControl extends Actor;

var array<Weapon_M763Shotgun_GasCollider> Clouds;
var() int Damage;
var() class<DamageType> DamageType;
var Controller InstigatorController;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.15, True);
}

function SpawnColliders(Vector StartLocation, Vector HitLocation)
{
	local float MaxSpawnRange;
	local Vector SpawnLoc, Dir, AddPerCycle;
	local Weapon_M763Shotgun_GasCollider C;

	if (Role != ROLE_Authority)
		return;

	Dir = Normal(HitLocation - StartLocation);
	MaxSpawnRange = VSize(HitLocation - StartLocation);

	if (MaxSpawnRange <= 0)
		return;

	AddPerCycle = Dir * 2 * class'Weapon_M763Shotgun_GasCollider'.default.CollisionRadius;

	for (SpawnLoc = StartLocation + Dir * 1.2 * (class'Weapon_M763Shotgun_GasCollider'.default.CollisionRadius + class'Pawn'.default.CollisionRadius);
		VSize(SpawnLoc - StartLocation) < MaxSpawnRange;
		SpawnLoc += AddPerCycle)
	{
		C = Spawn(class'Weapon_M763Shotgun_GasCollider', Self,, SpawnLoc);

		if (C != None)
		{
			C.Instigator = Instigator;
			Clouds[Clouds.Length] = C;
		}
	}
}

function LostChild(Actor A)
{
	local int i;

	for (i = 0; i < Clouds.Length; i++)
	{
		if (Clouds[i] == A)
		{
			Clouds.Remove(i, 1);
			break;
		}
	}

	if (Clouds.Length == 0 && Owner == None)
		Destroy();
}

function ServeCustomers()
{
	local int i, j, k;
	local array<Actor> Served;
	local Actor Victim;

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
				if (Instigator == None || Instigator.Controller == None)
					Victim.SetDelayedDamageInstigatorController(InstigatorController);

				class'BallisticDamageType'.static.GenericHurt(Victim, Damage, Instigator, Victim.Location, vect(0,0,0), DamageType);
				Served[Served.Length] = Victim;
			}
		}
	}
}

function Timer()
{
	if (Role == ROLE_Authority)
		ServeCustomers();
}

simulated function Destroyed()
{
	local int i;

	for (i = 0; i < Clouds.Length; i++)
	{
		if (Clouds[i] != None)
			Clouds[i].Destroy();
	}

	Super.Destroyed();
}

defaultproperties
{
	Damage=9
	DamageType=Class'BW_WD001_KF.Weapon_M763Shotgun_DamTypeM763Gas'
	bHidden=True
}