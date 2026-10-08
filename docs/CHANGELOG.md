# v0.3.0-beta.2

- Fix optional DkoppII turret/body decorations in Motorpool and tuning previews, including Abrams MK2 and special secondary-gun attachment bones. Apply the same preview attachment lookup in both editors.
- Preserve gameplay code, vehicle tuning, saved variants, groups and settings. Optional custom vehicle packages remain separate content; none is required or included.
- Validate this package with 100 editor/save/reload checks at 1440p, 49 preview checks across 16 tank variants, and 60 standalone gameplay checks. The installed preview fix was also tested by me.

Upgrade from beta.1 by backing up and replacing only `UnrealMotorworks.u` and `.ucl`; keep `UnrealMotorworks.ini`. Update server and client together. This is still a public beta; see [validation scope](VALIDATION.md).

# v0.3.0-beta.1

The first beta in the consolidated package line. This version changes runtime package identity, so earlier betas require configuration migration and server/client upgrades together.

- One `UnrealMotorworks.u` and one `.ucl`, with settings in `UnrealMotorworks.ini`.
- Complete mod in one ZIP; no separate original VehicleStuff or WoRM2k4 dependency.
- Optional preview-first upgrade helper preserves profiles, variants, groups, named presets and exact backups while retiring only the six earlier Motorworks package files.
- Updated fresh-install, upgrade, uninstall and server configuration instructions.
- Additional editor/persistence checks at 1080p and 4K, native migration/restart checks, repeated dedicated-server/client checks, and hands-on regression confirmation.

This remains a public beta. Native Windows, internet multiplayer and exhaustive custom-vehicle compatibility are unverified; Steam/Proton support is not guaranteed.

# v0.2.5-beta.5

Standalone public beta after the beta.4 distribution hold. This version keeps the existing internal package/configuration names and does not overwrite presets.

- Independent named vehicle variants, per-vehicle numbering, group preview synchronization, and automatic removal of deleted variants from groups.
- Save without closing; restored defaults no longer leave stale modification markers. Modified first and In-group first start enabled.
- Each mount offers Default: original weapon, None and alternate guns. None removes the gun. Edit starts a newly selected gun from its own projectile defaults; Restore Defaults, Done and Cancel have explicit draft behavior.
- Custom projectile firing retains the selected gun appearance. DkoppII custom Defender variants recreate the separate turret shell in gameplay.
- Advanced health accepts multiple digits and synchronizes with Health. Caps: speed/friction/mass 5, wheel/jump 3, hover 2, health 1,000,000.
- Corrected window/panning behavior, footer spacing and mount-only Restore Default Values. Stationary turrets are excluded from the browser for now.
- Four refreshed 4K stock-feature screenshots, original-mutator credit links and explicit testing limits.

This is a beta, not a stable release. Internet multiplayer, native Windows and exhaustive custom-vehicle compatibility remain unvalidated; Steam/Proton support is not guaranteed.
