class Weapon_M46A1Rifle_MineBase extends BallisticProjectile
    abstract;

var() Sound DetonateSound;
var float TriggerStartTime;

simulated function bool IsStationary()
{
    return True;
}

event TakeDamage(int Damage,Pawn EventInstigator,vector HitLocation,vector Momentum,class<DamageType> DamageType,optional int HitIndex)
{
    local Weapon_M46A1Rifle_ProximityMine ProximityMine;
    local Weapon_M46A1Rifle_StickyMine StickyMine;

    if (Role != ROLE_Authority || bDeleteMe || Damage <= 0)
        return;

    ProximityMine = Weapon_M46A1Rifle_ProximityMine(Self);

    if (ProximityMine != None)
    {
        if (ProximityMine.bDetonated)
            return;

        ProximityMine.bDetonated = True;

        if (DetonateSound != None)
            PlaySound(DetonateSound,, 2.0,, 256.0);

        ProximityMine.DetonateMine();
        return;
    }

    StickyMine = Weapon_M46A1Rifle_StickyMine(Self);

    if (StickyMine != None)
    {
        if (StickyMine.bDetonated)
            return;

        if (DetonateSound != None)
            PlaySound(DetonateSound,, 2.0,, 256.0);

        StickyMine.DetonateStickyMine();
        return;
    }

    Destroy();
}

defaultproperties
{
    StaticMesh=StaticMesh'BWKF_M46_SM.pickups.M46_GrenadeProj_Main'
    DetonateSound=Sound'BWKF_M46_SN.M46.OA-AR_GrenadeBeep'
	ImpactManager=Class'BW_WD001_KF.Weapon_M46A1Rifle_ImpactManager'

    MyRadiusDamageType=None
    MyDamageType=None

    ShakeRadius=512.000000
    MotionBlurRadius=384.000000
    MotionBlurFactor=3.000000
    MotionBlurTime=4.000000

    CullDistance=2500.000000
    bNetTemporary=False
    Physics=PHYS_None
    LifeSpan=0.000000
    DrawScale=0.450000
    bUnlit=False

    CollisionRadius=16.000000
    CollisionHeight=16.000000
    bCollideWorld=False
    bProjTarget=True
    bNetNotify=True
}