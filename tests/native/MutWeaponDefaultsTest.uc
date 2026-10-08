class MutWeaponDefaultsTest extends MutWeaponWorkflowTest;
var bool bRestoreClicked,bDropdownCaptured,bDropdownCue;
var VehicleStuffFix.VehicleProperties MarkerSavedProfile;
var int MarkerCaptureWait;
function CheckSelectionDefaults()
{
 local VehicleStuffFix.VehicleProperties Saved,VP;
 local VehicleStuffFix T;
 local ONSHoverTank V;
 local ONSManualGunPawn N;
 local string S[2];local float F[2];
 local int HiddenIndex;local bool bTurretsExcluded;local GUIList VehicleList;
 Saved=Editor.GetCurrentVP();
 VehicleList=GUIListBox(Editor.Controls[4]).List;bTurretsExcluded=True;
 for(HiddenIndex=0;HiddenIndex<VehicleList.ItemCount;HiddenIndex++)
  if(InStr(VehicleList.GetItemAtIndex(HiddenIndex), "Onslaught stationary turret")>=0
    || InStr(VehicleList.GetItemAtIndex(HiddenIndex), "Stationary minigun turret")>=0) bTurretsExcluded=False;
 Check(bTurretsExcluded,"both stationary turret classes are absent from tuning list");
 Check(VehicleList.ItemCount>0,"ordinary vehicles remain available for tuning");
 Editor.PlayerOwner().ConsoleCommand("shot");
 Editor.RestoreVehicleDefaults(Editor.CurrentIndex);
 Check(!Editor.VehicleIsModified(Editor.CurrentIndex),"default tuning has no marker after temporary reset state is lost");
 VP=Editor.GetCurrentVP();VP.ProfileId=17;VP.VehicleName="Retained variant name";Editor.SetCurrentVP(VP);
 Check(!Editor.VehicleIsModified(Editor.CurrentIndex),"default named variant has no marker after reopening");
 VP.SpeedScale=2;Editor.SetCurrentVP(VP);
 Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"editing restored variant still produces unsaved marker");
 Editor.SetCurrentVP(Saved);
 Check(Editor.WeapTab.Controls.Length==18,"original appearance controls are removed");
 Check(moComboBox(Editor.WeapTab.Controls[0]).MyComboBox.List.GetItemAtIndex(0)=="Default: ONSHoverTankCannon","per-mount stock weapon is the first named Default choice");
 Check(Editor.WeapTab.P[1].PClass=="None" && Editor.WeapTab.P[2].PClass=="@Separator","None and non-weapon divider precede other guns");
 S[0]="XWeapons.FlakShell";F[0]=0.8;Editor.SetCustomWeapon(S,F,0);
 moComboBox(Editor.WeapTab.Controls[0]).SetIndex(1);
 Check(Editor.GetCurrentVP().DWeapons[0].WeaponClass=="None" && !Editor.CanCustomizeProjectiles(0),"dropdown None commits removal and disables Edit");
 Check(Editor.MainTab.WeaponPreviewVisible[0]==0 && Editor.MountTab.WeaponPreviewVisible[0]==0,"None removes driver gun from both preview tabs");
 moComboBox(Editor.WeapTab.Controls[0]).SetIndex(2);
 Check(Editor.GetCurrentVP().DWeapons[0].WeaponClass=="None","divider cannot change the selected weapon");
 moComboBox(Editor.WeapTab.Controls[0]).SetIndex(0);
 Check(Editor.GetCurrentVP().DWeapons[0].WeaponClass=="Onslaught.ONSHoverTankCannon" && !Editor.GetCurrentVP().DWeapons[0].bCustomProjectiles,"Default resolves to this vehicle stock gun without previous overrides");
 Editor.SetCustomWeapon(S,F,0);Editor.SetWeaponClass("Onslaught.ONSAttackCraftGun",0);
 Check(!Editor.GetCurrentVP().DWeapons[0].bCustomProjectiles && Editor.GetCurrentVP().DWeapons[0].Mode[0]=="" && Editor.GetCurrentVP().DWeapons[0].Rate[0]==0,"changing gun clears previous projectile and interval settings");
 Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]);Dialog=VSCustomWeaponGUI(Editor.Controller.TopPage());
 Check(Dialog.P[moComboBox(Dialog.Controls[1]).GetIndex()].PClass==String(class'ONSAttackCraftGun'.default.ProjectileClass),"Edit starts from newly chosen gun default projectile");
 Check(float(moEditBox(Dialog.Controls[3]).GetText())==class'ONSAttackCraftGun'.default.FireInterval,"Edit starts from newly chosen gun default interval");Dialog.CancelWindow(None);
 foreach DynamicActors(class'VehicleStuffFix',T)break;
 VP=Saved;VP.DWeapons[0].WeaponClass="None";VP.PWeapons[0].WeaponClass="None";
 T.SetLiveProfile(0,VP);V=Spawn(class'ONSHoverTank',,,vect(0,0,5000));T.ChangeVehicleProps(V,0);
 Check(V.Weapons[0]==None && V.DriverWeapons[0].WeaponClass==None,"runtime None removes driver gun actor and class");
 Check(V.WeaponPawns[0].Gun==None && V.WeaponPawns[0].GunClass==None,"runtime None removes passenger gun actor and class");
 T.SetLiveProfile(0,Saved);T.ChangeVehicleProps(V,0);Check(V.Weapons[0]!=None && V.WeaponPawns[0].Gun!=None,"restoring selected guns recreates driver and passenger actors");V.Destroy();
 VP.VehicleClass="Onslaught.ONSManualGunPawn";T.SetLiveProfile(0,VP);N=Spawn(class'ONSManualGunPawn',,,vect(0,0,6000));T.ChangeVehicleProps(N,0);
 Check(N.Gun==None && N.GunClass==None,"runtime None removes integrated stationary gun");N.Destroy();
 Editor.SetCurrentVP(Saved);Editor.UpdateDisplay();

}
function CueDropdown()
{
 local FileLog F;local GUIComponent Target;
 Target=moComboBox(Editor.WeapTab.Controls[0]).MyComboBox.Edit;
 F=Spawn(class'FileLog');F.OpenLog("CustomProjectileInput-Dropdown",,true);
 F.Logf("CLICK" @ int(Target.ActualLeft()+Target.ActualWidth()*0.5) @ int(Target.ActualTop()+Target.ActualHeight()*0.5) @ int(Target.Controller.MouseX) @ int(Target.Controller.MouseY));
 F.CloseLog();F.Destroy();
}
function Timer()
{
 local int Before;
 local PlayerController MarkerPC;
 if(!bVerifyReload && Stage==13)
 {
  if(MarkerCaptureWait++<2)return;
  Editor.PlayerOwner().ConsoleCommand("shot");
  Editor.SetCurrentVP(MarkerSavedProfile);Editor.SaveAndClose(None);
  foreach DynamicActors(class'PlayerController',MarkerPC)if(MarkerPC.Player!=None)break;
  Stage=14;Finish(MarkerPC);return;
 }
 if(!bVerifyReload && Stage==3 && !bRestoreClicked)
 {
  Check(Dialog.Controls[9].ActualTop()+Dialog.Controls[9].ActualHeight()+8<Dialog.Controls[5].ActualTop(),"Restore Defaults has a visible gap above Done");
  Check(VSActionButton(Dialog.Controls[9]).ActionTone==3,"Restore Defaults uses amber fill and white action text");
  CueButton(Dialog.Controls[9]);bRestoreClicked=True;return;
 }
 if(!bVerifyReload && Stage==3 && bRestoreClicked)
 {
  Check(Dialog.P[moComboBox(Dialog.Controls[1]).GetIndex()].PClass==String(class'ONSAttackCraftGun'.default.ProjectileClass),"physical Restore Defaults restores selected gun projectile");
  Check(float(moEditBox(Dialog.Controls[3]).GetText())==class'ONSAttackCraftGun'.default.FireInterval,"physical Restore Defaults restores selected gun interval");
  Check(Editor.ProfilesEqual(BeforeDialog,Editor.GetCurrentVP()),"popup restore is staged and Cancel can discard it");
  SetFields("XWeapons.FlakShell","XWeapons.RocketProj","0.6","0.9");
 }
 if(!bVerifyReload && Stage==1 && !bDropdownCue)
 {
  Editor.SetWeaponClass(Editor.GetStockWeapon(0),0);
  Editor.WeapTab.SetCBPosition(Editor.GetStockWeapon(0),0);
  CueDropdown();bDropdownCue=True;return;
 }
 if(!bVerifyReload && Stage==1 && !bDropdownCaptured)
 {
  Check(moComboBox(Editor.WeapTab.Controls[0]).MyComboBox.MyListBox.bVisible,"physical click opens named Default and None dropdown");
  Editor.PlayerOwner().ConsoleCommand("shot");bDropdownCaptured=True;return;
 }
 if(!bVerifyReload && Stage==1)
 {
  moComboBox(Editor.WeapTab.Controls[0]).MyComboBox.HideListBox();
  Editor.SetCurrentVP(BeforeDialog);Editor.UpdateDisplay();
 }
 Before=Stage;Super.Timer();
 if(!bVerifyReload && Before==0 && Stage==1)CheckSelectionDefaults();
}

function Finish(PlayerController PC)
{
 local VehicleStuffFix.VehicleProperties BeforeReset;
 local GUIController Menus;
 Menus=GUIController(PC.Player.GUIController);
 if(!bVerifyReload && Stage==12)
 {
  Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());Editor.SelectProfile(WorkflowKey);
  BeforeReset=Editor.GetCurrentVP();
  Editor.TabRestoreAllDefaults(None);Editor.SaveWithoutClosing(None);Editor.CancelAndClose(None);
  Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());Editor.SelectProfile(WorkflowKey);
  Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==0,"Restore All then Save and Cancel stays unmarked after reopening");
  Editor.TabRestoreAllDefaults(None);Editor.CancelAndClose(None);
  Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());Editor.SelectProfile(WorkflowKey);
  Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==0,"Restore All then Cancel stays unmarked when saved tuning is already default");
  MarkerSavedProfile=BeforeReset;Editor.UpdateDisplay();Stage=13;return;
 }
 Super.Finish(PC);
}
