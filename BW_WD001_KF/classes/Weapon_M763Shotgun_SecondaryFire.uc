class Weapon_M763Shotgun_SecondaryFire extends BallisticShotgunFire;

var() float GasSprayRange;

//=============================================================================
// GAS SPRAY
//=============================================================================

function DoFireEffect()
{
    if (bAltFire)
    {
        DoGasSpray();
        return;
    }

    Super.DoFireEffect();
}

function DoGasSpray()
{
    local Vector StartTrace, Start, End, X, Y, Z;
    local Vector HitLocation, HitNormal, LastHitLoc;
    local Actor Other, LastOther;
    local float Dist, NewDist;
    local int Iterations;
    local Weapon_M763Shotgun_Main M763;
    local Weapon_M763Shotgun_GasCloudControl VisualGC;

    if (Weapon == None || Instigator == None)
        return;

    M763 = Weapon_M763Shotgun_Main(Weapon);

    if (M763 == None || M763.GC == None)
        return;

    Weapon.GetViewAxes(X, Y, Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    X = Normal(X);
    Start = StartTrace;
    End = Start + X * GasSprayRange;
    LastHitLoc = End;
    Dist = GasSprayRange;

    while (Dist > 0 && Iterations < 128)
    {
        Iterations++;

        Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

        if (Other == None)
        {
            LastHitLoc = End;
            break;
        }

        LastHitLoc = HitLocation;

        if (Other.bWorldGeometry || Mover(Other) != None)
            break;

        Start = HitLocation + X * FMax(32, Other.CollisionRadius * 2);
        NewDist = VSize(End - Start);

        if (NewDist >= Dist)
            break;

        Dist = NewDist;
        LastOther = Other;
    }

    M763.GC.SpawnColliders(StartTrace, LastHitLoc);

    VisualGC = Spawn(class'Weapon_M763Shotgun_GasCloudControl',,, StartTrace);

    if (VisualGC != None)
    {
        VisualGC.bVisualOnly = True;
        VisualGC.Instigator = Instigator;
        VisualGC.SpawnCloudLine(StartTrace, LastHitLoc);
    }
}

//=============================================================================
// DEFAULT PROPERTIES
//=============================================================================

defaultproperties
{
    AmmoClass=Class'BW_WD001_KF.Weapon_M763Shotgun_SecondaryAmmo'
    ProjectileClass=Class'BW_WD001_KF.Weapon_M763Shotgun_GasSlugProj'
    FlashEmitterClass=Class'BW_WD001_KF.Weapon_M763Shotgun_FlashEmitter'
	
	GasSprayRange=768.000000
	
    KickMomentum=(X=-45.000000,Z=10.000000)
    ProjPerFire=1
    AmmoPerFire=0
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSoundRef="BWKF_M763_SN.M763.M763Fire1"
    StereoFireSoundRef="BWKF_M763_SN.M763.M763Fire1"
    NoAmmoSoundRef="KF_PumpSGSnd.SG_DryFire"
    FireRate=0.7
    FireAnimRate=1.0
    BotRefireRate=0.200000
    aimerror=1.000000
    Spread=1125.0
    maxVerticalRecoilAngle=1500
    maxHorizontalRecoilAngle=900
	
	LastShotAnim=FireEmpty
    LastShotAnimRate=1.0

    //** View shake **//
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=10.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=3.0
    ShakeRotMag=(X=50.0,Y=50.0,Z=400.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=5.0
    bWaitForRelease=True
    bRandomPitchFireSound=false
}