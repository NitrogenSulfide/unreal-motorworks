#!/usr/bin/env python3
"""Optional, reversible migration from pre-0.3 native OldUnreal Motorworks.

Dry-run by default. Explicit configuration/System paths only; no game discovery,
network access, engine launches, or runtime dependencies on the original mods.
"""
from pathlib import Path
import argparse,datetime,hashlib,json,os,re,tempfile

CLASS_NAMES = ('BlueNattoAvatar', 'CustomVehicleWeapon', 'MutVehicleSuite', 'MutWoRM_vFix', 'STY_WoRMGroupBadge', 'VSActionButton', 'VSAvatarImage', 'VSConfigSaveAck', 'VSCustomWeaponDecoration', 'VSCustomWeaponGUI', 'VSFactoryProfile', 'VSGUI', 'VSHealthRoll', 'VSIGGUI', 'VSLegacyCredits', 'VSMenuText', 'VSMountReplication', 'VSNativeLabel', 'VSScaledButton', 'VSScaledLabel', 'VSStationaryMapping', 'VSTabHealth', 'VSTabMain', 'VSTabMount', 'VSTabWeap', 'VSUpdateInfo', 'VSWarningLabel', 'VSWeaponAppearance', 'VSWeaponComboBox', 'VSWeaponOccupantHider', 'VehicleStuffFix', 'VehicleSuiteConfig', 'WoRM_vCfgFix')
SECTIONS = {
 'VehicleStuffFix.ini': ('VehicleStuffFix.VehicleStuffFix',),
 'KangMods.ini': ('WoRM2k4Fix.MutWoRM_vFix','WoRM2k4Fix.WoRM_vCfgFix'),
 'VehicleSuite.ini': ('VehicleSuite.MutVehicleSuite',),
}
OLD_PACKAGES = tuple(n+ext for n in ('VehicleSuite','VehicleStuffFix','WoRM2k4Fix') for ext in ('.u','.ucl'))

def digest(data):return hashlib.sha256(data).hexdigest()

def rewrite(text):
 names='|'.join(re.escape(n) for n in sorted(CLASS_NAMES,key=len,reverse=True))
 return re.sub(r'\b(?:VehicleStuffFix|WoRM2k4Fix|VehicleSuite)\.(?=(?:'+names+r')\b)','UnrealMotorworks.',text,flags=re.I)

def merge(files,existing=b''):
 result=existing.decode('latin-1');present={n.casefold() for n in re.findall(r'^\[([^\]\r\n]+)\]',result,re.M)}
 for filename,wanted in SECTIONS.items():
  text=files.get(filename,b'').decode('latin-1');matches=list(re.finditer(r'^\[([^\]\r\n]+)\][^\r\n]*(?:\r?\n|$)',text,re.M))
  for i,m in enumerate(matches):
   if m[1].casefold() not in {n.casefold() for n in wanted}:continue
   target=rewrite(m[1])
   if target.casefold() in present:continue
   end=matches[i+1].start() if i+1<len(matches) else len(text)
   body=rewrite(text[m.end():end]);result=result.rstrip('\r\n')+'\r\n\r\n['+target+']\r\n'+body.rstrip('\r\n')+'\r\n';present.add(target.casefold())
 return result.encode('latin-1')

def regular(path):
 if path.is_symlink() or (path.exists() and not path.is_file()):raise RuntimeError('Refusing redirected/non-file target: '+str(path))
 return path.read_bytes() if path.exists() else None

def plan(config,system=None):
 config=config.resolve(strict=True)
 if not config.is_dir():raise RuntimeError('Configuration directory must exist')
 if system:
  system=system.resolve(strict=True)
  if not system.is_dir() or system.name.casefold()!='system':raise RuntimeError('Game System directory must exist and be named System')
 rows=[];files={name:regular(config/name) or b'' for name in SECTIONS};target=config/'UnrealMotorworks.ini';before=regular(target);after=merge(files,before or b'')
 if after!=(before or b''):rows.append({'path':target,'before':before,'after':after})
 for folder in dict.fromkeys([config,*([system] if system else [])]):
  for path in sorted(folder.glob('*.ini')):
   if path.name in {*SECTIONS,'UnrealMotorworks.ini'}:continue
   original=regular(path);updated=rewrite(original.decode('latin-1')).encode('latin-1')
   if updated!=original:rows.append({'path':path,'before':original,'after':updated})
 if system:
  for name in OLD_PACKAGES:
   path=system/name;original=regular(path)
   if original is not None:rows.append({'path':path,'before':original,'after':None})
 return rows

