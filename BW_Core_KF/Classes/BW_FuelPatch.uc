class BW_FuelPatch extends BallisticEmitter;

var() float Fuel;          // Fuel remaining
var() float MaxFuel;       // Max allowed fuel
var() float DrainRate;     // Fuel drained per second
var() int Extent;          // Minimum distance from other fuel patches

var byte NetFuel;          // Replicated fuel level

var() bool bCanIgnite;     // Can this fuel patch be ignited?
var() bool bCanFeed;       // Can this fuel patch receive more fuel?
var bool bIgnited;

replication
{
    reliable if (Role == ROLE_Authority)
        NetFuel, bIgnited;
}

function Reset()
{
    Destroy();
}

simulated event PostNetReceive()
{
    Fuel = NetFuel;
    FuelChanged();
}

simulated function Ignite(Pawn EventInstigator)
{
    bIgnited = true;
}

// Set the current fuel level.
function SetFuel(float Amount)
{
    Fuel = Amount;
    NetFuel = Fuel;
    FuelChanged();
}

// Add fuel, keeping the total below the maximum.
function AddFuel(float Amount)
{
    SetFuel(FMin(Fuel + Amount, MaxFuel));
}

// Client and server notification of fuel changes.
// Subclasses implement their own response.
simulated function FuelChanged();

// Called when the fuel runs out.
simulated function FuelOut()
{
    SetTimer(0, false);
    Kill();
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.5, true);
}

simulated event Timer()
{
    Fuel -= TimerRate * DrainRate;

    FuelChanged();

    if (Fuel <= 0)
        FuelOut();
}

defaultproperties
{
    Fuel=10.000000
    MaxFuel=100.000000
    DrainRate=1.000000
    Extent=48
    bCanIgnite=True
    bCanFeed=True
    bNetNotify=True
}