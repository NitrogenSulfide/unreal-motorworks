"""Portable metadata/package fixtures; no engine, network or installation."""
from pathlib import Path
import hashlib,json,struct,subprocess,sys,tempfile,unittest,zipfile
ROOT=Path(__file__).resolve().parents[1]
MEMBERS={'README.md','upgrade-settings.py','System/UnrealMotorworks.u','System/UnrealMotorworks.ucl'}
class PublicMetadataTests(unittest.TestCase):
 def test_release_identity_and_registration(self):
  version=(ROOT/'release/VERSION').read_text().strip();m=json.loads((ROOT/'release/manifest.json').read_text())
  self.assertEqual(version,m['version']);self.assertRegex(version,r'^\d+\.\d+\.\d+-beta\.\d+$')
  self.assertIn('v'+version,(ROOT/'README.md').read_text());self.assertEqual(m['archive'],'UnrealMotorworks-v'+version+'.zip')
  self.assertEqual(set(m['files']),MEMBERS)
  for h in [m['archive_sha256'],*m['files'].values()]:self.assertRegex(h,r'^[0-9a-f]{64}$')
  self.assertEqual(hashlib.sha256((ROOT/'src/UnrealMotorworks.ucl').read_bytes()).hexdigest(),m['files']['System/UnrealMotorworks.ucl'])
 def test_approved_original_screenshots(self):
  images=json.loads((ROOT/'docs/screenshots/manifest.json').read_text())['images'];self.assertEqual(len(images),4)
  self.assertEqual({i['file'] for i in images},{'docs/screenshots/'+n+'-3840x2160.png' for n in ['01-replacement-groups','02-vehicle-tuning','03-weapons','04-mount-placement']})
  for i in images:
   data=(ROOT/i['file']).read_bytes();self.assertEqual(data[:8],b'\x89PNG\r\n\x1a\n');self.assertEqual(struct.unpack('>II',data[16:24]),(3840,2160));self.assertEqual(hashlib.sha256(data).hexdigest(),i['sha256'])
 def verify_fixture(self,transform):
  data={n:b'fixture' for n in MEMBERS};data['System/UnrealMotorworks.ucl']=b'Mutator=(ClassName=UnrealMotorworks.MutVehicleSuite)\n'
  transform(data)
  with tempfile.TemporaryDirectory() as tmp:
   p=Path(tmp);z=p/'release.zip'
   with zipfile.ZipFile(z,'w') as f:
    for n,b in data.items():f.writestr(n,b)
   (p/'manifest.json').write_text(json.dumps({'files':{n:hashlib.sha256(b).hexdigest() for n,b in data.items()}}))
   return subprocess.run([sys.executable,str(ROOT/'tools/verify_release.py'),str(z),'--manifest',str(p/'manifest.json')],capture_output=True,text=True)
 def test_valid_release_fixture(self):self.assertEqual(self.verify_fixture(lambda d:None).returncode,0)
 def test_personal_config_rejected(self):self.assertNotEqual(self.verify_fixture(lambda d:d.update({'System/KangMods.ini':b'personal'})).returncode,0)
 def test_old_package_layout_rejected(self):self.assertNotEqual(self.verify_fixture(lambda d:d.update({'System/VehicleSuite.u':b'old'})).returncode,0)
 def test_wrong_mutator_registration_rejected(self):self.assertNotEqual(self.verify_fixture(lambda d:d.update({'System/UnrealMotorworks.ucl':b'Mutator=(ClassName=VehicleSuite.MutVehicleSuite)'})).returncode,0)
if __name__=='__main__':unittest.main()
