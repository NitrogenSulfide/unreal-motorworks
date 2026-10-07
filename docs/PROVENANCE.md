# Unreal Motorworks provenance and credit record

This record identifies the original works behind Unreal Motorworks' maintained
backend forks. It records attribution evidence; it does not by itself grant
permission to redistribute a derivative work.

## VehicleStuff

- Original author credit: `[-will-]`
- Contemporary community references also call the author `Will`; no reliable
  surname was found, so the credited handle remains the release attribution.
- Contemporary reference:
  `https://forums.beyondunreal.com/threads/review-weapon-stuff.108866/`
- Team credit: Fraghouse Mod Team
- Original testing credit: Underscore
- Historical contact printed in the archive: `mods@spambox.co.uk`
- Preserved archive:
  `https://pwc.muffincdn.com/ut2004/mutators/VehicleStuff.7z`
- Archive SHA-256:
  `b7da189bda3b64d959b7c0841da30eeaf43a68d3912ddb42c2b42f1a17be1730`
- Original `System/VehicleStuff.u` SHA-256:
  `b48a31301774175102d0860f719bdf81b25e7b681d1222bb80fcff878ee534a0`

The archive's `Help/VehicleStuff.txt` says that VehicleStuff was made by
`[-will-]` for the Fraghouse Mod Team and gives special testing thanks to
Underscore. It does not state an explicit redistribution or derivative-work
license.

## WoRM2k4 Motorpool

- Original handle: Kangus
- Name in the original copyright notice: Justin Follis
- Original supporting credits: WMP forum testers, Obscenery, and EvilDrWong
- Historical contact printed in the archive: `kangus@planetunreal.com`
- Preservation page:
  `https://unrealarchive.org/unreal-tournament-2004/mutators/W/worm2k4-v2-5_7508a8b2.html`
- Preserved `WoRM2k4_v2_5.zip` SHA-1:
  `7508a8b2f5d52b51e50327a5cf4bd6f896f3203f`
- Preserved `WoRM2k4_v2_5.zip` SHA-256:
  `b635a304a3d54975e3a469bfcf1fcc2f44a93504d2c4b9f306e1ecdb8b98d31b`
- Original `WoRM2k4.u` SHA-1:
  `ee13f4de3950c4d7d4c40b5e06c9c717cc40b9fa`
- Original `WoRM2k4.u` SHA-256:
  `192841b2b315ccd9cef25acaa16e7db0b754001704b46d4c6e95665195f53b68`

The v2.51 readme credits Kangus as author and identifies its new code as
copyright 2004-2005 Justin Follis. It encourages learning from the code but
does not state an explicit redistribution or derivative-work license.

## Compatibility confirmation

On 2026-09-29, the current native OldUnreal 3374 Vehicle Suite build was run in
an isolated server fixture after replacing the local WoRM2k4 dependency with
the preserved original `WoRM2k4.u` hash above. Both backends loaded exactly
once, Motorpool replacement and VehicleStuff tuning ran, and the fixture ended
with `[VehicleSuiteFeatures] RESULT failures=0`.

The original `WoRM2k4.u` is therefore a tested prerequisite, not a file that
must be bundled in the Vehicle Suite archive.

## Publication status

Author identities and the public prerequisite source are confirmed. On
2026-10-04 the user explicitly directed proceeding with a public release while
preserving appropriate original-author credits, rather than waiting for author
contact. No written upstream permission or new licence was obtained by that
decision; the historical licence observations above remain unchanged. Public
uploads follow the fresh-install test and release presentation work.

## Public beta assets and boundaries

The Blue Natto credits avatar is the existing brand graphic selected by Blue Natto for the application. It is embedded in the compiled presentation package. Original avatar files and private conversion/build inputs are not shipped separately. Publication of the branded mod and the four feature screenshots was explicitly requested for this release.

The legacy artwork is loaded optionally from the optional installed legacy mod and is not copied into this distribution. The original WoRM2k4 package, custom vehicles, character/voice assets, personal presets, private backend source, engine exports, and machine configuration are excluded. The four feature screenshots show stock UT2004 vehicle examples and an independently named tuning variant.

The historical licence observations above remain unchanged. Attribution and the publication decision do not grant a new upstream licence. This beta is a free fan-made modification for UT2004; it does not include the game or assert ownership of original authors' work.
