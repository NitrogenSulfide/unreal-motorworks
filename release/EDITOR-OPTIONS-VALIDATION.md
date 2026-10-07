# Unpublished editor options

Distribution remains on hold: the repository is private, beta.4 remains a draft,
and the working pull request remains a draft. No new public version is approved.

Custom projectile settings now describe fire intervals in seconds and explain
that lower is faster; zero uses the existing 0.25-second default. Weapon occupant
controls say **Hide player**. The optional **Use original gun appearance** keeps
the stock vehicle weapon mesh, aiming bones and muzzle metadata while firing the
configured custom projectiles. It defaults off for existing profiles. Specialized
animations and auxiliary parts implemented by other weapon classes are not
recreated; arbitrary third-party vehicles need further gameplay testing.

**Advanced** beside Health opens the former spawn-health controls in a popup.
The popup includes base health synchronized with the main field, plus optional
random spawn multipliers. Done returns to the vehicle page; the outer editor's
Save & Close and Cancel retain their existing commit/rollback behavior.

The native regression fixture extends the custom-projectile saving test with
actual Advanced, Done and appearance-checkbox clicks, both-direction health
synchronization, save/reopen and fresh-process persistence, and primary,
alternate and passenger firing through a Torlan factory variant. It also checks
original meshes, muzzle metadata and passenger aiming limits. Final evidence,
package identities and independent review remain in the private candidate record.
Portable GitHub CI does not compile or run these engine fixtures.

Local candidate archive SHA-256:
`619fd63651a4228b8d19940b3a3904d94be24b3cbdf3a3a840158c69a471ee8a`.

Native Linux checks cover 1080p, 1440p and 4K on authenticated software-rendered
private displays. A separate dedicated-server/client loopback check is scoped
to configuration replication, appearance, attachment and spawn health. These
checks do not establish Windows support, internet-server behavior, graphics-driver
parity, or exhaustive multiplayer driving/firing coverage. Steam/Proton remains
untested and support is not guaranteed. User gameplay confirmation is separate.
