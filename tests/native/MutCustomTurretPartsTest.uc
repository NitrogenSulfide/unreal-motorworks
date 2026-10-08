class MutCustomTurretPartsTest extends MutVehiclePartsTest;
var Actor TestCamera;
var CustomVehicleWeapon CustomGun;
function PreBeginPlay()
{
 local class<ONSVehicle> C;local VehicleStuffFix.VehicleProperties VP;
 Super.PreBeginPlay();
 C=class<ONSVehicle>(DynamicLoadObject("DKoppIIVehicles.Defender",class'Class',true));
 VP=StockProfile(C);VP.ProfileId=0;class'VehicleStuffFix'.static.SetVPElement(0,VP);
 VP.ProfileId=91;VP.VehicleName="Defender custom factory variant";VP.Health=5000;VP.SpeedScale=2;
 VP.DWeapons[0].bCustomProjectiles=True;
 VP.DWeapons[0].Mode[0]="DKoppIIVehicles.PROJ_DefenderFG";
 VP.DWeapons[0].Mode[1]="DKoppIIVehicles.PROJ_DefenderAP";
 VP.DWeapons[0].Rate[0]=2;VP.DWeapons[0].Rate[1]=2;
 class'VehicleStuffFix'.static.SetVPElement(1,VP);class'VehicleStuffFix'.default.VPsLength=2;
 class'MutWoRM_vFix'.default.ReplacementPoolClassNames[0]="DKoppIIVehicles.Defender#91";
 class'MutWoRM_vFix'.default.ReplacementStrategies[0]=0;
}
function PostBeginPlay(){SetTimer(4,true);}
function Timer()
{
 local PlayerController PC;local VSFactoryProfile Binding;local VSCustomWeaponDecoration SavedPart;
 foreach DynamicActors(class'PlayerController',PC)if(PC.Player!=None)break;
 if(PC==None)return;
 if(Stage==0)
 {
  foreach DynamicActors(class'VehicleStuffFix',Tuner)break;
  foreach DynamicActors(class'VSFactoryProfile',Binding)
   if(Binding.ProfileId==91 && Binding.Factory!=None && Binding.Factory.LastSpawned!=None)
   {Sample=ONSVehicle(Binding.Factory.LastSpawned);break;}
  Check(Sample!=None,"Motorpool factory spawns Defender custom variant");
  if(Sample==None){Log("[VehicleParts] RESULT failures=" $ Failures);PC.ConsoleCommand("quit");SetTimer(0,false);return;}
  Check(Sample.Health==5000,"factory vehicle receives variant health");
  CustomGun=CustomVehicleWeapon(Sample.Weapons[0]);Check(CustomGun!=None,"factory variant uses custom firing wrapper");
  if(CustomGun!=None)
  {
   Check(CustomGun.AppearanceDecoration!=None && CustomGun.AppearanceDecoration.Base==CustomGun,"custom gun has attached DkoppII turret shell");
   Check(CustomGun.AppearanceDecoration.StaticMesh!=None,"custom turret shell has renderable static mesh");
   Check(CustomGun.FireInterval==2 && CustomGun.AltFireInterval==2,"custom firing intervals preserved");
  }
  TestCamera=Spawn(class'VSCustomWeaponDecoration',,,Sample.Location+vect(-650,450,300));TestCamera.bHidden=True;
  TestCamera.SetRotation(rotator(Sample.Location+vect(0,0,70)-TestCamera.Location));
  PC.SetViewTarget(TestCamera);PC.bBehindView=False;
 }
 else if(Stage==1){PC.ConsoleCommand("shot");}
 else if(Stage==2)
 {
  SavedPart=CustomGun.AppearanceDecoration;Sample.Destroy();Check(SavedPart==None || SavedPart.bDeleteMe,"turret shell cleaned up with gun");
  TestCamera.Destroy();Log("[VehicleParts] RESULT failures=" $ Failures);PC.ConsoleCommand("quit");SetTimer(0,false);return;
 }
 Stage++;
}
