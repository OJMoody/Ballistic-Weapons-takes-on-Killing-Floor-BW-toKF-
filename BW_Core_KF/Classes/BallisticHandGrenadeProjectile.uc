class BallisticHandGrenadeProjectile extends KFMod.Nade
    abstract;
	
var() class<Actor> GrenadeExplosionEffectClass;
var() SoundGroup GrenadeExplosionSound;

//=============================================================================
// DIRECT IMPACT DAMAGE
//=============================================================================

var() int ImpactDamage;
var() class<DamageType> ImpactDamageType;

var bool bHasAppliedImpactDamage;

//=============================================================================
// ACTOR IMPACT
//=============================================================================

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    local KFHumanPawn Human;

    if (Other == None || Other == self || Other == Instigator)
        return;

    if (Other.Base == Instigator)
        return;

    // Preserve friendly-player collision filtering.
    Human = KFHumanPawn(Other);

    if (Human != None && Instigator != None
        && Human.PlayerReplicationInfo != None
        && Instigator.PlayerReplicationInfo != None
        && Human.PlayerReplicationInfo.Team != None
        && Instigator.PlayerReplicationInfo.Team != None
        && Human.PlayerReplicationInfo.Team.TeamIndex
            == Instigator.PlayerReplicationInfo.Team.TeamIndex)
        return;

    // Apply direct impact damage once, on the server.
    if (Role == ROLE_Authority && !bHasAppliedImpactDamage
        && ImpactDamage > 0 && ImpactDamageType != None)
    {
        bHasAppliedImpactDamage = true;
        Other.TakeDamage(ImpactDamage, Instigator, HitLocation, Velocity, ImpactDamageType);
    }

    // Bounce off actors instead of stopping on contact.
    HitWall(Normal(Location - Other.Location), Other);
}


//=============================================================================
// BOUNCING
//=============================================================================

simulated function HitWall(Vector HitNormal, Actor Wall)
{
    local Vector VNorm;

    if (bHasExploded)
        return;

    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    Speed = VSize(Velocity);

    if (Speed < 20)
    {
        bBounce = false;
        SetPhysics(PHYS_None);
    }
    else if (Level.NetMode != NM_DedicatedServer)
        PlaySound(ImpactSound, SLOT_Misc);
}


//=============================================================================
// EXPLOSION
//=============================================================================

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local PlayerController LocalPlayer;
    local Projectile P;
    local byte i;

    if (bHasExploded)
        return;

    bHasExploded = True;
    BlowUp(HitLocation);

    if (GrenadeExplosionSound != None)
        PlaySound(GrenadeExplosionSound,, 2.0);
    else if (ExplodeSounds.Length > 0)
        PlaySound(ExplodeSounds[Rand(ExplodeSounds.Length)],, 2.0);

    // Preserve the stock KF grenade shrapnel.
    for (i = Rand(6); i < 10; i++)
    {
        P = Spawn(ShrapnelClass,,, HitLocation, RotRand(True));

        if (P != None)
            P.RemoteRole = ROLE_None;
    }

    if (EffectIsRelevant(Location, False))
    {
        if (GrenadeExplosionEffectClass != None)
            Spawn(GrenadeExplosionEffectClass,,, HitLocation, Rotator(HitNormal));
        else
            Spawn(Class'KFMod.KFNadeExplosion',,, HitLocation, Rotator(Vect(0,0,1)));

        Spawn(ExplosionDecal, self,, HitLocation, Rotator(-HitNormal));
    }

    // Preserve the stock nearby-player screen shake.
    LocalPlayer = Level.GetLocalPlayerController();

    if (LocalPlayer != None
        && VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius * 1.5)
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

    Destroy();
}


//=============================================================================
// DEFAULTS
//=============================================================================

defaultproperties
{
    ImpactDamage=0
    ImpactDamageType=None

    DampenFactor=0.050000
    DampenFactorParallel=0.350000

    ExplodeTimer=3.000000
}