// Two native processes share only a private fixture configuration.
class MutCustomProjectileTest extends Mutator config(CustomProjectileTest);
var config bool bVerifyReload;
var int Stage, Failures;
var VehicleSuiteConfig Hub;
var VSGUI Editor;
var VSCustomWeaponGUI Dialog;
var ONSVehicle Tank;
var string Key;

function Check(bool Condition, string Message)
{
    if (Condition) Log("[CustomProjectile] PASS " $ Message);
    else { Failures++; Log("[CustomProjectile] FAIL " $ Message); }
}
event PreBeginPlay()
{
    local int i;
    local VehicleStuffFix.VehicleProperties VP;
    Super.PreBeginPlay();
    if (!bVerifyReload)
    {
        VP.VehicleClass = "Onslaught.ONSHoverTank";
        VP.VehicleName = "Goliath";
        VP.Health = 800;
        VP.SpeedScale = 1; VP.Friction = 1; VP.Mass = 1;
        VP.WheelScale = 1; VP.JumpHeight = 1; VP.HoverHeight = 1;
        VP.DWeapons[0].WeaponClass = "Onslaught.ONSHoverTankCannon";
        VP.PWeapons[0].WeaponClass = "Onslaught.ONSTankSecondaryTurret";
        class'VehicleStuffFix'.static.SetVPElement(0, VP);
        class'VehicleStuffFix'.default.VPsLength = 1;
        for (i = 0; i < 11; i++)
        {
            class'MutWoRM_vFix'.default.ReplacementPoolClassNames[i] = "";
            class'MutWoRM_vFix'.default.WoRMVehClassName[i] = "";
        }
    }
}
function PostBeginPlay() { SetTimer(3, true); }
function Cue(GUIComponent Target)
{
    local FileLog F;
    F = Spawn(class'FileLog'); F.OpenLog("CustomProjectileInput-" $ Stage,, true);
    F.Logf("CLICK" @ int(Target.ActualLeft()+Target.ActualWidth()*0.5) @
        int(Target.ActualTop()+Target.ActualHeight()*0.5) @ int(Target.Controller.MouseX) @ int(Target.Controller.MouseY));
    F.CloseLog(); F.Destroy();
}
function SetFields(string Primary, string Alternate, string Rate, string AltRate)
{
    Dialog.SetCBPosition(Primary, 1);
    Dialog.SetCBPosition(Alternate, 2);
    moEditBox(Dialog.Controls[3]).SetText(Rate);
    moEditBox(Dialog.Controls[4]).SetText(AltRate);
}
function CheckSettings(VehicleStuffFix.VehicleProperties VP, string Prefix)
{
    Check(VP.DWeapons[0].bCustomProjectiles, Prefix $ " selects custom driver weapon");
    Check(VP.DWeapons[0].Mode[0] == "XWeapons.FlakShell" &&
        VP.DWeapons[0].Mode[1] == "XWeapons.RocketProj", Prefix $ " retains both driver projectiles");
    Check(Abs(VP.DWeapons[0].Rate[0]-0.6)<0.001 && Abs(VP.DWeapons[0].Rate[1]-0.9)<0.001,
        Prefix $ " retains driver firing intervals");
}
function Finish(PlayerController PC)
{
    Log("[CustomProjectile] RESULT failures=" $ Failures);
    PC.ConsoleCommand("exit");
}
function FireAndCheck(CustomVehicleWeapon Gun, PlayerController PC, bool Alternate, class<Projectile> Expected)
{
    local Projectile P;
    local bool Found;
    if (Gun == None) { Check(false, "custom firing weapon exists"); return; }
    Gun.FireCountdown = 0;
    Check(Gun.AttemptFire(PC, Alternate), "real AttemptFire accepts configured trigger");
    foreach DynamicActors(class'Projectile', P)
        if (P.Class == Expected && P.Instigator == Gun.Instigator) Found = true;
    Check(Found, "trigger spawns selected projectile " $ string(Expected));
}
function VerifyReload(PlayerController PC)
{
    local MutWoRM_vFix Pool;
    local VehicleStuffFix Tuner;
    local VehicleStuffFix.VehicleProperties VP;
    local int i;
    local CustomVehicleWeapon Gun, PassengerGun;
    foreach DynamicActors(class'MutWoRM_vFix', Pool) break;
    foreach DynamicActors(class'VehicleStuffFix', Tuner) break;
    if (Stage == 0)
    {
        Check(Pool != None && Tuner != None, "restarted suite backends exist");
        for (i = 0; i < class'VehicleStuffFix'.default.VPsLength; i++)
        {
            VP = class'VehicleStuffFix'.static.GetDefaultProfile(i);
            if (VP.VehicleClass == "Onslaught.ONSHoverTank" && VP.ProfileId == 1) break;
        }
        Check(VP.ProfileId == 1, "restart loads saved variant identity");
        CheckSettings(VP, "fresh process");
        Check(VP.PWeapons[0].bCustomProjectiles && VP.PWeapons[0].Mode[0] == "XWeapons.FlakShell" &&
            Abs(VP.PWeapons[0].Rate[0]-0.7)<0.001, "fresh process retains passenger custom selection and fields");
        for (i = 0; i < Pool.VehicleFactories.Length; i++)
            if (Pool.VehicleFactories[i].Factory.VehicleClass == class'ONSHoverTank')
            {
                Pool.VehicleFactories[i].Factory.bActive = true;
                Pool.VehicleFactories[i].Factory.TeamNum = 0;
                if (Pool.VehicleFactories[i].Factory.LastSpawned == None) Pool.VehicleFactories[i].Factory.SpawnVehicle();
                Tank = ONSVehicle(Pool.VehicleFactories[i].Factory.LastSpawned);
                if (Tank != None) break;
            }
    }
    else
    {
        Check(Tank != None, "Torlan factory spawns configured tank variant");
        if (Tank != None)
        {
            VP = class'VehicleStuffFix'.static.GetDefaultProfile(Tuner.FindVehicleProfile(Tank));
            Check(VP.ProfileId == 1, "runtime binding uses saved variant rather than base");
            PC.Possess(Tank);
            Gun = CustomVehicleWeapon(Tank.Weapons[0]);
            Check(Gun != None, "runtime replaces original driver cannon with custom weapon");
            if (Gun != None)
            {
                Check(Gun.ProjectileClass == class'FlakShell' && Gun.AltFireProjectileClass == class'RocketProj',
                    "runtime loads both saved projectile classes");
                Check(Abs(Gun.FireInterval-0.6)<0.001 && Abs(Gun.AltFireInterval-0.9)<0.001,
                    "runtime uses both saved firing intervals");
                FireAndCheck(Gun, PC, false, class'FlakShell');
                FireAndCheck(Gun, PC, true, class'RocketProj');
            }
            PassengerGun = CustomVehicleWeapon(Tank.WeaponPawns[0].Gun);
            Check(PassengerGun != None, "runtime replaces passenger turret with custom weapon");
            if (PassengerGun != None)
            {
                Check(PassengerGun.ProjectileClass == class'FlakShell' && Abs(PassengerGun.FireInterval-0.7)<0.001,
                    "runtime passenger uses saved projectile and interval");
                FireAndCheck(PassengerGun, PC, false, class'FlakShell');
            }
        }
        Finish(PC);
    }
    Stage++;
}
function Timer()
{
    local PlayerController PC;
    local GUIController Menus;
    local VehicleStuffFix.VehicleProperties VP;
    local int i;
    foreach DynamicActors(class'PlayerController', PC) if (PC.Player != None) break;
    if (PC == None || PC.Player == None) return;
    if (bVerifyReload) { VerifyReload(PC); return; }
    Menus = GUIController(PC.Player.GUIController);
    if (Stage == 0)
    {
        PC.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox");
        PC.ClientOpenMenu("VehicleSuite.VehicleSuiteConfig");
        Hub = VehicleSuiteConfig(Menus.TopPage()); Hub.OpenVehicleTuning(None);
        Editor = VSGUI(Menus.TopPage()); Editor.SelectProfile("Onslaught.ONSHoverTank");
        Editor.DuplicateVehicle(None);
        VP = Editor.GetCurrentVP(); VP.VehicleName = "Custom projectile regression";
        Editor.SetCurrentVP(VP); Key = class'VehicleStuffFix'.static.ProfileKey(VP);
        GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab, true);
    }
    else if (Stage == 1)
    {
        moCheckBox(Editor.WeapTab.Controls[24]).SetComponentValue("True",true);
        Editor.WeapTab.CustomProjectilesChanged(Editor.WeapTab.Controls[24]);
        Check(Editor.GetCurrentVP().DWeapons[0].bCustomProjectiles && Editor.GetCurrentVP().DWeapons[0].WeaponClass=="Onslaught.ONSHoverTankCannon", "custom projectile toggle preserves selected gun");
        Editor.SetWeaponClass("Onslaught.ONSHoverTankCannon", 0); Editor.UpdateDisplay();
        Cue(Editor.WeapTab.Controls[6]);
    }
    else if (Stage == 2)
    {
        Dialog = VSCustomWeaponGUI(Menus.TopPage());
        Check(Dialog != None && Dialog.bInitialized, "actual Custom button opens initialized dialog");
        if (Dialog == None) { Finish(PC); return; }
        SetFields("XWeapons.FlakShell", "XWeapons.RocketProj", "0.6", "0.9");
    }
    else if (Stage == 3)
    {
        PC.ConsoleCommand("shot"); Cue(Dialog.Controls[5]);
    }
    else if (Stage == 4)
    {
        Check(Menus.TopPage() == Editor, "actual Done click returns to editor");
        CheckSettings(Editor.GetCurrentVP(), "Done");
        Check(Editor.VehicleMarkerState(Editor.CurrentIndex) == 2, "custom edits show unsaved marker");
        Cue(Editor.Controls[5]);
    }
    else if (Stage == 5)
    {
        Check(Menus.TopPage() == Hub, "actual Save and Close returns to hub");
        Hub.OpenVehicleTuning(None); Editor = VSGUI(Menus.TopPage()); Editor.SelectProfile(Key);
        CheckSettings(Editor.GetCurrentVP(), "reopened editor");
        Check(Editor.VehicleMarkerState(Editor.CurrentIndex) == 1, "saved custom profile shows green marker");
        GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab, true);
        Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]); Dialog = VSCustomWeaponGUI(Menus.TopPage());
        Check(Dialog.P[moComboBox(Dialog.Controls[1]).GetIndex()].PClass == "XWeapons.FlakShell" &&
            Abs(float(moEditBox(Dialog.Controls[3]).GetText())-0.6)<0.001, "reopened custom dialog displays saved fields immediately");
    }
    else if (Stage == 6)
    {
        PC.ConsoleCommand("shot"); Dialog.CloseWindow(None);
        Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[8]); Dialog = VSCustomWeaponGUI(Menus.TopPage());
        SetFields("XWeapons.FlakShell", "", "0.7", "0"); Dialog.CloseWindow(None);
        Check(Editor.GetCurrentVP().PWeapons[0].bCustomProjectiles, "passenger dialog activates exact passenger slot");
        Editor.SaveAndClose(None);
    }
    else if (Stage == 7)
    {
        Hub.OpenVehicleTuning(None); Editor = VSGUI(Menus.TopPage()); Editor.SelectProfile(Key);
        VP = Editor.GetCurrentVP(); Editor.SetWeaponClass("Onslaught.ONSHoverTankCannon", 0);
        Check(Editor.GetCurrentVP().DWeapons[0].WeaponClass == "Onslaught.ONSHoverTankCannon" &&
            Editor.GetCurrentVP().DWeapons[0].Mode[0] == VP.DWeapons[0].Mode[0], "normal weapon selection preserves dormant custom settings");
        Editor.CancelAndClose(None);
        Hub.OpenVehicleTuning(None); Editor = VSGUI(Menus.TopPage()); Editor.SelectProfile(Key);
        CheckSettings(Editor.GetCurrentVP(), "after Cancel");
        VP = Editor.GetCurrentVP(); VP.DWeapons[0].Mode[0] = "Onslaught.ONSHoverBikePlasmaProjectile";
        Editor.SetCurrentVP(VP);
        Editor.WeapTab.OpenCustomWeaponGUI(Editor.WeapTab.Controls[6]); Dialog = VSCustomWeaponGUI(Menus.TopPage());
        Check(Dialog.P[moComboBox(Dialog.Controls[1]).GetIndex()].PClass == VP.DWeapons[0].Mode[0],
            "dialog preserves a saved projectile absent from weapon cache");
        Dialog.CloseWindow(None);
        Check(Editor.GetCurrentVP().DWeapons[0].Mode[0] == VP.DWeapons[0].Mode[0],
            "Done does not erase an unlisted saved projectile");
        Editor.CancelAndClose(None);
        for (i = 0; i < 11; i++) if (class'MutWoRM_vFix'.default.ReplacedVehicleClass[i] == class'ONSHoverTank')
        {
            class'MutWoRM_vFix'.default.ReplacementPoolClassNames[i] = Key;
            class'MutWoRM_vFix'.default.ReplacementStrategies[i] = 0;
        }
        class'MutWoRM_vFix'.static.StaticSaveConfig(); Finish(PC);
    }
    Stage++;
}
