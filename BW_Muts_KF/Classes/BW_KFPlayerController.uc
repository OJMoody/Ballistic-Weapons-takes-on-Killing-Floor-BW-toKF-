class BW_KFPlayerController extends KFPlayerController;

function ShowBuyMenu(string wlTag,float maxweight)
{
    StopForceFeedback();

    Log("BW TRACE BW_KFPlayerController.ShowBuyMenu()");

    ClientOpenMenu("BW_Muts_KF.BW_GUIBuyMenu",,wlTag,string(maxweight));
}

defaultproperties
{
}