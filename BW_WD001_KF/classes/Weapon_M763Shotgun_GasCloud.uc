class Weapon_M763Shotgun_GasCloud extends BallisticEmitter
	placeable;

var AvoidMarker Fear;
var Weapon_M763Shotgun_GasCloudControl MyControl;
var float Density;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	MyControl = Weapon_M763Shotgun_GasCloudControl(Owner);

	if (Level.NetMode != NM_Client)
	{
		Fear = Spawn(class'AvoidMarker');

		if (Fear != None)
		{
			Fear.SetCollisionSize(200, 200);
			Fear.StartleBots();
		}

		if (Level.NetMode == NM_DedicatedServer)
		{
			if (Emitters.Length > 0)
				Emitters[0].Disabled = True;

			if (Emitters.Length > 1)
				Emitters[1].Disabled = True;
		}
	}
}

function Reset()
{
	Destroy();
}

simulated function Terminate(float Delay)
{
	SetTimer(Delay, False);
}

simulated function Timer()
{
	if (Level.NetMode == NM_DedicatedServer)
		GotoState('DSDying');
	else
		Kill();
}

state DSDying
{
Begin:
	Sleep(3.0);
	Destroy();
}

simulated function Destroyed()
{
	if (MyControl != None)
		MyControl.CloudDie(Self);

	if (Fear != None)
		Fear.Destroy();

	Super.Destroyed();
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if (NewVolume.bWaterVolume)
		Kill();
}

defaultproperties
{
	Density=1.000000

	Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		FadeOut=True
		FadeIn=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=True
		Acceleration=(Z=20.000000)
		ColorScale(0)=(Color=(B=200,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=200,G=255,R=255,A=255))
		ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Z=(Min=0.200000,Max=0.200000))
		Opacity=0.490000
		FadeOutStartTime=1.050000
		FadeInEndTime=1.050000
		CoordinateSystem=PTCS_Relative
		//MaxParticles=200
		MaxParticles=5
		StartLocationRange=(X=(Min=-96.000000,Max=96.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=-32.000000,Max=32.000000))
		SpinsPerSecondRange=(X=(Max=0.010000))
		StartSpinRange=(X=(Max=1.000000))
		SizeScale(0)=(RelativeSize=0.300000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=150.000000,Max=200.000000),Z=(Min=150.000000,Max=200.000000))
		//InitialParticlesPerSecond=0.700000
		InitialParticlesPerSecond=0.500000
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'BWKF_Core_T.Effects.Smoke7'
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=3.000000,Max=3.000000)
		StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=-10.000000))
	End Object
	Emitters(0)=SpriteEmitter'SpriteEmitter1'

	Begin Object Class=SpriteEmitter Name=SpriteEmitter0
		FadeOut=True
		FadeIn=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=True
		ColorScale(0)=(Color=(B=200,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=200,G=255,R=255,A=255))
		ColorMultiplierRange=(X=(Min=0.000000,Max=0.200000),Z=(Min=0.000000,Max=0.200000))
		Opacity=0.580000
		FadeOutStartTime=1.450000
		FadeInEndTime=0.675000
		CoordinateSystem=PTCS_Relative
		//MaxParticles=20
		MaxParticles=1
		StartLocationRange=(X=(Min=-64.000000,Max=64.000000))
		SpinsPerSecondRange=(X=(Max=0.030000))
		StartSpinRange=(X=(Min=1.000000,Max=1.000000))
		SizeScale(0)=(RelativeSize=0.200000)
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
		//InitialParticlesPerSecond=0.750000
		InitialParticlesPerSecond=0.100000
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'BWKF_Core_T.Particles.Smoke6'
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=2.500000,Max=2.500000)
	End Object
	Emitters(1)=SpriteEmitter'SpriteEmitter0'

	AutoDestroy=True
	CollisionRadius=192.000000
	CollisionHeight=192.000000
	bCollideActors=True
	bUseCylinderCollision=True
	bNotOnDedServer=False
}