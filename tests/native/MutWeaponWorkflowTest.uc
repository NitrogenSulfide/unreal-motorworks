class MutWeaponWorkflowTest extends MutCustomProjectileTest;
var VehicleStuffFix.VehicleProperties BeforeDialog;
var string WorkflowKey;
var int BeforeMarker, BeforeMountYaw;
var ONSManualGunPawn WorkflowNode;
var VehicleStuffFix WorkflowTuner;
var VehicleStuffFix.VehicleProperties NodeVP;
event PreBeginPlay()
{
 local VehicleStuffFix.VehicleProperties Legacy, Migrated;
 if(!bVerifyReload)
 {
  Legacy=class'VehicleStuffFix'.static.GetDefaultProfile(0);
  Check(Legacy.DWeapons[0].WeaponClass=="Custom" && !Legacy.DWeapons[0].bCustomProjectiles,"actual old config loads without the new flag");
  Migrated=class'VehicleStuffFix'.static.CapTuningProfile(Legacy);
  Check(Migrated.DWeapons[0].bCustomProjectiles && Migrated.DWeapons[0].WeaponClass=="Onslaught.ONSHoverTankCannon","legacy Custom migrates to stock gun plus projectile flag");
  Check(Migrated.DWeapons[0].Mode[0]=="XWeapons.FlakShell" && Migrated.DWeapons[0].Rate[0]==0.6 && Migrated.ProfileId==7,"migration retains projectile, rate and profile identity");
 }
 Super.PreBeginPlay();
}
function CueButton(GUIComponent Target)
{
 local FileLog F;
 F=Spawn(class'FileLog');F.OpenLog("CustomProjectileInput-Workflow" $ Stage,,true);
 F.Logf("CLICK" @ int(Target.ActualLeft()+Target.ActualWidth()*0.5) @ int(Target.ActualTop()+Target.ActualHeight()*0.5) @ int(Target.Controller.MouseX) @ int(Target.Controller.MouseY));
 F.CloseLog();F.Destroy();
}
function UseGunDefaults(class<ONSWeapon> Gun)
{
 local string Primary,Alternate;
 if(Gun.default.ProjectileClass!=None)Primary=String(Gun.default.ProjectileClass);
 if(Gun.default.AltFireProjectileClass!=None)Alternate=String(Gun.default.AltFireProjectileClass);
 SetFields(Primary,Alternate,String(Gun.default.FireInterval),String(Gun.default.AltFireInterval));
}
function CheckSettings(VehicleStuffFix.VehicleProperties VP,string Prefix)
{
 Super.CheckSettings(VP,Prefix);
 Check(VP.DWeapons[0].WeaponClass=="Onslaught.ONSAttackCraftGun",Prefix $ " retains selected Raptor gun independently of projectiles");
}
function FireAndCheck(CustomVehicleWeapon Gun,PlayerController PC,bool Alternate,class<Projectile> Expected)
{
 Super.FireAndCheck(Gun,PC,Alternate,Expected);
 if(Gun==None)return;
 if(ONSWeaponPawn(Gun.Owner)==None)
 {
  Check(Gun.AppearanceClass==class'ONSAttackCraftGun' && Gun.Mesh==class'ONSAttackCraftGun'.default.Mesh,"runtime custom driver uses selected gun model");
  Check(Gun.WeaponFireAttachmentBone==class'ONSAttackCraftGun'.default.WeaponFireAttachmentBone && Gun.WeaponFireOffset==class'ONSAttackCraftGun'.default.WeaponFireOffset,"runtime custom driver uses selected gun muzzle");
 }
}
function Finish(PlayerController PC)
{
 if(!bVerifyReload || Stage!=1) {Super.Finish(PC);Return;}
 foreach DynamicActors(class'VehicleStuffFix',WorkflowTuner) break;
 NodeVP.VehicleClass="Onslaught.ONSManualGunPawn";NodeVP.VehicleName="Workflow node turret";
 NodeVP.Health=600;NodeVP.SpeedScale=1;NodeVP.Friction=1;NodeVP.Mass=1;NodeVP.WheelScale=1;NodeVP.JumpHeight=1;NodeVP.HoverHeight=1;
 NodeVP.DWeapons[0].WeaponClass="Onslaught.ONSAttackCraftGun";NodeVP.DWeapons[0].bCustomProjectiles=true;
 NodeVP.DWeapons[0].Mode[0]="XWeapons.FlakShell";NodeVP.DWeapons[0].Rate[0]=0.7;
 WorkflowTuner.SetLiveProfile(0,NodeVP);WorkflowNode=Spawn(class'ONSManualGunPawn',,,Tank.Location+vect(0,0,1000));
 Check(WorkflowNode!=None,"stationary custom projectile test turret spawns");
 if(WorkflowNode!=None) WorkflowTuner.ChangeVehicleProps(WorkflowNode,0);
}
function VerifyStationary(PlayerController PC)
{
 local CustomVehicleWeapon Gun;
 if(WorkflowNode==None) {Super.Finish(PC);Return;}
 Gun=CustomVehicleWeapon(WorkflowNode.Gun);
 Check(Gun!=None && Gun.bSetupReady,"stationary custom projectile setup initializes");
 if(Gun!=None)
 {
  Check(Gun.AppearanceClass==class'ONSAttackCraftGun' && Gun.Mesh==class'ONSAttackCraftGun'.default.Mesh,"stationary custom projectiles retain selected gun appearance");
  if(Stage==2)
  {
   Check(Gun.ProjectileClass==class'FlakShell' && Abs(Gun.FireInterval-0.7)<0.001,"stationary custom projectile and interval apply");
   FireAndCheck(Gun,PC,false,class'FlakShell');
   NodeVP.DWeapons[0].Mode[0]="XWeapons.RocketProj";NodeVP.DWeapons[0].Rate[0]=0.8;
   WorkflowTuner.SetLiveProfile(0,NodeVP);WorkflowTuner.ChangeVehicleProps(WorkflowNode,0);Stage++;Return;
  }
  Check(Gun.ProjectileClass==class'RocketProj' && Abs(Gun.FireInterval-0.8)<0.001,"stationary edit refreshes existing custom setup");
 }
 NodeVP.DWeapons[0].bCustomProjectiles=false;WorkflowTuner.SetLiveProfile(0,NodeVP);WorkflowTuner.ChangeVehicleProps(WorkflowNode,0);
 Check(WorkflowNode.Gun.Class==class'ONSAttackCraftGun' && WorkflowNode.Gun.ProjectileClass==class'ONSAttackCraftGun'.default.ProjectileClass,"stationary custom off restores selected gun ordinary behavior");
 Super.Finish(PC);
}
function Timer()
{
 local PlayerController PC;local GUIController Menus;
 local int i;local WoRM_vCfgFix Pool;
 foreach DynamicActors(class'PlayerController',PC)if(PC.Player!=None)break;
 if(PC==None || PC.Player==None)return;
 if(bVerifyReload){if(Stage>=2)VerifyStationary(PC);else Super.VerifyReload(PC);return;}
 Menus=GUIController(PC.Player.GUIController);
 if(Stage==0)
 {
  Super.Timer();
  Editor.SetWeaponClass("Onslaught.ONSAttackCraftGun",0);Editor.UpdateDisplay();
  BeforeDialog=Editor.GetCurrentVP();BeforeMarker=Editor.VehicleMarkerState(Editor.CurrentIndex);
  WorkflowKey=class'VehicleStuffFix'.static.ProfileKey(BeforeDialog);
  Check(Editor.WeapTab.Controls.Length==24,"weapons rows contain no custom projectile checkboxes");
  Check(Editor.MountTab.bSpinPreview && moCheckBox(Editor.MountTab.Controls[20]).IsChecked(),"Placement auto-rotate starts on with synchronized checkbox");
  Check(Editor.WeapTab.P[1].PClass!="Custom","weapon dropdown contains guns instead of a Custom mode");
  return;
 }
 else if(Stage==1) {PC.ConsoleCommand("shot");CueButton(Editor.WeapTab.Controls[6]);}
 else if(Stage==2)
 {
  Dialog=VSCustomWeaponGUI(Menus.TopPage());Check(Dialog!=None && Dialog.bInitialized,"actual Edit button opens initialized projectile draft");
  if(Dialog==None){Finish(PC);return;}
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"opening popup does not change selected gun or flags");
  Check(Dialog.P[moComboBox(Dialog.Controls[1]).GetIndex()].PClass==String(class'ONSAttackCraftGun'.default.ProjectileClass),"new draft starts with selected gun's primary projectile");
  Check(Abs(float(moEditBox(Dialog.Controls[3]).GetText())-class'ONSAttackCraftGun'.default.FireInterval)<0.001,"new draft starts with selected gun's interval");
  SetFields("XWeapons.FlakShell","XWeapons.RocketProj","0.6","0.9");
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"projectile and rate edits remain staged until Done");
  Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==BeforeMarker,"draft edits do not alter parent marker");
 }
 else if(Stage==3)
 {
  Check(Dialog.Controls[7].ActualLeft()+Dialog.Controls[7].ActualWidth()+10<Dialog.Controls[5].ActualLeft(),"Cancel is left of Done with a visible gutter");
  Check(GUIButton(Dialog.Controls[7]).Caption=="Cancel" && GUIButton(Dialog.Controls[5]).Caption=="Done","dialog action labels are correct");
  PC.ConsoleCommand("shot");
 }
 else if(Stage==4) CueButton(Dialog.Controls[7]);
 else if(Stage==5)
 {
  Check(Menus.TopPage()==Editor,"actual Cancel returns to tuning page");
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"Cancel preserves whole profile including prior unsaved work");
  CueButton(Editor.WeapTab.Controls[6]);
 }
 else if(Stage==6)
 {
  Dialog=VSCustomWeaponGUI(Menus.TopPage());
  Check(Dialog!=None && Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"actual Edit opens without enabling overrides or replacing the gun");
  SetFields("XWeapons.FlakShell","XWeapons.RocketProj","0.6","0.9");
 }
 else if(Stage==7){PC.ConsoleCommand("shot");}
 else if(Stage==8)CueButton(Dialog.Controls[5]);
 else if(Stage==9)
 {
  Check(Menus.TopPage()==Editor,"actual Done returns to tuning page");CheckSettings(Editor.GetCurrentVP(),"Done");
  GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MainTab,true);
  Check(Editor.MainTab.PreviewWeapons[0].Mesh==class'ONSAttackCraftGun'.default.Mesh,"tuning preview shows selected gun with custom projectiles");
  Editor.SetOriginalGunAppearance(0,true);
  Check(Editor.MainTab.PreviewWeapons[0].Mesh==class'ONSHoverTankCannon'.default.Mesh,"original appearance overrides only the model");
  Editor.SetOriginalGunAppearance(0,false);
  Check(Editor.MainTab.PreviewWeapons[0].Mesh==class'ONSAttackCraftGun'.default.Mesh,"disabling original appearance restores selected gun model");
  GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab,true);
  BeforeMountYaw=Editor.MountTab.PreviewYaw;
 }
 else if(Stage==10)
 {
  Check(Editor.MountTab.PreviewYaw!=BeforeMountYaw,"Placement auto-rotate visibly advances the preview yaw");
  PC.ConsoleCommand("shot");CueButton(moCheckBox(Editor.MountTab.Controls[20]).MyCheckBox);
 }
 else if(Stage==11)
 {
  Check(!Editor.MountTab.bSpinPreview && !moCheckBox(Editor.MountTab.Controls[20]).IsChecked(),"physical Placement checkbox turns auto-rotate off");
  GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab,true);
  BeforeDialog=Editor.GetCurrentVP();
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]);Dialog=VSCustomWeaponGUI(Menus.TopPage());Dialog.CloseWindow(None);
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"unchanged Done preserves exact saved custom fields");
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]);Dialog=VSCustomWeaponGUI(Menus.TopPage());
  UseGunDefaults(class'ONSAttackCraftGun');Dialog.CloseWindow(None);
  Check(!Editor.GetCurrentVP().DWeapons[0].bCustomProjectiles && !Editor.FiringModified(Editor.GetCurrentVP().DWeapons[0]),"matching selected gun defaults restores native firing without a checkbox");
  BeforeDialog=Editor.GetCurrentVP();
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]);Dialog=VSCustomWeaponGUI(Menus.TopPage());Dialog.CloseWindow(None);
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"unchanged Done on native defaults does not create an override");
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]);Dialog=VSCustomWeaponGUI(Menus.TopPage());SetFields("XWeapons.FlakShell","XWeapons.RocketProj","0.6","0.9");Dialog.CloseWindow(None);
  Editor.SetCustomProjectilesEnabled(0,false);
  Check(!Editor.GetCurrentVP().DWeapons[0].bCustomProjectiles && Editor.GetCurrentVP().DWeapons[0].Mode[0]=="XWeapons.FlakShell","disabling custom firing retains dormant projectile choices");
  Editor.SetCustomProjectilesEnabled(0,true);
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]);Dialog=VSCustomWeaponGUI(Menus.TopPage());
  BeforeDialog=Editor.GetCurrentVP();SetFields("Onslaught.ONSHoverBikePlasmaProjectile","","1.4","0");
  // Generic window dismissal (including Escape) uses the same no-commit path.
  Menus.CloseMenu(true);
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"window dismissal discards draft changes too");
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[8]);Dialog=VSCustomWeaponGUI(Menus.TopPage());
  BeforeDialog=Editor.GetCurrentVP();SetFields("XWeapons.FlakShell","","0.7","0");Dialog.CancelWindow(None);
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"passenger Cancel preserves exact slot and driver setup");
  Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[8]);Dialog=VSCustomWeaponGUI(Menus.TopPage());SetFields("XWeapons.FlakShell","","0.7","0");Dialog.CloseWindow(None);
  Check(Editor.GetCurrentVP().PWeapons[0].bCustomProjectiles && Editor.GetCurrentVP().PWeapons[0].WeaponClass=="Onslaught.ONSTankSecondaryTurret","passenger Done retains passenger gun selection");
  Editor.SaveAndClose(None);
 }
 else if(Stage==12)
 {
  Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());Editor.SelectProfile(WorkflowKey);CheckSettings(Editor.GetCurrentVP(),"reopened editor");
  Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==1,"saved independent projectile setup is green");
  Editor.CancelAndClose(None);Hub.OpenMotorpool(None);Pool=WoRM_vCfgFix(Menus.TopPage());
  Pool.CurrentSlot=3;Pool.HighlightedVehicleClasses[3]=WorkflowKey;Pool.UpdateSelectedDetails();
  Check(Pool.PreviewWeapons[0].Mesh==class'ONSAttackCraftGun'.default.Mesh,"Motorpool variant preview retains selected gun with custom projectiles");
  Menus.CloseMenu(true);
  for(i=0;i<11;i++)if(class'MutWoRM_vFix'.default.ReplacedVehicleClass[i]==class'ONSHoverTank')
  {class'MutWoRM_vFix'.default.ReplacementPoolClassNames[i]=WorkflowKey;class'MutWoRM_vFix'.default.ReplacementStrategies[i]=0;}
  class'MutWoRM_vFix'.static.StaticSaveConfig();Finish(PC);return;
 }
 Stage++;
}
