class Weapon_M46A1Rifle_TeamLight extends BallisticEmitter
    placeable;

simulated event BaseChange()
{
    if (Base == None)
        Destroy();
}

simulated function SetTeamColor(int Team)
{
    switch (Team)
    {
        case 0:
            Emitters[0].ColorMultiplierRange.Z.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.Z.Max = 0.000000;
            Emitters[0].ColorMultiplierRange.Y.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.Y.Max = 0.000000;
            break;

        case 1:
            Emitters[0].ColorMultiplierRange.X.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.X.Max = 0.000000;
            Emitters[0].ColorMultiplierRange.Y.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.Y.Max = 0.000000;
            break;

        case 2:
            Emitters[0].ColorMultiplierRange.X.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.X.Max = 0.000000;
            Emitters[0].ColorMultiplierRange.Z.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.Z.Max = 0.000000;
            break;

        case 3:
        case 255:
            Emitters[0].ColorMultiplierRange.Z.Min = 0.000000;
            Emitters[0].ColorMultiplierRange.Z.Max = 0.000000;
            break;
    }
}

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        FadeIn=True
        UniformSize=True
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        Opacity=0.400000
        FadeOutStartTime=1.300000
        FadeInEndTime=1.300000
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        StartLocationOffset=(X=9.000000)
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        InitialParticlesPerSecond=100.000000
        Texture=Texture'BWKF_Core_T.Particles.AquaFlareA1'
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=3.000000)
    End Object

    Emitters(0)=SpriteEmitter'BW_WD001_KF.Weapon_M46A1Rifle_TeamLight.SpriteEmitter0'

    CullDistance=3072.000000
    bHardAttach=True
}