def atomic(path,data):
 mode=path.stat().st_mode & 0o777 if path.exists() else 0o600
 with tempfile.NamedTemporaryFile(dir=path.parent,prefix='.motorworks-',delete=False) as out:
  temporary=Path(out.name);out.write(data);out.flush();os.fsync(out.fileno())
 try:os.chmod(temporary,mode);os.replace(temporary,path)
 finally:temporary.unlink(missing_ok=True)

def check_closed(system):
 if system and Path('/proc').is_dir():
  root=system.resolve().parent
  for proc in Path('/proc').iterdir():
   if not proc.name.isdigit():continue
   try:
    if (proc/'exe').resolve(strict=True).is_relative_to(root):raise RuntimeError('Close the native OldUnreal game first (PID '+proc.name+')')
   except (FileNotFoundError,PermissionError,ProcessLookupError):pass

def apply(rows,config):
 if not rows:return None
 # Validate all targets before backup/write; preserve exact old INI bytes.
 for row in rows:
  if regular(row['path'])!=row['before']:raise RuntimeError('Target changed; run migration again')
 backup=config/'MotorworksUpgradeBackups'/datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%S%fZ');backup.mkdir(parents=True,mode=0o700)
 record={'status':'prepared','files':[]}
 for i,row in enumerate(rows):
  copy=backup/(str(i)+'-'+row['path'].name)
  if row['before'] is not None:copy.write_bytes(row['before']);os.chmod(copy,0o600)
  record['files'].append({'path':str(row['path']),'backup':str(copy) if row['before'] is not None else None,'before_sha256':digest(row['before']) if row['before'] is not None else None,'after_sha256':digest(row['after']) if row['after'] is not None else None})
 manifest=backup/'manifest.json';manifest.write_text(json.dumps(record,indent=2)+'\n')
 try:
  for row in rows:
   if row['after'] is None:row['path'].unlink()
   else:atomic(row['path'],row['after'])
  for row in rows:
   if regular(row['path'])!=row['after']:raise RuntimeError('Verification failed: '+str(row['path']))
 except BaseException:
  for row in reversed(rows):
   if row['before'] is None:row['path'].unlink(missing_ok=True)
   else:atomic(row['path'],row['before'])
  record['status']='rolled back after failure';manifest.write_text(json.dumps(record,indent=2)+'\n');raise
 record['status']='migrated';manifest.write_text(json.dumps(record,indent=2)+'\n');return manifest

def main():
 parser=argparse.ArgumentParser(description=__doc__)
 parser.add_argument('--config-dir',type=Path,required=True,help='Native OldUnreal writable System configuration directory')
 parser.add_argument('--game-system-dir',type=Path,help='Optional native game System directory: update references and back up/remove only six old Motorworks package files')
 parser.add_argument('--apply',action='store_true');parser.add_argument('--game-closed',action='store_true',help='Confirm the native game is closed before applying')
 args=parser.parse_args()
 if args.apply and not args.game_closed:parser.error('--apply requires --game-closed')
 check_closed(args.game_system_dir);rows=plan(args.config_dir,args.game_system_dir)
 for row in rows:print(('Back up and remove: ' if row['after'] is None else 'Back up and migrate: ')+str(row['path']))
 if not rows:print('No migration needed; existing unified settings remain authoritative.')
 elif args.apply:print('Migration verified. Exact rollback backups: '+str(apply(rows,args.config_dir.resolve())))
 else:print('Preview only. Add --apply --game-closed after reviewing these targets.')
 return 0
if __name__=='__main__':raise SystemExit(main())
