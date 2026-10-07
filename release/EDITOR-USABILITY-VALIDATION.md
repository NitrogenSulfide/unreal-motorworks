# Unpublished editor usability candidate

The repository remains private, beta.4 remains a draft, and publication stays on
hold. This is an internal candidate, not a new published version.

- **Modified first** puts green, previously modified profiles above ordinary or
  red unsaved profiles while retaining the active name/package/added sort and
  search. Turning it on scrolls to the top without changing the selected profile.
- The green key says **Modified previously**. Name/package subtitles use native
  raster font sizes and integer pixel positions, with fitting and truncation.
- **Use original gun appearance** moves from the Custom popup to the matching
  Weapons row. It applies only to Custom weapons and never changes the weapon
  selection. Existing stored options are retained.
- **Save** keeps tuning and Motorpool open. During a match it commits to the live
  tuning backend; it establishes a saved baseline so later Cancel discards only
  edits since Save. Remote updates prevent overlapping transfers and retain red markers until an
  owner-scoped server acknowledgment. The saved baseline is the sent snapshot;
  later edits remain unsaved. Rejected/unconfirmed updates offer Retry Save.
- Advanced base health accepts multiple typed digits and stays synchronized with
  the main Health field. Refresh no longer repeatedly selects the current text.
- Motorpool shows the selected group/count in red between Spawn mode and the
  viewport. The group pane explains that ordering matters only in Synchronized
  in-order mode; preview instructions have their own row.

The native fixture exercises real XTest pointer/button input on private,
authenticated displays and real XTest keyboard input on a native-focused health
field. It covers multi-digit health input, per-weapon appearance
without changing the weapon, Save then edit/Cancel/reopen, Modified first sorting,
scrolling/search/selection, fresh-process custom projectile persistence and firing.
Separate editor checks cover Motorpool Save/Cancel and group layout. The native
loopback fixture additionally checks confirmed remote Save, concurrent-send
prevention, edits during transfer, rejected non-admin saves and Cancel rollback.
Its admin transfer test starts with a seeded local profile; it does not establish
server-to-client editor inventory synchronization or exhaustive admin workflows. Final test
results, final screenshots, input/source identities, independent review and live
installation are recorded separately in the private candidate record. Portable CI
checks source and metadata; it does not run these native engine fixtures.

Candidate archive SHA-256:
`2d62e93404ccd485bf328b4458465a8b95a6add35dd806a7a786f01c25ff262c`.

Software-rendered layout checks at 1080p, 1440p and 4K do not establish graphics
driver parity or performance. Loopback dedicated-server/client checks remain
limited to the recorded replication and configuration scenarios, not exhaustive
multiplayer driving/firing. Steam/Proton is untested and support is not guaranteed;
these exact packages remain unvalidated on Windows. User gameplay confirmation
and publication approval remain separate.
