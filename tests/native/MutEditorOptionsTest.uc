class MutEditorOptionsTest extends MutCustomProjectileTest;
var int HealthPhase;
var bool bFinishPending;
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
    if (Stage == 2 && Dialog.ControlNum == 0) OptionCue(moCheckBox(Dialog.Controls[6]).MyCheckBox, 3);
    else
    {
        moCheckBox(Dialog.Controls[6]).SetComponentValue("True", true);
        Dialog.AnyChange(None);
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
    if (!bVerifyReload && Stage == 1 && HealthPhase < 4)
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
            moEditBox(Editor.HealthTab.Controls[6]).SetText("760");
            Check(Editor.GetCurrentVP().Health == 760 && moEditBox(Editor.MainTab.Controls[6]).GetText() == "760",
                "popup health edit immediately updates main health");
            moCheckBox(Editor.HealthTab.Controls[1]).SetComponentValue("True", true);
            Editor.HealthTab.HealthChanged(Editor.HealthTab.Controls[1]);
            Check(Editor.GetCurrentVP().bRandomHealth, "advanced random health checkbox updates same profile");
            // Hold the rendered popup until the next timer step for screenshot evidence.
        }
        else
        {
            PC.ConsoleCommand("shot"); OptionCue(Editor.HealthTab.Controls[7], 2);
        }
        HealthPhase++;
        return;
    }
    if (!bVerifyReload && Stage == 1 && HealthPhase == 4)
    {
        Check(GUIController(PC.Player.GUIController).TopPage() == Editor, "actual advanced Done returns to Vehicle tab");
        moEditBox(Editor.MainTab.Controls[6]).SetText("501");
        Editor.OpenAdvancedHealth(None);
        Check(moEditBox(Editor.HealthTab.Controls[6]).GetText() == "501", "main health edit is synced on popup reopening");
        Editor.HealthTab.CloseWindow(None);
        HealthPhase++;
        GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab, true);
    }
    Super.Timer();
}
