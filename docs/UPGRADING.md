# Upgrade to v0.3.0-beta.2

Fresh installations need only `System/UnrealMotorworks.u` and `System/UnrealMotorworks.ucl` from the ZIP. No original VehicleStuff or WoRM2k4 download is needed. Existing custom vehicle packs remain optional separate content.

The earlier v0.3.0-beta.1 release changed the runtime package identity and settings filename. Beta.2 keeps that unified package and settings layout. Close the native OldUnreal game before changing files. Server and client must both use the same Motorworks version; do not mix an earlier beta with this one. Steam/Proton installations are untested and support is not guaranteed. Native Windows has not been validated for this release.

## Already using the unified package

Back up `UnrealMotorworks.u`, `UnrealMotorworks.ucl`, and `UnrealMotorworks.ini`, then replace only the two package files. Keep your INI. You do not need the migration helper.

## Upgrading the earlier three-package betas

Back up the game's System files and writable configuration first. The old configuration directory can be different from the game System directory. On native Linux, the documented defaults are `~/.ut2004/System` for writable configuration and `~/.local/share/OldUnreal/UT2004/System` for game files; use your actual paths if customized. On native Windows, supply the actual OldUnreal directories explicitly.

The ZIP includes `upgrade-settings.py`, a standalone Python 3 helper. It does not launch the engine, download anything, or require either original mod. Preview its targets before applying:

```sh
python3 upgrade-settings.py --config-dir ~/.ut2004/System --game-system-dir ~/.local/share/OldUnreal/UT2004/System
```

With the game closed, apply the previewed migration:

```sh
python3 upgrade-settings.py --config-dir ~/.ut2004/System --game-system-dir ~/.local/share/OldUnreal/UT2004/System --apply --game-closed
```

The helper:

- Copies only Motorworks' four sections into `UnrealMotorworks.ini`, preserving profile IDs, variants, group membership, named presets, and tuning values. Existing unified sections take precedence.
- Updates old Motorworks class references in held mutator/menu configuration without changing unrelated settings.
- Backs up and removes only `VehicleSuite.u/.ucl`, `VehicleStuffFix.u/.ucl`, and `WoRM2k4Fix.u/.ucl` from the specified game System directory.
- Leaves all three old INIs intact, including unrelated sections of shared `KangMods.ini`, and preserves original `VehicleStuff.u` and `WoRM2k4.u`.
- Records exact backups under the configuration directory's `MotorworksUpgradeBackups/`, with a manifest mapping each backup to its original path. A failed migration restores the previous bytes.

After migration, extract the new `UnrealMotorworks.u` and `.ucl` into the game System directory. Start UT2004, select **Unreal Motorworks: Motorpool + Tuning**, and check your variants and replacement groups. The helper does not install the new files itself.

If you omit `--game-system-dir`, the helper migrates configuration only: manually back up/remove the six old Motorworks package files and update any old references in the game System INIs. For native Windows with Python installed, use `py upgrade-settings.py` and quote both actual directory paths. Its Windows behavior remains untested.

For rollback, close the game, remove the new unified package files, and restore the old package/configuration bytes from your backups. The helper's manifest identifies each original destination. Preserve any newer settings before reverting; do not overwrite later edits blindly. If migration created a new unified INI, set it aside when reverting to the older beta.

## Manual settings migration

If you prefer not to run Python, copy the following sections into a new `UnrealMotorworks.ini`, changing only their section headers:

| Old file and section | New section |
| --- | --- |
| `VehicleStuffFix.ini` — `[VehicleStuffFix.VehicleStuffFix]` | `[UnrealMotorworks.VehicleStuffFix]` |
| `KangMods.ini` — `[WoRM2k4Fix.MutWoRM_vFix]` | `[UnrealMotorworks.MutWoRM_vFix]` |
| `KangMods.ini` — `[WoRM2k4Fix.WoRM_vCfgFix]` | `[UnrealMotorworks.WoRM_vCfgFix]` |
| `VehicleSuite.ini` — `[VehicleSuite.MutVehicleSuite]` | `[UnrealMotorworks.MutVehicleSuite]` |

Do not copy unrelated sections or replace newer unified sections. Keep arrays, profile IDs, names, and stock/custom vehicle class paths intact. Replace old Motorworks class references such as `VehicleSuite.MutVehicleSuite` with `UnrealMotorworks.MutVehicleSuite` in your selected mutators/menu settings, and reselect the new mutator if needed. Back up/remove the six old Motorworks package files, then extract the new two-file build.
