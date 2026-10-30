class Weapon_M46A2Rifle_ProximityTrigger extends Triggers;

simulated singular function Touch(Actor Other)
{
    local Weapon_M46A2Rifle_ProximityMine Mine;
    local Pawn P;

    if (Other == None)
        return;

    P = Pawn(Other);

    // Player-controlled pawns must never trigger the mine.
    if (P != None && P.Controller != None
        && PlayerController(P.Controller) != None)
        return;

    Mine = Weapon_M46A2Rifle_ProximityMine(Owner);

    if (Mine != None && (Other.bProjTarget || Other.bBlockActors))
        Mine.SteppedOn(Other);
}

defaultproperties
{
    bOnlyAffectPawns=True
    bHardAttach=True
    CollisionRadius=192.000000
    CollisionHeight=192.000000
}