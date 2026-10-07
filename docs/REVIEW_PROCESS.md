# Review and release process

Adapted from the maintained game-modding CI workflow for this separate public repository.

1. Prepare a short-lived `codex/` branch with staged source and full Git history. Run `python3 tools/ci/install_gitleaks.py`, then `python3 tools/ci/check.py` before pushing. The scanner version and archive checksum are pinned.
2. Open a pull request. Require `portable-checks` on the current candidate and resolved consequential findings. Actions have read-only permissions and no game/private build inputs.
3. Obtain one independent review in a fresh context for meaningful changes. Supply exact base/candidate commits, release archive/package hashes, private input identities, native evidence and known limitations. Reviewers may inspect but may not edit, deploy, merge or publish.
4. Resolve blockers and repeat review for changed source or package bytes. Keep incomplete checks explicit. Freeze the archive and validate its members/hashes.
5. Merge the reviewed candidate only after applicable checks pass. Publish a prerelease manually with the reviewed ZIP and checksum. CI does not automatically publish.

For `main`, enable required pull requests, the current `portable-checks` status, resolved conversations, and force-push/deletion protection when GitHub supports these settings. Record actual protection separately from operational policy. Independent agent review is a recorded gate; it is not a second human GitHub approval.

No private backend source or licensed game assets may enter Git history. Exactly four approved stock-feature PNGs are allowed under `docs/screenshots/`; their hashes and dimensions are checked. Original packages and private inputs stay outside this repository. Compiled release files belong in release assets, not Git.
