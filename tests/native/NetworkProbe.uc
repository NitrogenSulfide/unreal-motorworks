class NetworkProbe extends Info;
var ONSVehicle Target;
var ONSWeapon TargetWeapon, TargetPassenger;
var int Phase, ExpectedHealth, ExpectedMax, ReceivedPhase, Checks, Failures, WaitTicks;
var float ExpectedScale;
var VSIGGUI Editor;
var int SaveStage;
var VehicleStuffFix.PartialVehicleProperties RawVP;
var GUIController Menus;
var MutMotorworksNetworkTest Harness;
replication
{
 reliable if(Role==ROLE_Authority) Target, TargetWeapon, TargetPassenger, Phase, ExpectedHealth, ExpectedMax, ExpectedScale;
 reliable if(Role<ROLE_Authority) Report;
}
simulated function PostNetBeginPlay() { Super.PostNetBeginPlay(); Log("[MotorworksNetworkClient] probe received netmode=" $ Level.NetMode $ " role=" $ Role); SetTimer(0.5,true); }
simulated function Check(bool OK, string Message)
{
 Checks++;
 if(!OK) { Failures++; Log("[MotorworksNetworkClient] FAIL" @ Message); }
 else Log("[MotorworksNetworkClient] PASS" @ Message);
}
function Report(int P, int C, int F)
{
 Log("[MotorworksNetworkServer] client report phase=" $ P $ " checks=" $ C $ " failures=" $ F);
 if(Harness!=None) Harness.Receive(P,C,F);
}
simulated function Timer()
{
 local PlayerController PC;
 local ONSWeapon W;
 local CustomVehicleWeapon CW;
 local VehicleStuffFix.VehicleProperties VP;
 if(Role==ROLE_Authority) return;
 if(Phase==3 || Phase==4)
 {
  foreach DynamicActors(class'PlayerController',PC) if(PC.Player!=None) break;
  if(PC==None) return;
  Menus=GUIController(PC.Player.GUIController);
  if(Phase==3 && SaveStage==0)
  {
   VP.VehicleClass="Onslaught.ONSHoverTank";VP.VehicleName="Network save tank";VP.Health=1000;
   VP.SpeedScale=1;VP.Friction=1;VP.Mass=1;VP.WheelScale=1;VP.JumpHeight=1;VP.HoverHeight=1;
   VP.DWeapons[0].WeaponClass="Onslaught.ONSHoverTankCannon";
   class'VehicleStuffFix'.static.SetVPElement(0,VP);class'VehicleStuffFix'.default.VPsLength=1;
   PC.ClientOpenMenu("UnrealMotorworks.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());
   Editor.SelectProfile("Onslaught.ONSHoverTank");
   Check(!Editor.CanUseOriginalAppearance(2),"empty passenger weapon safely disables appearance without a class load");
   Editor.SetWeaponClass("Onslaught.ONSAttackCraftGun",0);Editor.SetCustomProjectilesEnabled(0,true);
   VP=Editor.GetCurrentVP();VP.DWeapons[0].Mode[0]="XWeapons.FlakShell";Editor.SetCurrentVP(VP);
   Editor.HealthChange(2345);Editor.SaveWithoutClosing(None);
   Check(Editor.bSendingSave && Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"remote Save remains unsaved until server acknowledgment");
   Check(!Editor.SaveWithoutClosing(None),"remote Save prevents overlapping transfers");
   Editor.HealthChange(3456);SaveStage=1;return;
  }
  if(Phase==3 && SaveStage==1 && !Editor.bSendingSave)
  {
   Check(GUIButton(Editor.Controls[19]).Caption=="Save","remote Save received server acknowledgment");
   Check(Editor.GetCurrentVP().Health==3456 && Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"edit made while sending remains red after acknowledgment");
   Editor.CancelAndClose(None);PC.ClientOpenMenu("UnrealMotorworks.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");
   Check(Editor.GetCurrentVP().Health==2345,"Cancel preserves only the acknowledged remote snapshot");
   Check(Editor.GetCurrentVP().VehicleName=="Network save tank","remote snapshot preserves spaces in the vehicle name");
   Check(Editor.GetCurrentVP().DWeapons[0].bCustomProjectiles && Editor.GetCurrentVP().DWeapons[0].WeaponClass=="Onslaught.ONSAttackCraftGun","remote reopened snapshot keeps selected gun and independent flag");
   Check(Editor.GetCurrentVP().DWeapons[0].Mode[0]=="XWeapons.FlakShell","remote reopened snapshot keeps custom projectile");
   Editor.CancelAndClose(None);SaveStage=2;Report(3,Checks,Failures);return;
  }
  if(Phase==4 && SaveStage==2)
  {
   PC.ClientOpenMenu("UnrealMotorworks.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");
   Editor.HealthChange(4567);Editor.SaveWithoutClosing(None);SaveStage=3;return;
  }
  if(Phase==4 && SaveStage==3 && !Editor.bSendingSave)
  {
   Check(GUIButton(Editor.Controls[19]).Caption=="Retry Save","rejected remote Save reports missing acknowledgment");
   Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"rejected remote Save does not advance baseline");
   Editor.CancelAndClose(None);PC.ClientOpenMenu("UnrealMotorworks.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");
   Check(Editor.GetCurrentVP().Health==2345,"Cancel after rejected Save retains previously acknowledged settings");
   Editor.CancelAndClose(None);SaveStage=4;Report(4,Checks,Failures);return;
  }
  return;
 }
 if(Phase==8)
 {
  foreach DynamicActors(class'PlayerController',PC) if(PC.Player!=None) break;
  if(PC==None)return;
  if(SaveStage==4)
  {
   // Raw client protocol intentionally bypasses all editor and profile setters.
   PC.ConsoleCommand("mutate VehicleStuffFix SU LimitBoundary");
   RawVP.VehicleName="RemoteCap";RawVP.VehicleClass="Onslaught.ONSHoverTank";
   RawVP.SpeedScale=99;RawVP.Friction=99;RawVP.Mass=99;RawVP.WheelScale=99;RawVP.JumpHeight=99;RawVP.HoverHeight=99;RawVP.Health=2147483647;
   PC.ConsoleCommand("mutate VehicleStuffFix U M 0" @ GetPropertyText("RawVP") @ "0 LimitBoundary");
   PC.ConsoleCommand("mutate VehicleStuffFix U E LimitBoundary");
   PC.ConsoleCommand("mutate VehicleStuffFix EU LimitBoundary");
   SaveStage=5;WaitTicks=0;return;
  }
  if(SaveStage==5)
  {
   WaitTicks++;if(WaitTicks<10)return;
   Check(true,"raw oversized remote transfer sent from real client");
   SaveStage=6;Report(8,Checks,Failures);
  }
  return;
 }
 if(Phase==9)
 {
  if(ReceivedPhase==9 || Target==None)return;
  WaitTicks++;if(WaitTicks<12)return;
  Check(Target.Health==1000000 && Target.HealthMax==1000000,"server capped million HP replicates to real client");
  ReceivedPhase=9;Report(9,Checks,Failures);return;
 }
 if(Phase==5)
 {
  WaitTicks++; if(WaitTicks<6) return;
  Log("[MotorworksNetworkClient] RESULT checks=" $ Checks $ " failures=" $ Failures);
  foreach DynamicActors(class'PlayerController',PC)
   if(PC.Player!=None) { PC.ConsoleCommand("exit"); return; }
 }
 if(((Phase<6 && Phase<=ReceivedPhase) || (Phase>=6 && Phase==ReceivedPhase)) || Target==None) return;
 W=TargetWeapon;
 if(W==None) return;
 // Give all replicated actors and the mount helper time to settle.
 WaitTicks++;
 if(WaitTicks<12) return;
 WaitTicks=0;
 ReceivedPhase=Phase;
 Check(Level.NetMode==NM_Client,"real network client");
 Check(W.Base==Target,"replicated weapon is attached to the vehicle phase=" $ Phase);
 Check(Target.Health==ExpectedHealth,"server health reached client phase=" $ Phase);
 Check(Target.HealthMax==ExpectedMax,"server health maximum reached client phase=" $ Phase);
 if(Phase==1) Check(W.Class==class'ONSHoverTankCannon',"base tank cannon reached client");
 else if(Phase==6 || Phase==7)
 {
  Check(W.Class==class'ONSAttackCraftGun',"ordinary replacement weapon class reached client phase=" $ Phase);
  Check(W.ProjectileClass==class'ONSAttackCraftGun'.default.ProjectileClass && Abs(W.FireInterval-class'ONSAttackCraftGun'.default.FireInterval)<0.001,"ordinary replacement projectile and interval unchanged phase=" $ Phase);
  if(Phase==6)
  {
   Check(W.Mesh==class'ONSHoverTankCannon'.default.Mesh,"ordinary driver original mesh reached client");
   Check(W.WeaponFireAttachmentBone==class'ONSHoverTankCannon'.default.WeaponFireAttachmentBone && W.WeaponFireOffset==class'ONSHoverTankCannon'.default.WeaponFireOffset,"ordinary driver stock muzzle reached client");
   Check(TargetPassenger!=None && TargetPassenger.Mesh==class'ONSTankSecondaryTurret'.default.Mesh,"ordinary passenger original mesh reached client");
   Check(TargetPassenger!=None && TargetPassenger.WeaponFireAttachmentBone==class'ONSTankSecondaryTurret'.default.WeaponFireAttachmentBone && TargetPassenger.WeaponFireOffset==class'ONSTankSecondaryTurret'.default.WeaponFireOffset,"ordinary passenger stock muzzle reached client");
  }
  else
  {
   Check(W.Mesh==class'ONSAttackCraftGun'.default.Mesh,"ordinary driver replacement mesh restored on client");
   Check(W.WeaponFireAttachmentBone==class'ONSAttackCraftGun'.default.WeaponFireAttachmentBone && W.WeaponFireOffset==class'ONSAttackCraftGun'.default.WeaponFireOffset,"ordinary driver replacement muzzle restored on client");
   Check(TargetPassenger!=None && TargetPassenger.Mesh==class'ONSAttackCraftGun'.default.Mesh,"ordinary passenger replacement mesh restored on client");
   Check(TargetPassenger!=None && TargetPassenger.WeaponFireAttachmentBone==class'ONSAttackCraftGun'.default.WeaponFireAttachmentBone && TargetPassenger.WeaponFireOffset==class'ONSAttackCraftGun'.default.WeaponFireOffset,"ordinary passenger replacement muzzle restored on client");
  }
  Check(TargetPassenger!=None && TargetPassenger.Class==class'ONSAttackCraftGun' && TargetPassenger.ProjectileClass==class'ONSAttackCraftGun'.default.ProjectileClass,"ordinary passenger replacement behavior preserved");
  Check(VSize(W.RelativeLocation-vect(12,-6,24))<0.1,"ordinary mount translation reached client phase=" $ Phase);
  Check(W.RelativeRotation.Yaw==4096,"ordinary mount rotation reached client phase=" $ Phase);
  Check(Abs(W.DrawScale-ExpectedScale)<0.001,"ordinary mount scale reached client phase=" $ Phase);
 }
 else
 {
  CW=CustomVehicleWeapon(W);
  Check(CW!=None,"variant custom weapon reached client");
  if(CW!=None)
  {
   Check(CW.bSetupReady && CW.AppearanceClass==class'ONSAttackCraftGun' && CW.Mesh==class'ONSAttackCraftGun'.default.Mesh,"selected gun mesh and ready flag reached client");
   Check(CW.ProjectileClass==class'XWeapons.FlakShell' && CW.AltFireProjectileClass==class'XWeapons.RocketProj',"both custom projectile classes reached client");
   Check(Abs(CW.FireInterval-0.60)<0.001 && Abs(CW.AltFireInterval-0.90)<0.001,"both custom fire intervals reached client");
   Check(CW.WeaponFireAttachmentBone==class'ONSAttackCraftGun'.default.WeaponFireAttachmentBone && CW.WeaponFireOffset==class'ONSAttackCraftGun'.default.WeaponFireOffset,"selected muzzle reached client");
  }
  Check(VSize(W.RelativeLocation-vect(12,-6,24))<0.1,"variant mount translation reached client");
  Check(W.RelativeRotation.Yaw==4096,"variant mount rotation reached client");
  Check(Abs(W.DrawScale-ExpectedScale)<0.001,"variant mount scale reached client");
 }
 Log("[MotorworksNetworkClient] observed health=" $ Target.Health $ " max=" $ Target.HealthMax $ " weapon=" $ W.Class);
 Report(Phase,Checks,Failures);
}
defaultproperties
{
 bAlwaysRelevant=True
 RemoteRole=ROLE_SimulatedProxy
 NetUpdateFrequency=5
}
