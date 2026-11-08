class Weapon_RX22AFlamer_Tank extends Actor;

#exec OBJ LOAD FILE=BWKF_RX22A_A.ukx

var() rotator TankRotation;
var() vector TankOffset;

/*simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (Owner != None)
    {
        SetRelativeRotation(TankRotation);
        SetRelativeLocation(TankOffset);
    }
}*/

// The commented out tick function allows for the tank offset and rotation to be adjusted with editactor. We dont want this to tick in standard play however its here for when you need it

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=Mesh'BWKF_RX22A_A.RX22ATank_TP_Mesh'
	DrawScale=0.25
	TankRotation=(Pitch=0,Yaw=-16384,Roll=16384)
	TankOffset=(X=-10.000000,Y=5.000000,Z=0.000000)

    bOnlyDrawIfAttached=True
    bOwnerNoSee=False
    bHidden=False
    bHardAttach=True

    bCollideActors=False
    bBlockActors=False
    bBlockPlayers=False
    bBlockProjectiles=False

    Physics=PHYS_None

    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=False
	
	//bAlwaysTick=True
}