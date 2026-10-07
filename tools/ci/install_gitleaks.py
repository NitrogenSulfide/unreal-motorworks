#!/usr/bin/env python3
"""Install the pinned Linux x64 scanner locally, after verifying its archive."""
import argparse
import hashlib
import io
from pathlib import Path
import platform
import tarfile
import urllib.request

VERSION = '8.30.1'
ARCHIVE_SHA256 = '551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb'
ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--directory', type=Path, default=ROOT / '.local-state/ci/bin')
    args = parser.parse_args()
    if platform.system() != 'Linux' or platform.machine() not in ('x86_64', 'AMD64'):
        parser.error('This installer supports Linux x64; supply Gitleaks 8.30.1 via --gitleaks on other hosts.')
    url = f'https://github.com/gitleaks/gitleaks/releases/download/v{VERSION}/gitleaks_{VERSION}_linux_x64.tar.gz'
    with urllib.request.urlopen(url, timeout=60) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != ARCHIVE_SHA256:
        raise SystemExit('Scanner archive hash mismatch; nothing installed.')
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as archive:
        member = archive.getmember('gitleaks')
        if not member.isfile():
            raise SystemExit('Scanner archive member is not a regular file.')
        binary = archive.extractfile(member).read()
    args.directory.mkdir(parents=True, exist_ok=True)
    target = args.directory / 'gitleaks'
    if target.is_symlink():
        raise SystemExit('Refusing to overwrite a symlink.')
    target.write_bytes(binary)
    target.chmod(0o755)
    print(target)


if __name__ == '__main__':
    main()
