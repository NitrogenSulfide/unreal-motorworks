#!/usr/bin/env python3
"""Portable pre-push/CI checks. No engine builds, game launches, or deployment."""
import argparse
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SCANNER_VERSION = '8.30.1'
APPROVED_IMAGES = {
 'docs/screenshots/' + name + '-3840x2160.png'
 for name in ('01-replacement-groups','02-vehicle-tuning','03-weapons','04-mount-placement')
}
LEGACY_IMAGES = set()


def git(root, *args, input=None):
    return subprocess.run(['git', *args], cwd=root, input=input, check=True,
                          stdout=subprocess.PIPE).stdout


def forbidden(name):
    path = PurePosixPath(name)
    parts = set(path.parts)
    return (
        bool(parts & {'dist', '.private', '.local-state', '__pycache__', '.codex', 'scratch', 'VehicleStuffFix', 'WoRM2k4Fix'})
        or name.startswith(('tools/game-content-manager/state/', 'ut2004/notes/',
                            'ut2004/projects/vehiclestuff-fix/', 'ut2004/projects/worm2k4-fix/'))
        or (path.name.startswith('.env') and path.name != '.env.example')
        or (path.suffix.lower() in {'.png', '.jpg', '.jpeg', '.tga'} and name not in APPROVED_IMAGES)
        or path.suffix.lower() in {'.u', '.utx', '.ukx', '.usx', '.uax', '.ut2', '.uz2', '.log', '.bak'}
    )


def check_boundary(root):
    # The index is the next commit. Never certify different working-tree bytes.
    diff = subprocess.run(['git', 'diff', '--quiet', '--exit-code', '--'], cwd=root)
    if diff.returncode:
        raise ValueError('Unstaged tracked changes exist or index comparison failed; stage intended changes before validation.')
    entries = git(root, 'ls-files', '--stage', '-z').split(b'\0')
    names = []
    for entry in filter(None, entries):
        metadata, raw = entry.split(b'\t', 1)
        mode, _, stage = metadata.split()
        name = raw.decode('utf-8')
        if mode not in (b'100644', b'100755') or stage != b'0':
            raise ValueError(f'Unsupported Git entry (symlink, submodule, or conflict): {name!r}')
        if any(ord(c) < 32 for c in name):
            raise ValueError('Control characters in tracked filename')
        path = root / name
        if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(root.resolve()):
            raise ValueError(f'Tracked file missing or redirected; stage intended deletions: {name}')
        names.append(name)
    # Include paths deleted by later commits: pushing still transfers their objects.
    historical = git(root, 'log', '--format=', '--name-only', '--no-renames', '-m', '-z', 'HEAD')
    all_names = set(names) | {name.decode('utf-8') for name in historical.split(b'\0') if name}
    bad = sorted(name for name in all_names if forbidden(name))
    payload = b''.join(n.encode('utf-8') + b'\0' for n in sorted(all_names))
    ignored = subprocess.run(['git', 'check-ignore', '--no-index', '-z', '--stdin'],
                             cwd=root, input=payload, stdout=subprocess.PIPE)
    if ignored.returncode not in (0, 1):
        raise ValueError('Could not evaluate publication ignore rules')
    bad.extend(n.decode('utf-8') for n in ignored.stdout.split(b'\0')
               if n and n.decode('utf-8') not in LEGACY_IMAGES)
    if bad:
        raise ValueError('Private/generated paths in candidate or reachable history:\n' + '\n'.join(sorted(set(bad))))
    untracked = git(root, 'ls-files', '--others', '--exclude-standard', '-z')
    if untracked:
        raise ValueError('Untracked source files exist; stage intended files before validation (ignored private files are excluded).')
    return names


def run(command, root, env=None):
    subprocess.run(command, cwd=root, env=env, check=True)


def check(root, scanner):
    if git(root, 'rev-parse', '--is-shallow-repository').strip() != b'false':
        raise ValueError('Full candidate history is required; fetch with depth 0.')
    names = check_boundary(root)
    print(f'Publication boundary: {len(names)} tracked files plus reachable HEAD history', flush=True)
    run(['git', 'diff', '--check'], root)
    run(['git', 'diff', '--cached', '--check'], root)
    for name in names:
        path = root / name
        if path.suffix == '.py':
            compile(path.read_bytes(), name, 'exec')
        elif path.suffix == '.sh':
            run(['bash', '-n', str(path)], root)
        elif path.suffix == '.json':
            json.loads(path.read_text())
    version = subprocess.check_output([scanner, 'version'], text=True).strip()
    if version != SCANNER_VERSION:
        raise ValueError(f'Expected Gitleaks {SCANNER_VERSION}, found {version}')
    # Redact findings. Scan selected history, never unrelated archival/local refs.
    flags = ['--redact=100', '--no-banner', '--ignore-gitleaks-allow']
    run([scanner, 'git', str(root), '--log-opts=--full-history -m HEAD', *flags], root)
    with tempfile.TemporaryDirectory(prefix='ut2004-source-check-') as directory:
        stage = Path(directory)
        # Only tracked working files; ignored private data never enters the scan/export.
        for name in names:
            target = stage / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(root / name, target)
        run([scanner, 'dir', str(stage), *flags], root)
        env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1',
                   UT2004_GAME_DIR=str(stage / 'NO_LIVE_GAME'),
                   UT2004_CONFIG_DIR=str(stage / 'NO_LIVE_CONFIG'),
                   UT2004_UCC=str(stage / 'NO_COMPILER'))
        # An explicit list avoids accidentally discovering engine/visual launchers.
        suites = [('tools/ci', 'test_check.py'), ('tests', 'test_public_metadata.py')]
        for directory, pattern in suites:
            if not (stage / directory / pattern).is_file():
                raise ValueError(f'Required fixture suite is missing: {directory}/{pattern}')
            print(f'Fixture suite: {pattern}', flush=True)
            run([sys.executable, '-m', 'unittest', 'discover', '-s', directory, '-p', pattern, '-v'], stage, env)
    print('PASS: portable source/fixture/secret checks. Native, visual, review, and release gates remain separate.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gitleaks', default=str(ROOT / '.local-state/ci/bin/gitleaks'))
    args = parser.parse_args()
    try:
        check(ROOT, args.gitleaks)
    except (ValueError, OSError, subprocess.CalledProcessError, SyntaxError) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
