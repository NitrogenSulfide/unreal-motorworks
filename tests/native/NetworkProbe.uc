class NetworkProbe extends Info;
var ONSVehicle Target;
var ONSWeapon TargetWeapon;
var int Phase, ExpectedHealth, ExpectedMax, ReceivedPhase, Checks, Failures, WaitTicks;
var float ExpectedScale;
var VSIGGUI Editor;
var int SaveStage;
var GUIController Menus;
var MutMotorworksNetworkTest Harness;
replication
{
 reliable if(Role==ROLE_Authority) Target, TargetWeapon, Phase, ExpectedHealth, ExpectedMax, ExpectedScale;
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
   PC.ClientOpenMenu("VehicleStuffFix.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());
   Editor.SelectProfile("Onslaught.ONSHoverTank");
   Editor.HealthChange(2345);Editor.SaveWithoutClosing(None);
   Check(Editor.bSendingSave && Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"remote Save remains unsaved until server acknowledgment");
   Check(!Editor.SaveWithoutClosing(None),"remote Save prevents overlapping transfers");
   Editor.HealthChange(3456);SaveStage=1;return;
  }
  if(Phase==3 && SaveStage==1 && !Editor.bSendingSave)
  {
   Check(GUIButton(Editor.Controls[19]).Caption=="Save","remote Save received server acknowledgment");
   Check(Editor.GetCurrentVP().Health==3456 && Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"edit made while sending remains red after acknowledgment");
   Editor.CancelAndClose(None);PC.ClientOpenMenu("VehicleStuffFix.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");
   Check(Editor.GetCurrentVP().Health==2345,"Cancel preserves only the acknowledged remote snapshot");
   Check(Editor.GetCurrentVP().VehicleName=="Network save tank","remote snapshot preserves spaces in the vehicle name");
   Editor.CancelAndClose(None);SaveStage=2;Report(3,Checks,Failures);return;
  }
  if(Phase==4 && SaveStage==2)
  {
   PC.ClientOpenMenu("VehicleStuffFix.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");
   Editor.HealthChange(4567);Editor.SaveWithoutClosing(None);SaveStage=3;return;
  }
  if(Phase==4 && SaveStage==3 && !Editor.bSendingSave)
  {
   Check(GUIButton(Editor.Controls[19]).Caption=="Retry Save","rejected remote Save reports missing acknowledgment");
   Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"rejected remote Save does not advance baseline");
   Editor.CancelAndClose(None);PC.ClientOpenMenu("VehicleStuffFix.VSIGGUI");Editor=VSIGGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");
   Check(Editor.GetCurrentVP().Health==2345,"Cancel after rejected Save retains previously acknowledged settings");
   Editor.CancelAndClose(None);SaveStage=4;Report(4,Checks,Failures);return;
  }
  return;
 }
 if(Phase==5)
 {
  WaitTicks++; if(WaitTicks<6) return;
  Log("[MotorworksNetworkClient] RESULT checks=" $ Checks $ " failures=" $ Failures);
  foreach DynamicActors(class'PlayerController',PC)
   if(PC.Player!=None) { PC.ConsoleCommand("exit"); return; }
 }
 if(Phase<=ReceivedPhase || Target==None) return;
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
 else
 {
  CW=CustomVehicleWeapon(W);
  Check(CW!=None,"variant custom weapon reached client");
  if(CW!=None)
  {
   Check(CW.bSetupReady && CW.AppearanceClass==class'ONSHoverTankCannon' && CW.Mesh==class'ONSHoverTankCannon'.default.Mesh,"original gun mesh and ready flag reached client");
   Check(CW.ProjectileClass==class'XWeapons.FlakShell' && CW.AltFireProjectileClass==class'XWeapons.RocketProj',"both custom projectile classes reached client");
   Check(Abs(CW.FireInterval-0.60)<0.001 && Abs(CW.AltFireInterval-0.90)<0.001,"both custom fire intervals reached client");
   Check(CW.WeaponFireAttachmentBone==class'ONSHoverTankCannon'.default.WeaponFireAttachmentBone && CW.WeaponFireOffset==class'ONSHoverTankCannon'.default.WeaponFireOffset,"original muzzle reached client");
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
