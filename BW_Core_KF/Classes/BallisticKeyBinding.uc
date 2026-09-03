// ====================================================================
// BallisticKeyBinding.
//
// Adds some new keys.
// ====================================================================
class BallisticKeyBinding extends GUIUserKeyBinding;

defaultproperties
{
     KeyData(0)=(KeyLabel="Ballistic Weapons Keybinds",bIsSection=True)
	 KeyData(1)=(Alias="MeleeHold | OnRelease MeleeRelease",KeyLabel="Charged Melee Attack")
	 KeyData(2)=(Alias="SwitchWeaponMode",KeyLabel="Switch Fire Mode")
	 //KeyData(2)=(Alias="SwitchWeaponMode|OnRelease WeaponModeRelease",KeyLabel="Switch Fire Mode")
     //KeyData(3)=(Alias="CockGun",KeyLabel="Cock Weapon (optional)")
	 //KeyData(4)=(Alias="BWStats",KeyLabel="Ballistic Weapons Stats/Manual")
}
