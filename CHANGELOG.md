# Sleepo

## v1.1.3 (20/08/2025)

- Raid Setup Importer now saves the Stormlash and Banner Rotation in the addon database, instead of pushing it to WeakAuras, allowing to persist the rotation between sessions/reloads. An event WA_SLEEPO_NEW_SB_ROTATION is triggered when a new rotation has been saved, and rotation can be retrieved using Sleepo.DB:get("StormlashBannerRotation")
