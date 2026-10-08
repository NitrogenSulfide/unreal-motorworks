class MutVehiclePartsTest extends Mutator;
var int Stage, Failures, BaseParts;
var WoRM_vCfgFix Pool;
var VehicleStuffFix Tuner;
var ONSVehicle Sample;
var ONSWeapon OriginalGun;
var int OriginalAttachments;
function Check(bool OK,string Message)
{
 if(OK)Log("[VehicleParts] PASS" @ Message);
 else {Failures++;Log("[VehicleParts] FAIL" @ Message);}
}
function int Attachments(Actor Parent)
{
 local Actor A;local int Count;
 foreach AllActors(class'Actor',A)if(A.Base==Parent)Count++;
 return Count;
}
function VehicleStuffFix.VehicleProperties StockProfile(class<ONSVehicle> C)
{
 local VehicleStuffFix.VehicleProperties VP;local int i;
 VP.VehicleClass=string(C);VP.VehicleName=C.Name $ " variant";VP.ProfileId=91;
 VP.Health=C.default.Health;VP.SpeedScale=1;VP.Friction=1;VP.Mass=1;
 VP.WheelScale=1;VP.JumpHeight=1;VP.HoverHeight=1;
 for(i=0;i<Min(2,C.default.DriverWeapons.Length);i++)VP.DWeapons[i].WeaponClass=string(C.default.DriverWeapons[i].WeaponClass);
 for(i=0;i<Min(4,C.default.PassengerWeapons.Length);i++)
  if(C.default.PassengerWeapons[i].WeaponPawnClass!=None)VP.PWeapons[i].WeaponClass=string(C.default.PassengerWeapons[i].WeaponPawnClass.default.GunClass);
 return VP;
}
function CheckUnchanged(string Path)
{
 local class<ONSVehicle> C;local ONSVehicle V;local ONSWeapon Gun,PassengerGun;
 local VehicleStuffFix.VehicleProperties VP;
 C=class<ONSVehicle>(DynamicLoadObject(Path,class'Class',true));Check(C!=None,"comparison package loads " $ Path);if(C==None)return;
 V=Spawn(C,,,vect(0,0,5000));Check(V!=None,"comparison vehicle spawns " $ Path);if(V==None)return;
 Gun=V.Weapons[0];if(V.WeaponPawns.Length>0)PassengerGun=V.WeaponPawns[0].Gun;
 VP=StockProfile(C);Tuner.SetLiveProfile(0,VP);Tuner.ChangeVehicleProps(V,0);
 Check(V.Weapons[0]==Gun && !Gun.bDeleteMe,"unchanged driver actor preserved " $ Path);
 if(PassengerGun!=None)Check(V.WeaponPawns[0].Gun==PassengerGun && !PassengerGun.bDeleteMe,"unchanged passenger preserved " $ Path);
 V.Destroy();
}
function PostBeginPlay(){SetTimer(2,true);}
function Timer()
{
 local PlayerController PC;local GUIController Menus;local VehicleSuiteConfig Hub;
 local class<ONSVehicle> C;local VehicleStuffFix.VehicleProperties VP;
 foreach DynamicActors(class'PlayerController',PC)if(PC.Player!=None)break;
 if(PC==None || PC.Player==None)return;
 Menus=GUIController(PC.Player.GUIController);
 if(Stage==0)
 {
  foreach DynamicActors(class'VehicleStuffFix',Tuner)break;
  Check(Tuner!=None,"native tuner active");
  C=class<ONSVehicle>(DynamicLoadObject("DKoppIIVehicles.Defender",class'Class',true));
  Check(C!=None,"Defender package loads");if(C==None){Stage=4;return;}
  Sample=Spawn(C,,,vect(0,0,5000));OriginalGun=Sample.Weapons[0];
 }
 else if(Stage==1)
 {
  OriginalAttachments=Attachments(OriginalGun);Check(OriginalAttachments>0,"Defender native turret decoration attached");
  VP=StockProfile(Sample.Class);Tuner.SetLiveProfile(0,VP);Tuner.ChangeVehicleProps(Sample,0);
  Check(Sample.Weapons[0]==OriginalGun && !OriginalGun.bDeleteMe,"Defender duplicate preserves native gun actor");
  Check(Attachments(OriginalGun)==OriginalAttachments,"Defender duplicate preserves turret attachments");
  CheckUnchanged("DKoppIIVehicles.Abrams");CheckUnchanged("Onslaught.ONSHoverTank");CheckUnchanged("BWBP_VPC_Pro.Albatross");
  class'VehicleStuffFix'.static.SetVPElement(0,VP);class'VehicleStuffFix'.default.VPsLength=1;
  PC.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox");PC.ClientOpenMenu("UnrealMotorworks.VehicleSuiteConfig");Hub=VehicleSuiteConfig(Menus.TopPage());Hub.OpenMotorpool(None);Pool=WoRM_vCfgFix(Menus.TopPage());
  Pool.UpdatePreview("DKoppIIVehicles.Defender");BaseParts=Pool.PreviewPartCount;
  Check(BaseParts>0,"Defender base preview has decoration parts");Pool.UpdatePreview("DKoppIIVehicles.Defender#91");
  Check(Pool.PreviewPartCount==BaseParts,"Defender variant preview has same parts as base");
 }
 else if(Stage==2)
 {
  Pool.PreviewFitFrames=0;Pool.PreviewDistance=2000;Pool.PreviewZoom=1;Pool.bSpinPreview=False;Pool.PreviewActor.SetRotation(rot(0,32768,0));
  Check(Sample.Weapons[0]==OriginalGun && Attachments(OriginalGun)==OriginalAttachments,"Defender attachment state remains stable after tuning tick");
 }
 else if(Stage==3)
 {
  PC.ConsoleCommand("shot");Stage++;return;
 }
 else if(Stage==4)
 {
  Menus.CloseMenu(true);Sample.Destroy();
  Log("[VehicleParts] RESULT failures=" $ Failures);PC.ConsoleCommand("quit");SetTimer(0,false);return;
 }
 Stage++;
}
