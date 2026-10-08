# v0.3.0-beta.1 validation

This release consolidates the maintained classes into `UnrealMotorworks.u` plus one `.ucl`. Its runtime package bytes are the same single-package candidate installed locally and confirmed by hands-on regression testing. The release manifest identifies the ZIP and every member. No original mutator download is required.

| Evidence | Result and scope |
| --- | --- |
| Native Linux build | Zero errors and warnings; compiled class export checked |
| Current editor / persistence | 100 checks each at 1080p, 1440p and 4K; actual pointer/keyboard interactions, Save/Cancel, defaults, gun changes, projectiles and fresh-process reload |
| Native settings migration | 20 checks on import and 20 after restart; all config fields compared against copied legacy settings, old INI bytes preserved |
| Custom Defender gameplay | 7 checks; actual Motorpool factory variant on Torlan, turret shell rendering, custom intervals and actor cleanup |
| Dedicated server/client | One native dedicated server and one loopback client, separate configurations; 13 client and 5 server checks for joining, respawn, health, weapons and mount transforms; old Motorworks/original packages excluded |
| Current screenshots | Four stock-feature captures at 3840×2160 on a private display; inspected before publication |
| Installation and rollback | Native local upgrade verified two installed files, six retired files, migrated configuration and exact backups; portable tests cover stale plans, interrupted writes, and rollback |
| Hands-on testing | Regression testing, driving and firing tested by me during beta development |

Portable CI tests the downloadable upgrade helper using temporary fixture directories, including preservation of legacy/shared settings, duplicate migration, untouched original mods, target changes, and write-failure recovery. It does not run the game. Private backend sources/build inputs and personal settings are not published.

Multiplayer testing remains limited to loopback networking with one server and one client. Internet latency/packet loss, multiple clients, listen servers, downloads/redirects, reconnects and every third-party vehicle remain unverified. The DkoppII cosmetic shell has standalone gameplay evidence, not a dedicated-server cosmetic verification.

Earlier development checks covered remote Save acknowledgments, variant/group deletion, view interactions and tuning limits. Those records apply to their identified candidates; they do not establish exhaustive coverage for this ZIP. Native tests use software rendering on separate displays and do not establish graphics-driver parity or performance.

Steam/Proton installations have not been tested; support is not guaranteed. These exact packages remain unvalidated on native Windows. Source checks, isolated engine checks, live installation, hands-on testing, independent review, and publication are separate gates.
