#!/usr/bin/env python3

from __future__ import annotations

import argparse
import hashlib
import json
import zipfile
from pathlib import Path


EXPECTED_MEMBERS = {
    "README.md", "upgrade-settings.py",
    "System/UnrealMotorworks.u", "System/UnrealMotorworks.ucl",
}
REQUIRED_PACKAGES = {"System/UnrealMotorworks.u"}


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path)
    parser.add_argument(
        "--manifest",
        type=Path,
        required=True,
        help="Build manifest containing exact release hashes",
    )
    args = parser.parse_args()

    manifest = json.loads(args.manifest.read_text(encoding="utf-8-sig"))
    expected_files = manifest.get("files", manifest.get("packages"))
    if not isinstance(expected_files, dict):
        raise SystemExit("build manifest must contain a 'files' or 'packages' hash mapping")

    release_hashes = {
        name: expected_hash
        for name, expected_hash in expected_files.items()
        if name in EXPECTED_MEMBERS
    }
    if set(expected_files) != EXPECTED_MEMBERS:
        raise SystemExit('build manifest must hash every release member')
    if not REQUIRED_PACKAGES <= release_hashes.keys():
        missing = sorted(REQUIRED_PACKAGES - release_hashes.keys())
        raise SystemExit(f"build manifest is missing release package hashes: {missing}")
    unknown = set(expected_files) - EXPECTED_MEMBERS
    if unknown:
        raise SystemExit(f"build manifest contains unexpected release files: {sorted(unknown)}")

    with zipfile.ZipFile(args.archive) as archive:
        member_list = [name for name in archive.namelist() if not name.endswith("/")]
        members = set(member_list)
        if len(member_list) != len(members):
            raise SystemExit("duplicate archive members")
        if members != EXPECTED_MEMBERS:
            raise SystemExit(f"unexpected archive members: {sorted(members ^ EXPECTED_MEMBERS)}")

        for member, expected_hash in release_hashes.items():
            actual_hash = sha256(archive.read(member))
            if actual_hash != expected_hash:
                raise SystemExit(f"release hash mismatch for {member}: {actual_hash}")

        suite_cache = archive.read("System/UnrealMotorworks.ucl").decode("utf-8")
        if suite_cache.count("Mutator=(") != 1:
            raise SystemExit("UnrealMotorworks.ucl must contain exactly one mutator registration")
        if "UnrealMotorworks.MutVehicleSuite" not in suite_cache:
            raise SystemExit("UnrealMotorworks.ucl does not register the suite mutator")

        forbidden = {"System/KangMods.ini", "System/VehicleStuffFix.ini", "System/WoRM2k4.u"}
        if members & forbidden:
            raise SystemExit(f"forbidden configuration/original payload present: {sorted(members & forbidden)}")

    print(f"Release verified: {args.archive}")
    print(f"Archive SHA-256: {sha256(args.archive.read_bytes())}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
