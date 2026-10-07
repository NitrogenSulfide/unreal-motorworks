# Unreal Motorworks v0.2.5-beta.4 — Standalone Public Beta

By **Blue Natto (also known as CissiaLikesEggs on Gamebanana)**, for native OldUnreal Unreal Tournament 2004 **3374 or later**.

Choose vehicle replacement groups and tune vehicles through one mutator. Duplicate vehicles into independently named variants, change health and weapons, adjust weapon-mount position/rotation/scale, and optionally randomize spawn health. Unreal Motorworks includes its maintained tuning and replacement backends in one ZIP. Neither original VehicleStuff nor WoRM2k4 needs to be downloaded or installed.

Download the self-contained [v0.2.5-beta.4](https://github.com/NitrogenSulfide/unreal-motorworks/releases/tag/v0.2.5-beta.4).

## Install

1. Close UT2004. Use a native OldUnreal 3374+ installation; Steam/Proton installations have not been tested; support is not guaranteed.
2. Back up any existing `VehicleSuite.u`, `VehicleStuffFix.u`, `WoRM2k4Fix.u` and their `.ucl` files. Extract this ZIP into the UT2004 game root so the six files under `System/` land in your game's `System/` directory.
4. Add **Unreal Motorworks: Motorpool + Tuning** to your mutators, then open its configuration. Enable only the suite; do not also enable either Fix backend or the original VehicleStuff/Motorpool mutator.

This ZIP contains three compiled packages, their cache registrations, and this README. It includes no custom vehicles, voice packs, personal presets, or game binaries. Only the suite is registered in the mutator browser; the two backend `.ucl` files are intentionally empty.

## Use

- **Motorpool Remastered**: choose replacements for each stock vehicle slot. Groups can contain several vehicle classes or differently tuned variants of the same class. Double-click a browser vehicle to add/remove it from the selected stock group; double-click a numbered group member to remove it. Single clicks preview/select, and Space still toggles browser membership.
- **Reset view**: restore the Motorpool preview's fitted zoom, centered position and default angle. Auto-rotate keeps your chosen setting.
- **Synchronized in-order**: drag members in the bottom-left group list to change the spawn sequence, then Save. Independent random groups keep normal selection behavior.
- **View / tune highlighted vehicle**: open the tuner at the selected entry.
- **Duplicate as variant**: create a persistent independent profile. Name it, change settings, and save. Delete is available only for duplicates.
- **Modification markers**: a green asterisk marks saved vehicle changes; a red asterisk marks changes made since opening the editor. Reverting to the opening values clears the red marker. Restore Defaults clears the marker immediately; use Save to commit the reset, or Cancel to discard it. The key sits below the Name field.
- **Placement**: preview driver/passenger weapon-mount position (Unreal units), rotation (degrees), and uniform scale. Integrated stationary-turret weapons retain their native mounts.
- **In-group first**: bring current group members to the top without changing Search or Sort.
- **Spawn health**: set minimum/maximum multipliers against configured health. A vehicle gets one roll when it spawns; live updates do not reroll it. Respawning stationary turrets get fresh tuning.
- **Stationary turrets**: tune health/weapons in Vehicle Tuning & Weapons. They are placed map actors, not Motorpool factory slots.

Save commits changes; Cancel discards the current editor's unsaved changes. Motorpool has its own Save button. During a standalone match, `mutate VehicleSuite Config` opens the hub. Tuning saves apply immediately in standalone; Motorpool changes take effect on the next map.

The rename keeps the internal `VehicleSuite`, `VehicleStuffFix`, and `WoRM2k4Fix` package/configuration names so existing presets and mutator references continue to work.

## Presets, updates, and removal

Existing `KangMods.ini` and `VehicleStuffFix.ini` remain authoritative and are never bundled or overwritten. Back them up before experimenting. Existing Motorworks replacement groups and named group presets remain available. Original-only WoRM2k4 presets are not automatically imported; their INI sections are preserved.

To uninstall, close UT2004 and remove only the six suite files listed above, or restore the versions/cache registrations backed up before installation. Keep `WoRM2k4.u` and shared `KangMods.ini` if other WoRM2k4 mutators use them. Keep tuning INIs to retain presets. For a fresh start, back up/remove `VehicleStuffFix.ini` and `VehicleSuite.ini`, and back up/reset only the Motorpool sections in shared `KangMods.ini`; its unrelated weapon settings should be preserved.

## Servers and beta scope

Both extra-client-package lists default to empty. A fresh install does not request the author's custom vehicles or voice packs. Server admins using custom vehicles can list their actual package names under `[VehicleSuite.MutVehicleSuite]` in `VehicleSuite.ini` using `VehicleServerPackages[0]=YourPackage`, and further indices up to 31. `VoiceServerPackages[0]=YourVoicePackage` is an optional explicit override. Only configure content the server actually installs and needs. Standalone play skips this registration.

This is a public beta. The current packages were built and checked on native Linux OldUnreal 3374. The interface was checked at 1920×1080, 2560×1440, and 3840×2160. The latest package has not been validated on native Windows.

**Limited multiplayer testing:** one native OldUnreal dedicated server and one local client, with separate configurations. Joining, variant respawns, health, replacement weapons, and mount placement passed. I also tested driving and firing. Internet play, multiple clients, listen servers, and package downloads remain unverified. Compatibility with every custom vehicle is not guaranteed.

**Standalone beta update:** the original mod downloads are no longer prerequisites. A fresh configuration now resolves directly to stock vehicle mappings. Custom vehicles remain optional separate downloads; this ZIP includes the editor and runtime, not a custom vehicle collection.

Report your OldUnreal patch version, map, mutators, reproduction steps, and relevant UT2004 log messages in [Issues](https://github.com/NitrogenSulfide/unreal-motorworks/issues).

## Credits

- Unreal Motorworks coordination, maintained backend fixes, and new editor work: **Blue Natto (also known as CissiaLikesEggs on Gamebanana)**.
- Original VehicleStuff: **[-will-]**, **Fraghouse Mod Team**; original testing: **Underscore**.
- Original WoRM2k4 and Motorpool: **Kangus (Justin Follis)**; original thanks to WMP forum testers, Obscenery, and EvilDrWong.

The Blue Natto avatar appears beside the centered author credit. The in-game Credits panel preserves the original-author attribution. If the legacy mod is already installed, its artwork may appear in Credits; this is optional and is not needed to use Motorworks.

## Feature screenshots

Original in-game 4K captures using stock vehicles and an example tuning variant.

![Replacement groups and named variants](docs/screenshots/01-replacement-groups-3840x2160.png)
![Vehicle tuning and preview](docs/screenshots/02-vehicle-tuning-3840x2160.png)
![Weapon configuration](docs/screenshots/03-weapons-3840x2160.png)
![Weapon mount placement](docs/screenshots/04-mount-placement-3840x2160.png)

## Repository and validation

This separate repository contains the original coordination-layer source under `src/VehicleSuite`, public documentation, approved feature screenshots, and portable validation tools. The maintained backend forks are distributed as compiled packages in Releases; their source and private build inputs are not included in this repository. This is not a complete reproducible source distribution. No blanket open-source licence is asserted for the upstream-derived backends; see [provenance and credits](docs/PROVENANCE.md).

[Validation](docs/VALIDATION.md) separates native tests, user testing, and portable CI. [Review process](docs/REVIEW_PROCESS.md) describes the release gates. GitHub Actions checks source boundaries, syntax, release metadata, temporary fixtures, and credentials; it does not build or launch UT2004 and does not publish releases automatically.
