class BallisticIceProjectileSmall extends BallisticProjectile;

var Emitter TrailEffect;


//=============================================================================
// INITIALISATION
//=============================================================================

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    // Preserve the original Ice Dart's initial velocity.
    Velocity = Speed * Vector(Rotation);

    // Initialise the original tracer and trail effects.
    if (Level.NetMode != NM_DedicatedServer && !PhysicsVolume.bWaterVolume)
    {
        if (Trail == None)
        {
            Trail = Spawn(class'IceDartTracer', self);

            if (Trail != None)
            {
                Trail.Lifespan = Lifespan;
                Trail.SetBase(self);
            }
        }

        if (Level.DetailMode >= DM_SuperHigh)
        {
            TrailEffect = Spawn(class'IceDartTrail', self);

            if (TrailEffect != None)
            {
                TrailEffect.Lifespan = Lifespan;
                TrailEffect.SetBase(self);
            }
        }
    }
}


//=============================================================================
// CLEANUP
//=============================================================================

simulated function Destroyed()
{
    if (TrailEffect != None)
    {
        TrailEffect.Kill();
        TrailEffect.SetPhysics(PHYS_None);
    }

    Super.Destroyed();
}


//=============================================================================
// IMPACT
//=============================================================================

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    local Vector X;
    local Vector TempHitLocation;
    local Vector HitNormal;
    local array<int> HitPoints;
    local KFPawn HitPawn;

    if (Other == None || Other == Instigator || Other.Base == Instigator
        || !Other.bBlockHitPointTraces)
        return;

    X = Vector(Rotation);

    // Locational damage for ballistic hitbox attachments.
    if (ROBulletWhipAttachment(Other) != None)
    {
        if (!Other.Base.bDeleteMe)
        {
            Other = Instigator.HitPointTrace(
                TempHitLocation,
                HitNormal,
                HitLocation + (200 * X),
                HitPoints,
                HitLocation,
                ,
                1
            );

            if (Other == None || HitPoints.Length == 0)
                return;

            HitPawn = KFPawn(Other);

            if (Role == ROLE_Authority && HitPawn != None)
            {
                if (!HitPawn.bDeleteMe)
                {
                    HitPawn.ProcessLocationalDamage(
                        Damage,
                        Instigator,
                        TempHitLocation,
                        MomentumTransfer * Normal(Velocity),
                        MyDamageType,
                        HitPoints
                    );
                }
            }
        }
    }
    else
    {
        // Preserve the original headshot multiplier.
        if (Pawn(Other) != None && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
        {
            Other.TakeDamage(
                Damage * 1.0,
                Instigator,
                HitLocation,
                MomentumTransfer * Normal(Velocity),
                MyDamageType
            );
        }
        else
        {
            Other.TakeDamage(Damage, Instigator, HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType);
        }
    }

    // Impact effect.
    //if (ImpactEffect != None && Level.NetMode != NM_DedicatedServer && !Level.bDropDetail && Level.DetailMode > DM_Low)
    //{
    //    Spawn(ImpactEffect,,, Location, rotator(-HitNormal));
    //}
	
	// No impact effect for now.

    // No penetration.
    Destroy();
}

//=============================================================================
// WALL IMPACT
//=============================================================================

simulated function HitWall(Vector HitNormal, Actor Wall)
{
    if (Role == ROLE_Authority)
        Explode(Location, HitNormal);
}


//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    ExplosionDecal=Class'KFMod.NailGunDecal'
	MyDamageType=Class'BW_Core_KF.DamTypeFreezerDart'
	ImpactManager=Class'BW_Core_KF.IE_BallisticIceProjectileSmall'
	bCheckHitSurface=True
	bPenetrate=False
    bTearOnExplode=False

    Speed=5000.000000
    MaxSpeed=7000.000000
	LifeSpan=3.000000
    Damage=45.000000
    
	StaticMesh=StaticMesh'BWKF_Core_SM.IceProj.IceDart-PROJ'
    DrawScale=0.500000
}