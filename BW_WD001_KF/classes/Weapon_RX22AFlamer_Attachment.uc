class Weapon_RX22AFlamer_Attachment extends BallisticAttachment;

var Weapon_RX22AFlamer_Spray Flame;
var Weapon_RX22AFlamer_GasSpray GasSpray;

var Weapon_RX22AFlamer_Tank RX22ATank;

struct FlameHit
{
    var vector HitLoc;
    var vector HitNorm;
    var float HitTime;
};

var array<FlameHit> FlameHits;
var Weapon_RX22AFlamer_FireHit FlameHitFX;
var float KillFlameTime;
var float SprayLastUpdateTime;

function InitFor(Inventory I)
{
    Super.InitFor(I);

    SpawnRX22ATank();
}

function SpawnRX22ATank()
{
    if (Role != ROLE_Authority || Instigator == None || RX22ATank != None)
        return;

    RX22ATank = Spawn(class'Weapon_RX22AFlamer_Tank', Instigator,, Instigator.Location, Instigator.Rotation);

    if (RX22ATank != None)
    {
        if (!Instigator.AttachToBone(RX22ATank, 'CHR_Ribcage'))
        {
            RX22ATank.Destroy();
            RX22ATank = None;
        }
        else
            RX22ATank.SetRelativeRotation(RX22ATank.TankRotation);
			RX22ATank.SetRelativeLocation(RX22ATank.TankOffset);
    }
}

simulated function InstantFireEffects(byte Mode)
{
    local vector TipLocation;
    local rotator AimRotation;
	
	log("RX22A InstantFireEffects ENTERED");
    log("RX22A NetMode: "$Level.NetMode);
    log("RX22A Owner: "$Owner);
    log("RX22A Instigator: "$Instigator);
    log("RX22A Attachment Location: "$Location);
	
	if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;
	
	SprayLastUpdateTime = Level.TimeSeconds;
	
	log("RX22A SPRAY UPDATE" @ "Time:" @ Level.TimeSeconds @ "LastUpdate:" @ SprayLastUpdateTime);

    TipLocation = GetTracerStart();
    AimRotation = Instigator.GetViewRotation();

    if (Mode == 0)
    {
        if (GasSpray != None)
        {
            GasSpray.Kill();
            GasSpray.bHidden = false;
            GasSpray = None;
        }

        if (Flame == None)
            Flame = Spawn(class'Weapon_RX22AFlamer_Spray', Instigator,, TipLocation, AimRotation);

        if (Flame != None)
        {
            Flame.bHidden = !Weapon_RX22AFlamer_Main(Instigator.Weapon).bBWThirdPersonCamera;
            Flame.SetLocation(TipLocation);
            Flame.SetRotation(AimRotation);
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
            GasSpray = Spawn(class'Weapon_RX22AFlamer_GasSpray', Instigator,, TipLocation, AimRotation);

        if (GasSpray != None)
        {
            GasSpray.bHidden = !Weapon_RX22AFlamer_Main(Instigator.Weapon).bBWThirdPersonCamera;
            GasSpray.SetLocation(TipLocation);
            GasSpray.SetRotation(AimRotation);
            GasSpray.SetFlameRange(VSize(mHitLocation - GasSpray.Location));

            Weapon_RX22AFlamer_Main(Instigator.Weapon).GasSpray = GasSpray;
        }
    }
}

simulated function vector GetTracerStart()
{
    local Pawn P;
    local BallisticWeapon BW;

    P = Pawn(Owner);

    if (P == None)
        return Location;

    BW = BallisticWeapon(P.Weapon);

    if (BW != None && BW.bBWThirdPersonCamera)
        return GetBoneCoords('TP_tip').Origin;

    if (P.Weapon != None)
        return P.Weapon.GetEffectStart();

    return GetBoneCoords('TP_tip').Origin;
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

    // Stop the spray when firing updates cease.
    if ((Flame != None || GasSpray != None)
        && Level.TimeSeconds - SprayLastUpdateTime > 0.30)
    {
        StopSpray();
    }
}

simulated function StopSpray()
{
    log("RX22A StopSpray CALLED - FlashCount:" @ FlashCount);
	
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
    if (FlashCount > 0)
        InstantFireEffects(FiringMode);
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

    if (Role == ROLE_Authority && RX22ATank != None)
        RX22ATank.Destroy();

    Super.Destroyed();
}


defaultproperties
{
    MeshRef="BWKF_RX22A_A.RX22A_TP_Mesh"
    DrawScale=0.250000

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