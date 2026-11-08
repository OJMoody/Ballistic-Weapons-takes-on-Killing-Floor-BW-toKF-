class Weapon_RX22AFlamer_Attachment extends BallisticAttachment;

var Weapon_RX22AFlamer_Spray Flame;
var Weapon_RX22AFlamer_GasSpray GasSpray;

struct FlameHit
{
    var vector HitLoc;
    var vector HitNorm;
    var float HitTime;
};

var array<FlameHit> FlameHits;
var Weapon_RX22AFlamer_FireHit FlameHitFX;
var float KillFlameTime;

simulated function InstantFireEffects(byte Mode)
{
    local vector TipLocation;

    if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;

    TipLocation = GetTracerStart();

    if (Mode == 0)
    {
        if (GasSpray != None)
        {
            GasSpray.Kill();
            GasSpray.bHidden = false;
            GasSpray = None;
        }

        if (Flame == None)
            Flame = Spawn(class'Weapon_RX22AFlamer_Spray', Instigator,, TipLocation, Rotator(mHitLocation - TipLocation));

        if (Flame != None)
        {
            Flame.bHidden = Instigator.IsFirstPerson();
            Flame.SetLocation(TipLocation);
            Flame.SetRotation(Rotator(mHitLocation - Flame.Location));
            Flame.SetFlameRange(VSize(mHitLocation - Flame.Location));

            Weapon_RX22AFlamer_Main(Instigator.Weapon).Flame = Flame;
        }
    }
    else if (Mode == 1)
    {
        if (Flame != None)
        {
            Flame.Kill();
            Flame.bHidden = false;
            Flame = None;
        }

        if (GasSpray == None)
            GasSpray = Spawn(class'Weapon_RX22AFlamer_GasSpray', Instigator,, TipLocation, Rotator(mHitLocation - TipLocation));

        if (GasSpray != None)
        {
            GasSpray.bHidden = Instigator.IsFirstPerson();
            GasSpray.SetLocation(TipLocation);
            GasSpray.SetRotation(Rotator(mHitLocation - GasSpray.Location));
            GasSpray.SetFlameRange(VSize(mHitLocation - GasSpray.Location));

            Weapon_RX22AFlamer_Main(Instigator.Weapon).GasSpray = GasSpray;
        }
    }
}

simulated function QueueFlameHit(vector Loc, vector Norm)
{
    local int i;

    if (Instigator == None)
        return;

    i = FlameHits.Length;
    FlameHits.Length = i + 1;
    FlameHits[i].HitLoc = Loc;
    FlameHits[i].HitNorm = Norm;
    FlameHits[i].HitTime = Level.TimeSeconds + VSize(Instigator.Location - Loc) / 3600;
}

simulated event Tick(float DT)
{
    local int i;

    Super.Tick(DT);

    for (i = 0; i < FlameHits.Length; i++)
    {
        if (Level.TimeSeconds >= FlameHits[i].HitTime)
        {
            DoFlameHit(FlameHits[i].HitLoc, FlameHits[i].HitNorm);
            FlameHits.Remove(i, 1);
            i--;
        }
    }

    if (FlameHitFX != None && Level.TimeSeconds >= KillFlameTime)
        EndFlameHit();
}

simulated function StopSpray()
{
    if (Flame != None)
    {
        Flame.Kill();
        Flame.bHidden = false;
        Flame = None;
    }

    if (GasSpray != None)
    {
        GasSpray.Kill();
        GasSpray.bHidden = false;
        GasSpray = None;
    }

    if (Instigator != None && Weapon_RX22AFlamer_Main(Instigator.Weapon) != None)
    {
        Weapon_RX22AFlamer_Main(Instigator.Weapon).Flame = None;
        Weapon_RX22AFlamer_Main(Instigator.Weapon).GasSpray = None;
    }
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();

    if (FlashCount > 0)
        InstantFireEffects(FiringMode);
    else
        StopSpray();
}

