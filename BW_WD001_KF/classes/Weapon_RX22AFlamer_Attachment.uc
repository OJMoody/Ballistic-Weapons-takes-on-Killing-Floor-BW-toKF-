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
	
	if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;
	
	SprayLastUpdateTime = Level.TimeSeconds;

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

    MovementAnims(0)=RX22A_BW_JogF
    MovementAnims(1)=RX22A_BW_JogB
    MovementAnims(2)=RX22A_BW_JogL
    MovementAnims(3)=RX22A_BW_JogR

    CrouchAnims(0)=RX22A_BW_CHwalkF
    CrouchAnims(1)=RX22A_BW_CHwalkB
    CrouchAnims(2)=RX22A_BW_CHwalkL
    CrouchAnims(3)=RX22A_BW_CHwalkR

    WalkAnims(0)=RX22A_BW_WalkF
    WalkAnims(1)=RX22A_BW_WalkB
    WalkAnims(2)=RX22A_BW_WalkL
    WalkAnims(3)=RX22A_BW_WalkR

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

    TurnRightAnim=RX22A_BW_TurnR
    TurnLeftAnim=RX22A_BW_TurnL
    CrouchTurnRightAnim=RX22A_BW_CHTurnR
    CrouchTurnLeftAnim=RX22A_BW_CHTurnL

    IdleRestAnim=RX22A_BW_Idle
    IdleCrouchAnim=CHRX22A_BW_Idle
    IdleSwimAnim=Swim_Tread						
    IdleWeaponAnim=RX22A_BW_Idle
    IdleHeavyAnim=RX22A_BW_Idle
    IdleRifleAnim=RX22A_BW_Idle
    IdleChatAnim=RX22A_BW_Idle

    FireAnims(0)=RX22A_BW_Fire
    FireAnims(1)=RX22A_BW_Fire
    FireAnims(2)=RX22A_BW_Fire
    FireAnims(3)=RX22A_BW_Fire

    FireAltAnims(0)=RX22A_BW_Fire
    FireAltAnims(1)=RX22A_BW_Fire
    FireAltAnims(2)=RX22A_BW_Fire
    FireAltAnims(3)=RX22A_BW_Fire

    FireCrouchAnims(0)=RX22A_BW_CHFire
    FireCrouchAnims(1)=RX22A_BW_CHFire
    FireCrouchAnims(2)=RX22A_BW_CHFire
    FireCrouchAnims(3)=RX22A_BW_CHFire

    FireCrouchAltAnims(0)=RX22A_BW_CHFire
    FireCrouchAltAnims(1)=RX22A_BW_CHFire
    FireCrouchAltAnims(2)=RX22A_BW_CHFire
    FireCrouchAltAnims(3)=RX22A_BW_CHFire

    HitAnims(0)=RX22A_BW_HitF
    HitAnims(1)=RX22A_BW_HitB
    HitAnims(2)=RX22A_BW_HitL
    HitAnims(3)=RX22A_BW_HitR			

    PostFireBlendStandAnim=RX22A_BW_Blend
    PostFireBlendCrouchAnim=RX22A_BW_CHBlend

    WeaponAmbientScale=2.0
}