class BW_KFPlayerController extends KFPlayerController;

function ShowBuyMenu(string wlTag,float maxweight)
{
    StopForceFeedback();

    ClientOpenMenu("BW_Muts_KF.BW_GUIBuyMenu",,wlTag,string(maxweight));
}

defaultproperties
{
}