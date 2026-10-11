class Weapon_M763Shotgun_GasCollider extends Actor
	placeable;

var AvoidMarker Fear;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode != NM_Client)
	{
		Fear = Spawn(class'AvoidMarker');

		if (Fear != None)
		{
			Fear.SetCollisionSize(200, 200);
			Fear.StartleBots();
		}
	}
}

function Reset()
{
	Destroy();
}

function Destroyed()
{
	if (Fear != None)
		Fear.Destroy();

	Super.Destroyed();
}

function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if (NewVolume.bWaterVolume)
		Destroy();
}

defaultproperties
{
	bHidden=True
	LifeSpan=6.000000
	CollisionRadius=150.000000
	CollisionHeight=150.000000
	bCollideActors=True
	bUseCylinderCollision=True
}