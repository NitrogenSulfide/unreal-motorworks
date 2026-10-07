"""Regression cases for publication boundaries, using disposable repositories."""
from pathlib import Path
import subprocess
import tempfile
import unittest

from check import check_boundary


class BoundaryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git('init', '-q')
        self.git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
                 'commit', '-qm', 'initial', '--allow-empty')

    def git(self, *args):
        subprocess.run(['git', *args], cwd=self.root, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def add(self, name, data=b'fixture'):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        self.git('add', '-f', '--', name)

    def test_source_allowed_and_private_untracked_files_not_read(self):
        self.add('.gitignore', b'dist/\n')
        self.add('ut2004/example.uc')
        (self.root / 'dist').mkdir()
        (self.root / 'dist/private.u').write_bytes(b'private fixture')
        self.assertEqual(len(check_boundary(self.root)), 2)

    def test_force_added_ignored_file_rejected(self):
        self.add('.gitignore', b'private-input/\n')
        self.add('private-input/data.txt')
        with self.assertRaisesRegex(ValueError, 'Private/generated'):
            check_boundary(self.root)

    def test_removed_private_package_still_rejected_in_history(self):
        self.add('ut2004/leak.u')
        self.git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'fixture')
        self.git('rm', 'ut2004/leak.u')
        with self.assertRaisesRegex(ValueError, 'Private/generated'):
            check_boundary(self.root)

    def test_symlink_rejected_without_reading_target(self):
        (self.root / 'link').symlink_to('/does-not-exist')
        self.git('add', 'link')
        with self.assertRaisesRegex(ValueError, 'Unsupported Git entry'):
            check_boundary(self.root)

    def test_untracked_source_cannot_silently_escape_checks(self):
        (self.root / 'forgotten.py').write_text('invalid source')
        with self.assertRaisesRegex(ValueError, 'Untracked source'):
            check_boundary(self.root)

    def test_staged_contents_cannot_hide_behind_safe_working_copy(self):
        self.add('example.py', b'staged contents that must be scanned')
        (self.root / 'example.py').write_bytes(b'different safe working contents')
        with self.assertRaisesRegex(ValueError, 'Unstaged tracked changes'):
            check_boundary(self.root)


if __name__ == '__main__':
    unittest.main()
