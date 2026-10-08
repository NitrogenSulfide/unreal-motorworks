"""Temporary directory checks for the optional public upgrade helper."""
from pathlib import Path
import importlib.util,sys,tempfile,unittest,json
from unittest.mock import patch
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('migrate_settings',ROOT/'tools/migrate_settings.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class MigrationTests(unittest.TestCase):
 def test_copy_only_motorworks_and_preserve_newer_values(self):
  old=b'[OtherMod]\r\nKeep=True\r\n[VehicleStuffFix.VehicleStuffFix]\r\nVPs[4]=(VehicleName="Held",ProfileId=19,Health=800)\r\n'
  pool=b'[WoRM2k4Fix.MutWoRM_vFix]\nVehicleGroupPresets=(SetName="Held",PoolClassNames[3]="Onslaught.ONSHoverTank#19")\n[WoRM2k4.MutWoRM]\nOther=True\n'
  one=m.merge({'VehicleStuffFix.ini':old,'KangMods.ini':pool})
  self.assertIn(b'ProfileId=19',one);self.assertIn(b'Onslaught.ONSHoverTank#19',one);self.assertNotIn(b'OtherMod',one);self.assertNotIn(b'Other=True',one)
  self.assertEqual(m.merge({'VehicleStuffFix.ini':old,'KangMods.ini':pool},one),one)
  newer=b'[UnrealMotorworks.VehicleStuffFix]\nVPsLength=9\n';self.assertEqual(m.merge({'VehicleStuffFix.ini':old},newer),newer)
 def test_reference_rewrite_preserves_struct_and_unrelated_paths(self):
  value="VehicleStuffFix.VehicleProperties VehicleStuffFix.VehicleStuffFix WoRM2k4Fix.MutWoRM_vFix VehicleSuite.MutVehicleSuite DKoppIIVehicles.Defender"
  self.assertEqual(m.rewrite(value),"VehicleStuffFix.VehicleProperties UnrealMotorworks.VehicleStuffFix UnrealMotorworks.MutWoRM_vFix UnrealMotorworks.MutVehicleSuite DKoppIIVehicles.Defender")
 def fixture(self,root):
  config=root/'config';system=root/'game/System';config.mkdir();system.mkdir(parents=True)
  (config/'VehicleStuffFix.ini').write_bytes(b'[VehicleStuffFix.VehicleStuffFix]\nVPsLength=2\n')
  (config/'KangMods.ini').write_bytes(b'[Other]\nKeep=42\n[WoRM2k4Fix.MutWoRM_vFix]\nLastSavedPresetName=Held\n')
  (config/'User.ini').write_bytes(b'[Held]\nMutator=VehicleSuite.MutVehicleSuite,Other.Mod\nRoster=keep\n')
  for n in m.OLD_PACKAGES:(system/n).write_bytes(('old:'+n).encode())
  for n in ['VehicleStuff.u','WoRM2k4.u','Unrelated.u','UnrealMotorworks.u','UnrealMotorworks.ucl']:(system/n).write_bytes(('keep:'+n).encode())
  return config,system
 def test_apply_backup_retirement_and_idempotence(self):
  with tempfile.TemporaryDirectory() as temp:
   config,system=self.fixture(Path(temp));before={str(p):p.read_bytes() for folder in (config,system) for p in folder.iterdir()}
   rows=m.plan(config,system);manifest=m.apply(rows,config);record=json.loads(manifest.read_text());self.assertEqual(record['status'],'migrated')
   self.assertEqual((config/'VehicleStuffFix.ini').read_bytes(),before[str(config/'VehicleStuffFix.ini')]);self.assertEqual((config/'KangMods.ini').read_bytes(),before[str(config/'KangMods.ini')])
   self.assertIn(b'UnrealMotorworks.MutVehicleSuite,Other.Mod',(config/'User.ini').read_bytes());self.assertIn(b'Roster=keep',(config/'User.ini').read_bytes())
   self.assertFalse(any((system/n).exists() for n in m.OLD_PACKAGES))
   for n in ['VehicleStuff.u','WoRM2k4.u','Unrelated.u','UnrealMotorworks.u','UnrealMotorworks.ucl']:self.assertEqual((system/n).read_bytes(),before[str(system/n)])
   for row in record['files']:
    if row['backup']:self.assertEqual(Path(row['backup']).read_bytes(),before[row['path']])
   self.assertEqual(m.plan(config,system),[])
 def test_stale_plan_and_symlink_rejected(self):
  with tempfile.TemporaryDirectory() as temp:
   config,system=self.fixture(Path(temp));rows=m.plan(config,system);(config/'User.ini').write_bytes(b'changed')
   with self.assertRaisesRegex(RuntimeError,'Target changed'):m.apply(rows,config)
   (config/'User.ini').unlink();(config/'User.ini').symlink_to(config/'KangMods.ini')
   with self.assertRaisesRegex(RuntimeError,'redirected'):m.plan(config,system)
 def test_failure_restores_all_targets(self):
  with tempfile.TemporaryDirectory() as temp:
   config,system=self.fixture(Path(temp));before={str(p):p.read_bytes() for folder in (config,system) for p in folder.iterdir()};rows=m.plan(config,system);original=m.atomic;calls=[]
   def injected(path,data):
    original(path,data)
    if not calls:calls.append(True);raise OSError('injected write failure')
   with patch.object(m,'atomic',side_effect=injected):
    with self.assertRaisesRegex(OSError,'injected'):m.apply(rows,config)
   for p,b in before.items():self.assertEqual(Path(p).read_bytes(),b)
   self.assertFalse((config/'UnrealMotorworks.ini').exists())
   manifests=list((config/'MotorworksUpgradeBackups').glob('*/manifest.json'));self.assertEqual(json.loads(manifests[0].read_text())['status'],'rolled back after failure')
if __name__=='__main__':unittest.main()