simulated function DoFlameHit(vector Loc, vector Norm)
{
	if (FlameHitFX == None)
        FlameHitFX = Spawn(class'Weapon_RX22AFlamer_FireHit',,, Loc, Rotator(Norm));
    else
    {
        FlameHitFX.SetLocation(Loc);
        FlameHitFX.SetRotation(Rotator(Norm));
    }

    KillFlameTime = Level.TimeSeconds + 0.12;
}

simulated function EndFlameHit()
{
    if (FlameHitFX != None)
    {
        FlameHitFX.Kill();
        FlameHitFX = None;
    }
}

simulated event Destroyed()
{
    EndFlameHit();
    StopSpray();
    Super.Destroyed();
}

defaultproperties
{
    MeshRef="KF_Weapons3rd_Trip.Flamethrower_3rd"

    MovementAnims(0)=JogF_Flamethrower
    MovementAnims(1)=JogB_Flamethrower
    MovementAnims(2)=JogL_Flamethrower
    MovementAnims(3)=JogR_Flamethrower

    CrouchAnims(0)=CHwalkF_Flamethrower
    CrouchAnims(1)=CHwalkB_Flamethrower
    CrouchAnims(2)=CHwalkL_Flamethrower
    CrouchAnims(3)=CHwalkR_Flamethrower

    WalkAnims(0)=WalkF_Flamethrower
    WalkAnims(1)=WalkB_Flamethrower
    WalkAnims(2)=WalkL_Flamethrower
    WalkAnims(3)=WalkR_Flamethrower

    AirStillAnim=JumpF_Mid
    AirAnims(0)=JumpF_Mid
    AirAnims(1)=JumpF_Mid
    AirAnims(2)=JumpL_Mid
    AirAnims(3)=JumpR_Mid

    TakeoffStillAnim=JumpF_Takeoff
    TakeoffAnims(0)=JumpF_Takeoff
    TakeoffAnims(1)=JumpF_Takeoff
    TakeoffAnims(2)=JumpL_Takeoff
    TakeoffAnims(3)=JumpR_Takeoff

    LandAnims(0)=JumpF_Land
    LandAnims(1)=JumpF_Land
    LandAnims(2)=JumpL_Land
    LandAnims(3)=JumpR_Land

    TurnRightAnim=TurnR_Flamethrower
    TurnLeftAnim=TurnL_Flamethrower
    CrouchTurnRightAnim=CH_TurnR_Flamethrower
    CrouchTurnLeftAnim=CH_TurnL_Flamethrower

    IdleRestAnim=Idle_Flamethrower
    IdleCrouchAnim=CHIdle_Flamethrower
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_Flamethrower
    IdleHeavyAnim=Idle_Flamethrower
    IdleRifleAnim=Idle_Flamethrower
    IdleChatAnim=Idle_Flamethrower

    FireAnims(0)=Fire_Flamethrower
    FireAnims(1)=Fire_Flamethrower
    FireAnims(2)=Fire_Flamethrower
    FireAnims(3)=Fire_Flamethrower

    FireAltAnims(0)=Fire_Flamethrower
    FireAltAnims(1)=Fire_Flamethrower
    FireAltAnims(2)=Fire_Flamethrower
    FireAltAnims(3)=Fire_Flamethrower

    FireCrouchAnims(0)=CHFire_Flamethrower
    FireCrouchAnims(1)=CHFire_Flamethrower
    FireCrouchAnims(2)=CHFire_Flamethrower
    FireCrouchAnims(3)=CHFire_Flamethrower

    FireCrouchAltAnims(0)=CHFire_Flamethrower
    FireCrouchAltAnims(1)=CHFire_Flamethrower
    FireCrouchAltAnims(2)=CHFire_Flamethrower
    FireCrouchAltAnims(3)=CHFire_Flamethrower

    HitAnims(0)=HitF_Flamethrower
    HitAnims(1)=HitB_Flamethrower
    HitAnims(2)=HitL_Flamethrower
    HitAnims(3)=HitR_Flamethrower

    PostFireBlendStandAnim=Blend_Flamethrower
    PostFireBlendCrouchAnim=CHBlend_Flamethrower

    WeaponAmbientScale=2.0
}