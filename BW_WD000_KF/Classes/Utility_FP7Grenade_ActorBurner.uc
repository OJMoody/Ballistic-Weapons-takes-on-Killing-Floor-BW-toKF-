class Utility_FP7Grenade_ActorBurner extends BallisticEmitter
    placeable;

var Actor Victim;
var() class<DamageType> DamageType;
var() int Damage;
var() float BurnTime;
var Controller InstigatorController;

//=============================================================================
// INITIALIZATION
//=============================================================================

function Reset()
{
    Destroy();
}

simulated function Initialize(Actor V)
{
    if (V == None)
        return;

    Victim = V;

    SetTimer(0.5, True);

    if (Level.NetMode == NM_DedicatedServer)
    {
        if (Emitters.Length > 0)
            Emitters[0].Disabled = True;
        if (Emitters.Length > 1)
            Emitters[1].Disabled = True;
        if (Emitters.Length > 2)
            Emitters[2].Disabled = True;
    }
    else
    {
        if (Emitters.Length > 0)
            Emitters[0].SkeletalMeshActor = Victim;
        if (Emitters.Length > 1)
            Emitters[1].SkeletalMeshActor = Victim;
        if (Emitters.Length > 2)
            Emitters[2].SkeletalMeshActor = Victim;
    }

    SetLocation(Victim.Location - vect(0,0,1) * Victim.CollisionHeight);
    SetRotation(Victim.Rotation + rot(0,-16384,0));
    SetBase(Victim);
}

//=============================================================================
// BURN DAMAGE
//=============================================================================

simulated event Timer()
{
    if (BurnTime == -1)
        return;

    BurnTime -= 0.5;

    if (Victim == None || Victim.bDeleteMe)
    {
        Destroy();
        return;
    }

    if (BurnTime <= 2
        || (Victim.PhysicsVolume != None && Victim.PhysicsVolume.bWaterVolume))
    {
        BurnTime = -1;
        Kill();
        bDynamicLight = False;
    }

    if (Victim != None && Level.NetMode != NM_Client && BurnTime > 1)
    {
        if ((Instigator == None || Instigator.Controller == None)
            && InstigatorController != None)
            Victim.SetDelayedDamageInstigatorController(InstigatorController);

        Class'BallisticDamageType'.static.GenericHurt(
            Victim, Damage, Instigator, Location, vect(0,0,0), DamageType);
    }
}

//=============================================================================
// LIFETIME AND CLEANUP
//=============================================================================

simulated event Tick(float DT)
{
    Super.Tick(DT);

    if (Victim == None || Victim.bDeleteMe)
    {
        Destroy();
        return;
    }

    if (Level.NetMode == NM_DedicatedServer && BurnTime <= 1)
    {
        Destroy();
        return;
    }

    if (BurnTime == -1)
        return;
}

simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    if (NewVolume != None && NewVolume.bWaterVolume)
    {
        if (Level.NetMode == NM_DedicatedServer)
            Destroy();
        else
            Kill();
    }
}

defaultproperties
{
    DamageType=Class'BW_WD000_KF.Utility_FP7Grenade_DamType'
    Damage=6
    BurnTime=5.000000


    AutoDestroy=True
    LightType=LT_SubtlePulse
    LightEffect=LE_QuadraticNonIncidence
    LightHue=25
    LightSaturation=100
    LightBrightness=200.000000
    LightRadius=15.000000
    bDynamicLight=True

	AmbientSound=Sound'BWKF_FP7_SN.FP7.FP7FireLoop'
    bFullVolume=True
    bHardAttach=True
    SoundVolume=255
    SoundRadius=128.000000
    bNotOnDedServer=False
}