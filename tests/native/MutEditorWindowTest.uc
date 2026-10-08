class MutEditorWindowTest extends Mutator;
var int Stage, Failures;
var string StackSnapshot;
var VehicleSuiteConfig Hub;
var WoRM_vCfgFix Pool;
var VSGUI Editor;
var string VariantKey;
var float OldPan;
var VSTabMain Pane;
function Check(bool OK,string Message) { if(OK)Log("[EditorWindow] PASS"@Message);else{Failures++;Log("[EditorWindow] FAIL"@Message);} }
function PostBeginPlay(){SetTimer(4,true);}
function Cue(string Action,VSTabMain P)
{
 local FileLog F;
 F=Spawn(class'FileLog');F.OpenLog("EditorWindowInput-"$Stage,,true);
 F.Logf(Action@int(P.PreviewViewLeft+P.PreviewViewWidth*0.5)@int(P.PreviewViewTop+P.PreviewViewHeight*0.5));F.CloseLog();F.Destroy();
}
function Timer()
{
 local PlayerController PC;local GUIController Menus;
 local VehicleStuffFix.VehicleWeaponProperties W;
 local int JournalCount;
 foreach DynamicActors(class'PlayerController',PC)if(PC.Player!=None)break;
 if(PC==None||PC.Player==None)return;Menus=GUIController(PC.Player.GUIController);
 if(Stage==0)
 {
  PC.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox");PC.ClientOpenMenu("VehicleSuite.VehicleSuiteConfig");Hub=VehicleSuiteConfig(Menus.TopPage());Hub.OpenMotorpool(None);Pool=WoRM_vCfgFix(Menus.TopPage());
  Pool.CurrentSlot=3;Pool.HighlightedVehicleClasses[3]="Onslaught.ONSHoverTank";Pool.UpdateSelectedDetails();Pool.OpenHighlightedTuning(None);Editor=VSGUI(Menus.TopPage());StackSnapshot=Menus.GetPropertyText("MenuStack");
  Pane=Editor.MainTab;Pane.bSpinPreview=false;
 }
 else if(Stage==1){OldPan=Pane.PreviewPanY;Cue("RPAN",Pane);}
 else if(Stage==2)
 {
  Check(Menus.TopPage()==Editor,"right pan keeps tuning on top");Check(Menus.GetPropertyText("MenuStack")==StackSnapshot,"right pan does not grow menu stack");Check(Pane.PreviewPanY!=OldPan,"right drag actually pans tuning preview");PC.ConsoleCommand("shot");
  // Recover only to continue diagnosis if the baseline pulled the parent forward.
  if(Menus.TopPage()!=Editor){PC.ClientOpenMenu("VehicleStuffFix.VSIGGUI");Editor=VSGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");StackSnapshot=Menus.GetPropertyText("MenuStack");}
  GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab,true);Pane=Editor.MountTab;Pane.bSpinPreview=false;
 }
 else if(Stage==3){OldPan=Pane.PreviewPanY;Cue("RPAN",Pane);}
 else if(Stage==4)
 {
  Check(Menus.TopPage()==Editor,"right pan keeps placement on top");Check(Menus.GetPropertyText("MenuStack")==StackSnapshot,"placement pan does not grow menu stack");Check(Pane.PreviewPanY!=OldPan,"right drag actually pans placement preview");PC.ConsoleCommand("shot");
  if(Menus.TopPage()!=Editor){PC.ClientOpenMenu("VehicleStuffFix.VSIGGUI");Editor=VSGUI(Menus.TopPage());Editor.SelectProfile("Onslaught.ONSHoverTank");}
  GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab,true);Editor.SetWeaponClass("Onslaught.ONSRVWebLauncher",0);Editor.WeapTab.SetCBPosition("Onslaught.ONSRVWebLauncher",0);
  Check(Editor.WeapTab.Controls[18].MenuState!=MSAT_Disabled,"normal replacement enables original appearance checkbox");
  moCheckBox(Editor.WeapTab.Controls[18]).SetComponentValue("True");
  W=Editor.GetVehicleWeapons(true,0);
  Check(W.WeaponClass=="Onslaught.ONSRVWebLauncher" && W.bUseOriginalAppearance,"checkbox enables appearance without changing selected weapon");GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab,true);
 }
 else if(Stage==5)
 {
  Check(Editor.MountTab.Controls[24].bVisible,"normal replacement shows enabled appearance warning");PC.ConsoleCommand("shot");
  moCheckBox(Editor.WeapTab.Controls[18]).SetComponentValue("False");
  W=Editor.GetVehicleWeapons(true,0);
  Check(W.WeaponClass=="Onslaught.ONSRVWebLauncher" && !W.bUseOriginalAppearance,"checkbox disables appearance without changing selected weapon");GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab,true);GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab,true);
 }
 else if(Stage==6)
 {
  Check(!Editor.MountTab.Controls[24].bVisible,"disabled appearance warning stays hidden after tab switches");PC.ConsoleCommand("shot");
  Editor.SelectProfile("Onslaught.ONSHoverTank");Editor.DuplicateVehicle(None);VariantKey=class'VehicleStuffFix'.static.ProfileKey(Editor.GetCurrentVP());Editor.SaveWithoutClosing(None);
  Pool.SelectedPoolTexts[3]="Onslaught.ONSHoverTank|"$VariantKey$"|Onslaught.ONSHoverBike";Pool.SaveWithoutClosing(None);
  Check(GUIButton(Editor.Controls[15]).Caption=="Delete Variant","variant delete caption is explicit");
  Pool.VehicleGroupPresets.Length=1;Pool.VehicleGroupPresets[0].SetName="Held deletion test";Pool.VehicleGroupPresets[0].PoolClassNames[3]=Pool.SelectedPoolTexts[3];
  class'MutWoRM_vFix'.default.VehicleGroupPresets=Pool.VehicleGroupPresets;class'MutWoRM_vFix'.static.StaticSaveConfig();
  JournalCount=class'VehicleStuffFix'.default.DeletedVariantKeys.Length;
  Editor.SelectProfile(VariantKey);Editor.DeleteVehicleVariant(None);
  Check(class'VehicleStuffFix'.default.DeletedVariantKeys.Length==JournalCount,"unsaved deletion does not prune groups");
  Editor.SaveAndClose(None);
 }
 else if(Stage==7)
 {
  Check(Pool.FindPoolClass(3,VariantKey)<0,"saved deleted variant is removed from open replacement group");Check(Pool.SelectedPoolTexts[3]=="Onslaught.ONSHoverTank|Onslaught.ONSHoverBike","deletion preserves other group members and order");
  Check(InStr(class'MutWoRM_vFix'.default.ReplacementPoolClassNames[3],VariantKey)<0,"deleted variant is removed from persisted active group");
  Check(Pool.VehicleGroupPresets[0].PoolClassNames[3]=="Onslaught.ONSHoverTank|Onslaught.ONSHoverBike","open held preset prunes only deleted variant");
  Check(class'MutWoRM_vFix'.default.VehicleGroupPresets[0].PoolClassNames[3]=="Onslaught.ONSHoverTank|Onslaught.ONSHoverBike","persisted held preset prunes only deleted variant");
  Check(class'VehicleStuffFix'.default.DeletedVariantKeys.Length>0,"confirmed deletion journal exists");
  PC.ConsoleCommand("shot");Pool.CancelAndClose(None);Log("[EditorWindow] RESULT failures="$Failures);PC.ConsoleCommand("exit");return;
 }
 Stage++;
}
