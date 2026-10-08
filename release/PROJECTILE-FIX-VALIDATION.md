> Historical development record, superseded by v0.2.5-beta.5. Descriptions and hashes below refer to their original candidates. Current behavior is documented in README and docs/VALIDATION.md.

# Unpublished custom-projectile saving fix

Public distribution is on hold: the repository is private and beta.4 is a draft.
The beta.4 release description and immutable release assets remain preserved.
No new version or public release has been approved.

The Custom dialog updated projectile fields and its displayed weapon caption,
but the saved weapon class could remain the original cannon. The fix explicitly
selects the Custom weapon when opening or editing the dialog, allows the Custom
dropdown sentinel, initializes saved values before accepting input, commits the
final fields on Done, and preserves saved projectile choices omitted by the
current weapon cache. An unset alternate projectile is handled without attempting
to load an empty class name. No existing configuration is migrated or rewritten
during package installation.

The native fixture in `tests/native/MutCustomProjectileTest.uc` is compiled by the
maintainer's private native build, separately from portable CI. An authenticated
private 2560×1440 Xvfb display exercises actual mouse clicks on Custom, Done, and
Save & Close. It checks reopening, Cancel, saved/unsaved markers, both firing
intervals, passenger slots, and saved choices absent from the weapon cache. A
fresh game process reads the saved INI, spawns the exact stock Goliath variant
through a Torlan factory, and invokes the weapon's firing path to verify the
selected driver primary, alternate, and passenger projectile actors. This is
limited automated native Linux testing; it does not establish Windows, multiplayer
custom-projectile behavior, graphics-driver parity, or Steam/Proton support.

Local candidate archive SHA-256:
`52ebf5dacef8ad3a1cf31fe9681632c86673f99fd14b5b8cb34f4a838b923ce1`.
Private build-input manifests, native results, screenshots, install/rollback
records, and the independent review are kept with the local candidate. Those
records identify compiled bytes beyond the source repository commit.
