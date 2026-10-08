# v0.2.5-beta.5 validation

This beta ships the exact compiled packages installed and tested locally after the weapon editor, reset-marker and DkoppII turret fixes. The release manifest identifies the downloadable ZIP and every member. Neither original VehicleStuff nor WoRM2k4 is bundled or required.

| Evidence | Result and scope |
| --- | --- |
| Native Linux build | Zero errors and warnings |
| Current weapon editor / persistence | 100 checks; real pointer and keyboard interactions, Save/Cancel, defaults, gun changes, projectiles and fresh-process reload |
| Current custom Defender gameplay | 7 checks; actual Motorpool factory variant on Torlan, turret shell rendering, custom intervals and actor cleanup |
| Current standalone server/client | One native dedicated server and one local client, separate configurations, both original mods absent; 13 client and 5 server checks passed for joining, respawn, health, weapons and mount transforms |
| Current screenshots | Four stock-feature captures at 3840×2160 on a separate virtual display; inspected before publication |
| Installation and rollback | Fresh and collision round trips; installed/member/backup hashes checked; existing presets preserved |
| Live installation | Current game packages match tested bytes; saved configuration retained |
| Hands-on testing | Driving and firing tested by me during beta development; latest turret correction still awaits a separate user confirmation |

Earlier development checks covered layouts at 1080p, 1440p and 4K, remote Save acknowledgments, variant/group deletion, view interactions and tuning limits. Those records apply to their identified earlier candidates; they are not a claim that every scenario was rerun on this ZIP. Current editor checks use private 1440p software rendering.

Multiplayer support has limited testing: loopback networking, one dedicated server and one client. Internet latency/packet loss, multiple clients, listen servers, downloads/redirects, reconnects and every third-party vehicle remain unverified. The latest DkoppII cosmetic shell fix has standalone gameplay evidence, not a dedicated-server cosmetic verification.

Test fixtures may inherit unrelated inventory/HUD warnings from copied game configuration. The suite-specific regressions had no errors; this is not a guarantee that every installation has warning-free logs. Private evidence, backend source and build-input manifests remain private.

Steam/Proton installations have not been tested; support is not guaranteed. These exact packages remain unvalidated on native Windows. Portable CI validates source boundaries, syntax, metadata and temporary fixtures, not UnrealScript compilation or gameplay.
