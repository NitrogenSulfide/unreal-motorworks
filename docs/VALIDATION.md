# v0.3.0-beta.3 validation

This release simplifies Motorpool's save/load/close workflow. Save Set saves and activates the named set; Load Set activates a saved or built-in mapping. Close offers Save, Don't Save, and Cancel. Popup Save assigns the first unused UnnamedNN name when needed. The redundant Motorpool Save and Save & Close controls are removed. Tuning-editor save controls are unchanged.

| Evidence for the beta.3 package | Result and scope |
| --- | --- |
| Native Linux build | Zero errors and warnings |
| Motorpool workflow and persistence | 32 checks at each of 1920×1080 and 3840×2160, including all three close actions, Unnamed01/02/03 generation, built-in fallback, exact variant order, strategies, reopen and fresh-process restart |
| Final visuals | Three-choice prompt and affected controls captured and inspected on isolated displays at 1080p and 4K |
| Independent code review | Exact frozen private source and compiled package checked; no demonstrated blockers |
| Install/rollback | Fresh and collision archive transfer verified; exact previous bytes restored and configuration sentinel preserved |
| Live installation | Reviewed package and registration hashes verified; 149 configuration files unchanged, collision backups retained |
| Hands-on confirmation | This beta.3 change has not yet received a separate user gameplay confirmation |

GUI delegate/controller paths were exercised. New physical pointer/keyboard interaction, gameplay and multiplayer tests were not repeated on beta.3. Replacement changes apply on the next map. Private screenshots, backend sources, personal sets and machine configuration are excluded from the public release.

## Earlier beta.2 evidence

Beta.2's custom-gun preview fix passed 100 editor/persistence checks at 1440p, 49 preview checks across 16 vehicle variants, and 60 standalone gameplay checks. Its preview was confirmed by hands-on testing. Those results identify beta.2, not the rebuilt beta.3 package; the preview logic is unchanged by this Motorpool workflow update.

## Earlier beta.1 evidence

Beta.1 passed 100 editor checks each at 1080p, 1440p and 4K, 20 native settings-import checks plus 20 after restart, and seven custom vehicle factory/weapon-attachment checks. It also passed a native dedicated-server plus loopback-client test with separate configurations: 13 client and five server checks for joining, variant respawn, health, replacement weapons and mount transforms. Those network checks were rerun on beta.1 before the beta.2 preview fix; they were not repeated on the beta.2 package. Gameplay code is unchanged. Earlier 4K feature captures remain in the README.

Driving and firing were tested by me during beta development. Multiplayer coverage is limited: internet latency/packet loss, multiple clients, listen servers, downloads/redirects, reconnects and every third-party vehicle remain unverified. Separate cosmetic attachments have standalone gameplay evidence, not a dedicated-server cosmetic verification.

Portable CI checks source boundaries, syntax, metadata, migration/install fixtures and credentials; it does not build or run the game. The unchanged upgrade helper was previously checked for legacy/shared settings preservation, stale plans, interrupted writes and rollback. Private backend source/build inputs and personal settings remain unpublished.

Native visual tests use software rendering on separate displays and do not establish graphics-driver parity or performance. Steam/Proton installations have not been tested; support is not guaranteed. Native Windows remains unvalidated. Automated checks, independent review, installation, hands-on testing and publication are separate gates.
