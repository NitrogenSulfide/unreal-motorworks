# v0.2.5-beta.3 validation

The release reuses the exact compiled package bytes of the validated candidate. Updating the public README and archive name does not rebuild those packages. `release/manifest.json` records the exact downloadable archive and member hashes.

| Evidence | Result and scope |
| --- | --- |
| Native Linux build | Zero errors and warnings |
| Gameplay fixtures | 25 checks passed |
| Editor fixtures | 46 checks passed |
| Actual mouse interactions | 25 checks passed, including Reset and double-click membership |
| Layout | 45 checks at each of 1080p, 1440p and 4K; screenshots inspected |
| Installation/rollback fixture | Collision round trip passed; backup and installed hashes verified |
| Local dedicated server/client | 13 client and 5 server checks passed: joining, variant respawn, health/max, weapons and mount transforms |
| Hands-on testing | I tested driving and firing |

Server and client testing used native OldUnreal 3374, loopback networking, separate copied configurations and a private display. Latest-candidate testing with the original WoRM2k4 prerequisite is recorded in the release review. Full logs and private source manifests remain private; public summaries do not substitute for those records.

Unverified scenarios include internet latency/packet loss, multiple clients, reconnects/late joins, listen servers, package downloading/redirects and the latest packages on native Windows. Some test fixtures inherited unrelated inventory/HUD warnings; this is not a warning-free clean-install claim. The clean Motorpool configuration startup warning is documented in the README.

Portable CI validates source and release metadata only. Native gameplay, visual checks, independent review, live installation and publication are separate gates.
