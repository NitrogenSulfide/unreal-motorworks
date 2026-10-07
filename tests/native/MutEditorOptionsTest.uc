class MutEditorOptionsTest extends MutCustomProjectileTest;
var int HealthPhase;
var bool bFinishPending;
function PostBeginPlay() { SetTimer(4,True); }
function KeyboardCue(GUIComponent Target, string Value)
{
 local FileLog F;
 Target.SetFocus(None);
 F=Spawn(class'FileLog');F.OpenLog("CustomProjectileInput-Options6",,true);
 F.Logf("KEYTYPE" @ int(Target.ActualLeft()+Target.ActualWidth()*0.5) @ int(Target.ActualTop()+Target.ActualHeight()*0.5) @ int(Target.Controller.MouseX) @ int(Target.Controller.MouseY) @ Value);
 F.CloseLog();F.Destroy();
}
function CheckGreenPartition()
{
 local int i,Index;local bool SeenOther;local GUIList L;
 L=GUIListBox(Editor.Controls[4]).List;
 for(i=0;i<L.ItemCount;i++)
 {
  Index=int(L.GetExtraAtIndex(i));
  if(Editor.VehicleMarkerState(Index)!=1) SeenOther=true;
  else Check(!SeenOther,"green saved vehicles remain above ordinary/red entries");
 }
}

