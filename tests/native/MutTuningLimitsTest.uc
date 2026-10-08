// Native boundary, real keyboard, runtime and separate-process persistence tests.
class MutTuningLimitsTest extends MutCustomProjectileTest;
function KeyboardCue(GUIComponent Target, string Value)
{
 local FileLog F;
 Target.SetFocus(None);
 F=Spawn(class'FileLog');F.OpenLog("CustomProjectileInput-Limits" $ Stage,,true);
 F.Logf("KEYTYPE" @ int(Target.ActualLeft()+Target.ActualWidth()*0.5) @ int(Target.ActualTop()+Target.ActualHeight()*0.5) @ int(Target.Controller.MouseX) @ int(Target.Controller.MouseY) @ Value);
 F.CloseLog();F.Destroy();
}
function CheckProfile(VehicleStuffFix.VehicleProperties VP, string Prefix)
{
 Check(VP.SpeedScale==5 && VP.Friction==5 && VP.Mass==5 && VP.WheelScale==3 && VP.JumpHeight==3 && VP.HoverHeight==2,Prefix $ " retains all six maxima");
 Check(VP.Health==1000000 && VP.bRandomHealth,Prefix $ " retains million HP random-health base");
 Check(VP.ProfileId>0 && VP.VehicleName=="Tuning limits regression" && VP.DWeapons[0].WeaponClass=="Onslaught.ONSHoverTankCannon",Prefix $ " preserves variant identity and weapon");
}
function RuntimeLimits()
{
 local LimitsRawTuner T;local VehicleStuffFix.VehicleProperties VP,Original;
 local ONSRV Car;local ONSHoverBike Bike;
 local int i;
 T=Spawn(class'LimitsRawTuner');
 Check(T!=None,"standalone live tuner exists");if(T==None)return;
 Original=class'VehicleStuffFix'.static.GetDefaultProfile(0);
 VP=Original;VP.Health=2147483647;VP.SpeedScale=99;VP.Friction=99;VP.Mass=99;VP.WheelScale=99;VP.JumpHeight=99;VP.HoverHeight=99;
 VP.bRandomHealth=false;
 // Bypass editor/save guards to represent an old, oversized configuration.
 T.SetRaw(VP);
 Car=Spawn(class'ONSRV',,,vect(17000,17000,3000));
 Bike=Spawn(class'ONSHoverBike',,,vect(16000,17000,3000));
 Check(Car!=None && Bike!=None,"isolated physics vehicles spawn");
 if(Car!=None)
 {
  T.ChangeVehicleProps(Car,0);
  Check(Abs(Car.TorqueCurve.Points[0].OutVal-Car.default.TorqueCurve.Points[0].OutVal*5)<0.1,"runtime caps legacy wheel propulsion");
  Check(Car.WheelLongFrictionScale==5 && Car.WheelLatFrictionScale==5,"runtime caps legacy friction");
  Check(Abs(Car.MomentumMult-Car.default.MomentumMult/5)<0.001,"runtime caps legacy momentum response");
  Check(Car.MaxJumpForce==600000,"runtime caps legacy wheel jump force");
  Check(Car.Health==1000000 && Car.HealthMax==1000000,"runtime caps fixed health and health maximum");
  Car.Destroy();
 }
 if(Bike!=None)
 {
  T.ChangeVehicleProps(Bike,0);
  Check(Abs(Bike.MaxThrustForce-Bike.default.MaxThrustForce*5)<0.1,"runtime caps legacy hover propulsion");
  Check(Abs(Bike.HoverCheckDist-Bike.default.HoverCheckDist*2)<0.1,"runtime caps legacy hover distance");
  Check(Abs(Bike.JumpForceMag-Bike.default.JumpForceMag*3)<0.1,"runtime caps legacy hover jump force");Bike.Destroy();
 }
 VP.bRandomHealth=true;VP.HealthMin=0.1;VP.HealthMax=3;
 Check(class'VehicleStuffFix'.static.RollHealth(VP,1)==1000000,"random multiplier cannot exceed million HP");
 for(i=0;i<20;i++) Check(class'VehicleStuffFix'.static.RollHealth(VP,float(i)/19)<=1000000,"random sample stays capped");
 VP=Original;VP.SpeedScale=0.75;VP.Friction=0;VP.Mass=-1;
 VP=class'VehicleStuffFix'.static.CapTuningProfile(VP);
 Check(VP.SpeedScale==0.75 && VP.Friction==0 && VP.Mass==-1,"normal fractions and legacy nonpositive stock sentinels are preserved");
 Check(class'VehicleStuffFix'.static.TuningHealthFromText("999999999999999999999999999999999999")==1000000,"long health text saturates without integer overflow");
 Check(class'VehicleStuffFix'.static.TuningHealthFromText("-1")==0 && class'VehicleStuffFix'.static.TuningHealthFromText("1x")==0,"invalid health text is rejected");
 T.Destroy();
}
function Timer()
{
 local PlayerController PC;local GUIController Menus;
 local VehicleStuffFix.VehicleProperties VP;
 local int i;
 foreach DynamicActors(class'PlayerController',PC) if(PC.Player!=None)break;
 if(PC==None || PC.Player==None)return;
 Menus=GUIController(PC.Player.GUIController);
 if(Stage==0)
 {
  PC.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox");PC.ClientOpenMenu("UnrealMotorworks.VehicleSuiteConfig");
  Hub=VehicleSuiteConfig(Menus.TopPage());Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());
  if(bVerifyReload)
  {
   for(i=0;i<Editor.VPsLength;i++)
   { VP=class'VehicleStuffFix'.static.GetDefaultProfile(i);if(VP.VehicleName=="Tuning limits regression")break; }
   Check(i<Editor.VPsLength,"saved variant exists after process restart");
   if(i>=Editor.VPsLength){Finish(PC);return;}
   Editor.SelectProfile(class'VehicleStuffFix'.static.ProfileKey(VP));CheckProfile(Editor.GetCurrentVP(),"restarted editor");
   Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==1,"restarted variant shows saved green marker");PC.ConsoleCommand("shot");
  }
  else
  {
   RuntimeLimits();Editor.SelectProfile("Onslaught.ONSHoverTank");Editor.DuplicateVehicle(None);
   VP=Editor.GetCurrentVP();VP.VehicleName="Tuning limits regression";Editor.SetCurrentVP(VP);
   GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MainTab,true);
   KeyboardCue(moEditBox(Editor.MainTab.Controls[0]).MyEditBox,"9.9");
  }
 }
 else if(bVerifyReload) {Finish(PC);return;}
 else if(Stage==1)
 {
  Check(Editor.GetCurrentVP().SpeedScale==5 && float(moEditBox(Editor.MainTab.Controls[0]).GetText())==5,"physical decimal typing caps speed without losing subsequent digits");
  KeyboardCue(moEditBox(Editor.MainTab.Controls[0]).MyEditBox,"0.75");
 }
 else if(Stage==2)
 {
  Check(Abs(Editor.GetCurrentVP().SpeedScale-0.75)<0.001,"physical fractional input below cap stays unchanged");
  KeyboardCue(moEditBox(Editor.MainTab.Controls[6]).MyEditBox,"999999999999999999");
 }
 else if(Stage==3)
 {
  Check(Editor.GetCurrentVP().Health==1000000 && moEditBox(Editor.MainTab.Controls[6]).GetText()=="1000000","physical long main health input remains capped after every digit");
  for(i=0;i<6;i++)moEditBox(Editor.MainTab.Controls[i]).SetText("99");
  VP=Editor.GetCurrentVP();Check(VP.SpeedScale==5 && VP.Friction==5 && VP.Mass==5 && VP.WheelScale==3 && VP.JumpHeight==3 && VP.HoverHeight==2,"all six editor handlers enforce limits");
  PC.ConsoleCommand("shot");
 }
 else if(Stage==4)
 {
  Editor.OpenAdvancedHealth(None);KeyboardCue(moEditBox(Editor.HealthTab.Controls[6]).MyEditBox,"999999999999999999");
 }
 else if(Stage==5)
 {
  Check(Editor.GetCurrentVP().Health==1000000 && moEditBox(Editor.HealthTab.Controls[6]).GetText()=="1000000" && moEditBox(Editor.MainTab.Controls[6]).GetText()=="1000000","physical Advanced health entry caps and synchronizes both fields");
  moCheckBox(Editor.HealthTab.Controls[1]).SetComponentValue("True",true);
  moSlider(Editor.HealthTab.Controls[2]).SetComponentValue("0.1",true);moSlider(Editor.HealthTab.Controls[3]).SetComponentValue("3",true);
  Editor.HealthTab.HealthChanged(Editor.HealthTab.Controls[3]);
  Check(InStr(GUILabel(Editor.HealthTab.Controls[4]).Caption,"to 1000000 HP")>=0,"Advanced summary reports capped random-health upper end");
  PC.ConsoleCommand("shot");
 }
 else if(Stage==6)
 {
  Editor.HealthTab.CloseWindow(None);
  // Programmatic updates bypass field handlers and must obey the same caps.
  VP=Editor.GetCurrentVP();VP.SpeedScale=99;VP.Health=2147483647;Editor.SetCurrentVP(VP);
  Editor.SaveWithoutClosing(None);CheckProfile(Editor.GetCurrentVP(),"Save");
  Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==1,"bounded Save establishes green baseline");
  Editor.CancelAndClose(None);Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());
  for(i=0;i<Editor.VPsLength;i++)
   { VP=class'VehicleStuffFix'.static.GetDefaultProfile(i);if(VP.VehicleName=="Tuning limits regression")break; }
  Editor.SelectProfile(class'VehicleStuffFix'.static.ProfileKey(VP));CheckProfile(Editor.GetCurrentVP(),"reopened editor");
  PC.ConsoleCommand("shot");
 }
 else {Finish(PC);return;}
 Stage++;
}
defaultproperties
{
 bVerifyReload=False
}
