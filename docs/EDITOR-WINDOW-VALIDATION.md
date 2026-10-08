# Editor window, appearance and deletion regression

Unpublished beta follow-up. Repository visibility and release publication remain on hold.

The regression starts at the Unreal Motorworks landing page, opens Motorpool,
and opens tuning for a selected vehicle. Real right-button input pans the Vehicle
and Placement previews while checking that tuning remains the top page and the
entire menu stack stays unchanged. Hidden or underlying previews must not handle
that input.

The same native fixture exercises the ordinary replacement weapon appearance
checkbox through its change handler, preserves the selected weapon class, checks
warning visibility across tab switches, and removes a saved deleted variant from
active and held replacement groups while preserving other members and order.
A separate engine process verifies that the deletion journal survives restart,
repairs an unconsumed stale reference, and preserves a newly recreated profile
that reuses the same ID. Unsaved deletion does not emit a cleanup event.

An isolated loopback dedicated server and client check ordinary driver and
passenger replacement weapon appearance on and off. The client checks the
selected class, projectile, firing interval, stock or replacement mesh and muzzle,
and mount transform. Existing custom projectile and acknowledged/rejected remote
save checks remain included. This is limited multiplayer testing; Internet play,
third-party weapon-specific animations, full passenger driving/firing and every
vehicle combination are not covered by this fixture.

Native engine tests use private displays and copied configuration. Source-only
GitHub CI does not run the game or certify these behaviors. Final candidate and
package hashes, screenshots and independent review are kept in private evidence.

## Conservative tuning guidelines

These are suggested starting ceilings for experimentation, not universal engine
limits or enforced new clamps. Vehicle classes implement different physics.
Increase values gradually and test driving, collisions and respawning.

| Setting | Suggested ceiling | Meaning in this implementation |
| --- | --- | --- |
| Speed | 3 | Scales propulsion/gear properties; not an exact top-speed multiplier. |
| Friction | 3 | Absolute wheel friction scale where supported; not a multiplier of each class's default friction. |
| Mass scale | 3 | Currently changes momentum response inversely; does not change Karma rigid-body mass. |
| Wheel size | 1.5–2 | Wheel radius scale where supported. |
| Jump height | 3 | Scales jump force where supported. |
| Hover height | 2 | Scales hover distance where supported. |
| Health | 5 times stock | A practical balance ceiling, not the editor's storage limit. |

The placement editor already clamps offsets to ±500 Unreal units, angles to ±180
degrees and scale to 0.1–5. Keeping offsets much closer to the original mount is
usually easier to aim and review. For custom fire intervals, 0.1 seconds is a
reasonable first lower bound; lower means faster. Zero uses the existing fallback,
not an infinitely fast weapon.