function OptionCue(GUIComponent Target, int Id)
{
    local FileLog F;
    F=Spawn(class'FileLog'); F.OpenLog("CustomProjectileInput-Options" $ Id,, true);
       F.Logf("CLICK" @ int(Target.ActualLeft()+Target.ActualWidth()*0.5) @ int(Target.ActualTop()+Target.ActualHeight()*0.5) @ int(Target.Controller.MouseX) @ int(Target.Controller.MouseY));
    F.CloseLog(); F.Destroy();
}
function SetFields(string Primary, string Alternate, string Rate, string AltRate)
{
    Super.SetFields(Primary, Alternate, Rate, AltRate);
    if (Dialog.ControlNum >= 2)
    {
        moCheckBox(Editor.WeapTab.Controls[18+Dialog.ControlNum]).SetComponentValue("True",true);
        Editor.WeapTab.OriginalAppearanceChanged(Editor.WeapTab.Controls[18+Dialog.ControlNum]);
    }
}
function CheckSettings(VehicleStuffFix.VehicleProperties VP, string Prefix)
{
    Super.CheckSettings(VP, Prefix);
    Check(VP.DWeapons[0].bUseOriginalAppearance, Prefix $ " retains original gun appearance option");
    Check(VP.Health == 501 && VP.bRandomHealth, Prefix $ " retains synced advanced health values");
}
function FireAndCheck(CustomVehicleWeapon Gun, PlayerController PC, bool Alternate, class<Projectile> Expected)
{
    Super.FireAndCheck(Gun, PC, Alternate, Expected);
    if (Gun == None) return;
    Check(Gun.AppearanceClass != None && Gun.Mesh == Gun.AppearanceClass.default.Mesh,
        "runtime custom projectiles retain original gun mesh");
    if (Gun.AppearanceClass != None)
    {
        Check(Gun.WeaponFireAttachmentBone == Gun.AppearanceClass.default.WeaponFireAttachmentBone &&
            Gun.WeaponFireOffset == Gun.AppearanceClass.default.WeaponFireOffset, "runtime uses original muzzle bone and offset");
        if (ONSWeaponPawn(Gun.Owner) != None)
            Check(ONSWeaponPawn(Gun.Owner).PitchUpLimit == Gun.PitchUpLimit &&
                ONSWeaponPawn(Gun.Owner).PitchDownLimit == Gun.PitchDownLimit, "passenger pawn retains original aiming limits");
        Check(Gun.YawBone == Gun.AppearanceClass.default.YawBone && Gun.PitchBone == Gun.AppearanceClass.default.PitchBone,
            "runtime uses original aiming bones");
    }
}
function Finish(PlayerController PC)
{
    if (bVerifyReload && !bFinishPending)
    {
        bFinishPending=true;
        PC.bBehindView=true;
        SetTimer(3, true);
        return;
    }
    Super.Finish(PC);
}
function Timer()
{
    local PlayerController PC;
    local GUIController Menus;
    foreach DynamicActors(class'PlayerController', PC) if (PC.Player != None) break;
    if (PC == None || PC.Player == None) return;
    if (bFinishPending) { PC.ConsoleCommand("shot"); Super.Finish(PC); return; }
    if (!bVerifyReload && Stage == 1 && HealthPhase < 14)
    {
        Menus=GUIController(PC.Player.GUIController);
        if (HealthPhase == 0)
        {
            Editor.HealthChange(501);
            GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MainTab, true);
        }
        else if (HealthPhase == 1)
        {
            PC.ConsoleCommand("shot"); OptionCue(Editor.MainTab.Controls[13], 1);
        }
        else if (HealthPhase == 2)
        {
            Log("[CustomProjectile] advanced click cursor=" @ Menus.MouseX @ Menus.MouseY @ "resolution=" @ Menus.ResX @ Menus.ResY);
            Check(Menus.TopPage() == Editor.HealthTab && Editor.HealthTab != None, "actual Advanced click opens health popup");
            if (Editor.HealthTab == None) { Super.Finish(PC); return; }
            Check(moEditBox(Editor.HealthTab.Controls[6]).GetText() == "501", "popup loads main health value");
            KeyboardCue(moEditBox(Editor.HealthTab.Controls[6]).MyEditBox,"760");
            moCheckBox(Editor.HealthTab.Controls[1]).SetComponentValue("True", true);
            Editor.HealthTab.HealthChanged(Editor.HealthTab.Controls[1]);
            Check(Editor.GetCurrentVP().bRandomHealth, "advanced random health checkbox updates same profile");
            // Hold the rendered popup until the next timer step for screenshot evidence.
        }
        else if (HealthPhase == 3)
        {
            Log("[CustomProjectile] keyboard result=" @ moEditBox(Editor.HealthTab.Controls[6]).GetText() @ "cursor=" @ Menus.MouseX @ Menus.MouseY);
            Check(moEditBox(Editor.HealthTab.Controls[6]).GetText()=="760" &&
                Editor.GetCurrentVP().Health==760 && moEditBox(Editor.MainTab.Controls[6]).GetText()=="760",
                "actual keyboard enters multiple health digits and synchronizes main field");
            PC.ConsoleCommand("shot"); OptionCue(Editor.HealthTab.Controls[7],2);
        }
        else if (HealthPhase == 4)
        {
            Check(Menus.TopPage()==Editor,"actual advanced Done returns to Vehicle tab");
            moEditBox(Editor.MainTab.Controls[6]).SetText("501");Editor.OpenAdvancedHealth(None);
            Check(moEditBox(Editor.HealthTab.Controls[6]).GetText()=="501","main health edit is synced on popup reopening");
            Editor.HealthTab.CloseWindow(None);
            GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab,true);
            Editor.SetWeaponClass("Onslaught.ONSHoverTankCannon",0);
            Editor.WeapTab.SetCBPosition("Onslaught.ONSHoverTankCannon",0);
            moCheckBox(Editor.WeapTab.Controls[18]).SetComponentValue("True",true);
            Editor.WeapTab.OriginalAppearanceChanged(Editor.WeapTab.Controls[18]);
            Check(Editor.GetCurrentVP().DWeapons[0].WeaponClass=="Onslaught.ONSHoverTankCannon",
                "appearance toggle cannot overwrite an ordinary selected weapon");
            Editor.SetWeaponClass("Custom",0);Editor.WeapTab.SetCBPosition("Custom",0);
            // Reset the fixture checkbox before real pointer activation.
            moCheckBox(Editor.WeapTab.Controls[18]).SetComponentValue("False",true);

        }
        else if (HealthPhase == 5)
        {
            OptionCue(moCheckBox(Editor.WeapTab.Controls[18]).MyCheckBox,3);
        }
        else if (HealthPhase == 6)
        {
            Check(Editor.GetCurrentVP().DWeapons[0].bUseOriginalAppearance,
                "actual per-weapon checkbox enables original appearance");
            Check(Editor.GetCurrentVP().DWeapons[0].WeaponClass=="Custom","appearance checkbox preserves Custom selection");
            PC.ConsoleCommand("shot");OptionCue(Editor.Controls[19],4);
        }
        else if (HealthPhase == 7)
        {
            Check(Menus.TopPage()==Editor,"actual Save keeps editor open");
            Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==1,"Save clears red marker and establishes green baseline");
            Editor.HealthChange(600);Check(Editor.VehicleMarkerState(Editor.CurrentIndex)==2,"later edit is red after Save");
            Log("[CustomProjectile] before Cancel key=" @ Key @ "selected=" @ class'VehicleStuffFix'.static.ProfileKey(Editor.GetCurrentVP()));
            Editor.CancelAndClose(None);Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());
        }
        else if (HealthPhase == 8)
        {
            Editor.SelectProfile(Key);
            Log("[CustomProjectile] after reopen key=" @ Key @ "selected=" @ class'VehicleStuffFix'.static.ProfileKey(Editor.GetCurrentVP()) @ "HP=" @ Editor.GetCurrentVP().Health @ "appearance=" @ Editor.GetCurrentVP().DWeapons[0].bUseOriginalAppearance);
            Check(Editor.GetCurrentVP().Health==501 && Editor.GetCurrentVP().DWeapons[0].bUseOriginalAppearance,
                "Cancel discards only edits made after Save");
            moCheckBox(Editor.Controls[18]).SetComponentValue("False",true);
            Editor.ModifiedFirstChanged(Editor.Controls[18]);
            GUIListBox(Editor.Controls[4]).List.SetTopItem(100);
        }
        else if (HealthPhase == 9)
        {
            OptionCue(moCheckBox(Editor.Controls[18]).MyCheckBox,5);
        }
        else if (HealthPhase == 10)
        {
            Check(Editor.bModifiedFirst && GUIListBox(Editor.Controls[4]).List.Top==0,"enabling Modified first scrolls list to top");
            Check(class'VehicleStuffFix'.static.ProfileKey(Editor.GetCurrentVP())==Key,"Modified first preserves exact selected variant");
            CheckGreenPartition();
            GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MainTab,true);
        }
        else if (HealthPhase == 11)
        {
            PC.ConsoleCommand("shot");
            Check(VSNativeLabel(Editor.MainTab.Controls[12])!=None,"vehicle subtitle uses native unscaled font renderer");
            GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab,true);
        }
        else if (HealthPhase == 12)
        {
            PC.ConsoleCommand("shot");
            Check(VSNativeLabel(Editor.MountTab.Controls[22])!=None,"placement subtitle uses native unscaled font renderer");
            // Exercise search inside the partition and disable without losing its sort.
            moEditBox(Editor.Controls[9]).SetText("custom projectile regression");
            Check(GUIListBox(Editor.Controls[4]).List.ItemCount==1,"Modified first honors active search");
            moEditBox(Editor.Controls[9]).SetText("");
            moCheckBox(Editor.Controls[18]).SetComponentValue("False",true);Editor.ModifiedFirstChanged(Editor.Controls[18]);
            Check(!Editor.bModifiedFirst && Editor.VehicleSortMode==0,"disabling Modified first preserves name sort");
            GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab,true);
        }
        // One frame interval with Weapons visible before opening its popup.
        else PC.ConsoleCommand("shot");
        HealthPhase++;return;
    }
    Super.Timer();
}
