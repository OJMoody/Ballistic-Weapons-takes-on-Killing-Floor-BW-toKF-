class BallisticWeaponHitEffects extends ROHitEffect;

#exec OBJ LOAD FILE=..\Sounds\ProjectileSounds.uax

//=============================================================================
// defaultproperties
//=============================================================================
defaultproperties
{
	HitEffects(0)=(HitDecal=class'IE_BWBulletHoleDirt',HitEffect=class'ROBulletHitRockEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletDirt')        			// Default (Dirt?)
	HitEffects(1)=(HitDecal=class'IE_BWBulletHoleConcrete',HitEffect=class'ROBulletHitRockEffect',HitSound=Sound'ProjectileSounds.Bullets.Impact_Asphalt')     				// Rock
	HitEffects(2)=(HitDecal=class'IE_BWBulletHoleDirt',HitEffect=class'ROBulletHitRockEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletDirt')           			// Dirt
	HitEffects(3)=(HitDecal=class'IE_BWBulletHoleMetal',HitEffect=class'ROBulletHitMetalEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletMetal')      			// Metal
	HitEffects(4)=(HitDecal=class'IE_BWBulletHoleWood',HitEffect=class'ROBulletHitWoodEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletWood')    				// Wood
	HitEffects(5)=(HitDecal=class'IE_BWBulletHoleDirt',HitEffect=class'ROBulletHitGrassEffect',HitSound=sound'ProjectileSounds.Bullets.Impact_Grass')   						// Plant
	HitEffects(6)=(HitDecal=class'BulletHoleFlesh',HitEffect=class'ROBulletHitFleshEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletFlesh')    				// Flesh (dead animals)
	HitEffects(7)=(HitDecal=class'IE_BWBulletHoleIce',HitEffect=class'ROBulletHitIceEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletGlassBig')        			// Ice
	HitEffects(8)=(HitDecal=class'BulletHoleSnow',HitEffect=class'ROBulletHitSnowEffect',HitSound=sound'ProjectileSounds.Bullets.Impact_Snow')        					// Snow
	HitEffects(9)=(HitEffect=class'ROBulletHitWaterEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletWater')                                    				// Water
	HitEffects(10)=(HitDecal=class'IE_BWBulletHoleIce',HitEffect=class'ROBreakingGlass',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletGlassBig')          			// Glass
	HitEffects(11)=(HitDecal=class'IE_BWBulletHoleConcrete',HitEffect=class'ROBulletHitGravelEffect',HitSound=sound'ProjectileSounds.Bullets.Impact_Gravel')     			// Gravel
	HitEffects(12)=(HitDecal=class'IE_BWBulletHoleConcrete',HitEffect=class'ROBulletHitConcreteEffect',HitSound=sound'BWKF_Core_SN.BulletImpacts.BulletConcrete')   		 	// Concrete
	HitEffects(13)=(HitDecal=class'IE_BWBulletHoleWood',HitEffect=class'ROBulletHitWoodEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletWood')       			// HollowWood
	HitEffects(14)=(HitDecal=class'BulletHoleSnow',HitEffect=class'ROBulletHitMudEffect',HitSound=sound'ProjectileSounds.Bullets.Impact_Mud')        					// Mud
	HitEffects(15)=(HitDecal=class'BulletHoleMetalArmor',HitEffect=class'ROBulletHitMetalArmorEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.ArmorMisc')    	// MetalArmor
	HitEffects(16)=(HitDecal=class'IE_BWBulletHoleConcrete',HitEffect=class'ROBulletHitPaperEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletWood')       		// Paper
	HitEffects(17)=(HitDecal=class'BulletHoleCloth',HitEffect=class'ROBulletHitClothEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletDirt')       			// Cloth
	HitEffects(18)=(HitDecal=class'IE_BWBulletHoleMetal',HitEffect=class'ROBulletHitRubberEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletDirt')       			// Rubber
	HitEffects(19)=(HitDecal=class'IE_BWBulletHoleDirt',HitEffect=class'ROBulletHitRockEffect',HitSound=SoundGroup'BWKF_Core_SN.BulletImpacts.BulletDirt')       			// Mud
}
