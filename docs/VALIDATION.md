# v0.3.0-beta.2 validation

This release changes only editor preview attachments for optional DkoppII guns. Runtime gameplay classes, registration, settings layout, and the upgrade helper are unchanged from beta.1. The release manifest identifies the ZIP and every member; the compiled package is the same build installed locally and confirmed by hands-on preview testing. Neither original mutator is required.

| Evidence for the beta.2 package | Result and scope |
| --- | --- |
| Native Linux build | Zero errors and warnings |
| Editor / persistence | 100 checks at 2560×1440, including gun/default/projectile edits and a fresh-process reload |
| Tank preview sweep | 49 checks across 16 tank variants; inspected final captures for rendered hulls and optional turret/body attachments |
| Standalone gameplay | 60 checks across Goliath, Manta, Scorpion and Defender, covering entry, actual driving, firing and exit; custom projectile cases included |
| Independent review | Preview helper, both editor integrations, optional dependency behavior and exact compiled package hashes checked; no demonstrated blockers |
| Live installation | Two installed package hashes verified; collision backups verified; 149 INIs and four original-mutator files preserved |
| Hands-on preview verification | Tested by me after installation; reported preview now looks correct |

Plain Abrams rendered correctly in isolated tests, so its initially reported transparency could not be reproduced there. The tests do not establish compatibility with every custom vehicle or gun. Custom vehicle packs and private test captures are not included in the release.

## Earlier beta.1 evidence

Beta.1 passed 100 editor checks each at 1080p, 1440p and 4K, 20 native settings-import checks plus 20 after restart, and seven custom Defender factory/turret checks. It also passed a native dedicated-server plus loopback-client test with separate configurations: 13 client and five server checks for joining, variant respawn, health, replacement weapons and mount transforms. Those network checks were rerun on beta.1 before this preview fix; they were not repeated on the beta.2 package. Gameplay code is unchanged. Earlier 4K feature captures remain in the README.

Driving and firing were tested by me during beta development. Multiplayer coverage is limited: internet latency/packet loss, multiple clients, listen servers, downloads/redirects, reconnects and every third-party vehicle remain unverified. The DkoppII cosmetic shell has standalone gameplay evidence, not a dedicated-server cosmetic verification.

Portable CI checks source boundaries, syntax, metadata, migration/install fixtures and credentials; it does not build or run the game. The unchanged upgrade helper was previously checked for legacy/shared settings preservation, stale plans, interrupted writes and rollback. Private backend source/build inputs and personal settings remain unpublished.

Native visual tests use software rendering on separate displays and do not establish graphics-driver parity or performance. Steam/Proton installations have not been tested; support is not guaranteed. Native Windows remains unvalidated. Automated checks, independent review, installation, hands-on testing and publication are separate gates.
