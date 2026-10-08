class MutVehicleSuiteEditorTest extends MutVehicleSuiteFeatureTest;

var VSGUI Editor;
var WoRM_vCfgFix PoolPage;
var int DuplicateProfileId, SourceProfileId, SourceHealth;
var bool bNavigationTested;
var int BrowserScreenshotStage;

function PostBeginPlay()
{
    Stage = 0;
    SetTimer(3, true);
}

function TestBrowserMembershipNavigation()
{
    local GUIList List;
    local string Target, NextKey, Anchor;
    local int Mode, StartIndex, SavedTop;
    local byte Key, KeyState;
    List = GUIListBox(PoolPage.Controls[22]).List;
    for (Mode = 0; Mode < 2; Mode++)
    {
        PoolPage.bInGroupFirst = Mode == 1;
        moCheckBox(PoolPage.Controls[37]).SetComponentValue(string(Mode == 1), true);
        PoolPage.SelectedPoolTexts[0] = "Onslaught.ONSHoverTank|Onslaught.ONSHoverTank#1";
        PoolPage.RebuildVehicleList();
        StartIndex = List.ItemCount / 2;
        List.SetIndex(StartIndex);
        PoolPage.VehicleListChange(PoolPage.Controls[22]);
        List.SetTopItem(StartIndex - 5);
        Target = List.GetExtra();
        NextKey = List.GetExtraAtIndex(StartIndex + 1);
        Anchor = List.GetExtraAtIndex(List.Top);
        Check(List.ItemsPerPage > 5 && List.Top > 0, "navigation fixture is scrolled below top");
        Key = 32;
        KeyState = 1;
        Check(PoolPage.VehicleListKeyEvent(Key, KeyState, 0), "Space is handled by vehicle browser");
        Check(PoolPage.FindPoolClass(0, Target) >= 0 && List.GetExtra() == NextKey,
            "Space adds member and advances to next original row, sort mode " $ Mode);
        Check(List.GetExtraAtIndex(List.Top) == Anchor, "add preserves viewport anchor, sort mode " $ Mode);
        KeyState = 3;
        PoolPage.VehicleListKeyEvent(Key, KeyState, 0);
        KeyState = 0;
        PoolPage.VehicleListKeyEvent(Key, KeyState, 0);
        Check(PoolPage.FindPoolClass(0, NextKey) < 0, "Space repeat and release do not toggle next row");

        // Arrange an existing member in the middle of the browser for removal.
        PoolPage.bInGroupFirst = false;
        PoolPage.HighlightedVehicleClasses[0] = Target;
        PoolPage.RebuildVehicleList();
        List.SetTopItem(List.Index - 5);
        SavedTop = List.Top;
        PoolPage.ToggleVehicleGroupClass(None);
        Check(PoolPage.FindPoolClass(0, Target) < 0 && List.GetExtra() == NextKey && List.Top == SavedTop,
            "button removal advances without resetting scroll");
    }
    moCheckBox(PoolPage.Controls[37]).SetComponentValue("False", true);
}

function SelectBrowserSort(string SortKey)
{
    local moComboBox Combo;
    Combo = moComboBox(PoolPage.Controls[33]);
    Combo.SetIndex(Combo.FindIndex(SortKey, true, true));
    PoolPage.VehicleSortChange(Combo);
}

function TestHealthAndPackageSorts()
{
    local int i, VariantIndex, SavedHealth, SectionIndex, NextIndex;
    local GUIList List;
    local string Target, NextKey;
    local VehicleStuffFix.VehicleProperties VP;
    local color LowestColor, HighestColor;
    PoolPage.bInGroupFirst = false;
    for (i = 0; i < class'VehicleStuffFix'.default.VPsLength; i++)
    {
        VP = class'VehicleStuffFix'.static.GetDefaultProfile(i);
        if (class'VehicleStuffFix'.static.ProfileKey(VP) == "Onslaught.ONSHoverTank#1") break;
    }
    VariantIndex = i;
    Check(VariantIndex < class'VehicleStuffFix'.default.VPsLength, "HP fixture finds exact variant profile");
    if (VariantIndex >= class'VehicleStuffFix'.default.VPsLength) return;
    SavedHealth = VP.Health;
    VP.Health = 123456;
    class'VehicleStuffFix'.static.SetVPElement(VariantIndex, VP);
    PoolPage.TuningClosed();
    SelectBrowserSort("CURRENTHP");
    i = PoolPage.FindVehicleClass("Onslaught.ONSHoverTank#1");
    Check(i == 0 && PoolPage.Vehicles[i].CurrentHealth == 123456,
        "current HP sort uses exact tuned variant health after tuning refresh");
    Check(PoolPage.Vehicles[i].OriginalHealth == class'Onslaught.ONSHoverTank'.default.Health,
        "original HP remains class default for tuned variants");
    SelectBrowserSort("ORIGINALHP");
    for (i = 1; i < PoolPage.Vehicles.Length; i++)
        if (PoolPage.Vehicles[i-1].OriginalHealth < PoolPage.Vehicles[i].OriginalHealth) break;
    Check(i == PoolPage.Vehicles.Length, "original HP sort is descending throughout catalog");
    VP.Health = 0;
    class'VehicleStuffFix'.static.SetVPElement(VariantIndex, VP);
    PoolPage.TuningClosed();
    i = PoolPage.FindVehicleClass("Onslaught.ONSHoverTank#1");
    Check(PoolPage.Vehicles[i].CurrentHealth == PoolPage.Vehicles[i].OriginalHealth,
        "unset tuned HP falls back to original HP");
    VP.Health = SavedHealth;
    class'VehicleStuffFix'.static.SetVPElement(VariantIndex, VP);
    PoolPage.TuningClosed();
    SelectBrowserSort("PACKAGE");
    List = GUIListBox(PoolPage.Controls[22]).List;
    for (SectionIndex = 3; SectionIndex < List.ItemCount - 1; SectionIndex++)
        if (List.Elements[SectionIndex].bSection && !List.Elements[SectionIndex-1].bSection) break;
    Check(SectionIndex < List.ItemCount - 1, "package sort inserts section headers");
    if (SectionIndex < List.ItemCount - 1)
    {
        List.SetIndex(SectionIndex-1);
        PoolPage.VehicleListChange(PoolPage.Controls[22]);
        Target = List.GetExtra();
        NextIndex = SectionIndex+1;
        NextKey = List.GetExtraAtIndex(NextIndex);
        PoolPage.ToggleVehicleGroupClass(None);
        Check(List.GetExtra() == NextKey && Left(PoolPage.HighlightedVehicleClasses[0], 8) != "SECTION:",
            "membership advance skips package header and selects real next vehicle");
    }
    SelectBrowserSort("CURRENTHP");
    for (i = 1; i < PoolPage.Vehicles.Length; i++)
        if (PoolPage.Vehicles[i-1].CurrentHealth < PoolPage.Vehicles[i].CurrentHealth) break;
    Check(i == PoolPage.Vehicles.Length, "current HP sort is descending throughout catalog");
    LowestColor = PoolPage.HealthGradientColor(PoolPage.Vehicles[PoolPage.Vehicles.Length - 1].CurrentHealth, true);
    HighestColor = PoolPage.HealthGradientColor(PoolPage.Vehicles[0].CurrentHealth, true);
    Check(LowestColor.G == 255 && LowestColor.R == 0 && HighestColor.R == 255 && HighestColor.G == 0,
        "HP gradient is green at the lowest value and red at the highest value");
    List.SetTopItem(0);
}

function TestPresetDefaults(PlayerController PC)
{
    local GUIController Menus;
    local WoRM_vCfgFix ReopenedPage;

    // The runtime test uses an isolated UT2004 config tree. Start with no
    // carried-over custom set so each lifecycle assertion has a fixed baseline.
    class'WoRM2k4Fix.WoRM_vCfgFix'.default.CustomPreset.Length = 0;
    class'MutWoRM_vFix'.default.VehicleGroupPresets.Length = 0;
    class'MutWoRM_vFix'.default.GoliathGroupPresets.Length = 0;
    class'MutWoRM_vFix'.default.LastSavedPresetName = "";
    class'WoRM2k4Fix.WoRM_vCfgFix'.static.StaticSaveConfig();
    class'MutWoRM_vFix'.static.StaticSaveConfig();

    PoolPage.SelectedCars[0] = "Onslaught.ONSHoverTank";
    PoolPage.SelectedPoolTexts[0] = "Onslaught.ONSHoverTank";
    PoolPage.SelectedStrategies[0] = 0;
    moComboBox(PoolPage.Controls[26]).SetText("Preset regression A");
    PoolPage.SavePresetFixed(None);
    Check(class'MutWoRM_vFix'.default.LastSavedPresetName ~= "Preset regression A",
        "saving preset A records the Motorpool default");

    // Prior Motorworks releases kept name metadata in the legacy GUI section.
    // Reopen with only authoritative saved group records to verify migration.
    class'WoRM2k4Fix.WoRM_vCfgFix'.default.CustomPreset.Length = 0;
    PoolPage.CancelAndClose(None);
    PC.ClientOpenMenu("WoRM2k4Fix.WoRM_vCfgFix");
    Menus = GUIController(PC.Player.GUIController);
    ReopenedPage = WoRM_vCfgFix(Menus.TopPage());
    if (ReopenedPage == None)
    {
        Check(false, "reopening Motorpool after preset A returns its page");
        return;
    }
    Check(moComboBox(ReopenedPage.Controls[26]).GetText() ~= "Preset regression A" &&
        ReopenedPage.SelectedPoolTexts[0] ~= "Onslaught.ONSHoverTank", "reopening Motorpool selects and loads preset A");

    PoolPage = ReopenedPage;
    PoolPage.SelectedCars[0] = "Onslaught.ONSAttackCraft";
    PoolPage.SelectedPoolTexts[0] = "Onslaught.ONSAttackCraft";
    moComboBox(PoolPage.Controls[26]).SetText("Preset regression B");
    PoolPage.SavePresetFixed(None);
    Check(class'MutWoRM_vFix'.default.LastSavedPresetName ~= "Preset regression B",
        "saving preset B replaces the Motorpool default");

    moComboBox(PoolPage.Controls[26]).SetText("New set name");
    PoolPage.SelectedPoolTexts[0] = "none";
    PoolPage.SavePresetFixed(None);
    Check(class'MutWoRM_vFix'.default.LastSavedPresetName ~= "Preset regression B",
        "invalid preset save leaves the prior default intact");

    PoolPage.CancelAndClose(None);
    PC.ClientOpenMenu("WoRM2k4Fix.WoRM_vCfgFix");
    Menus = GUIController(PC.Player.GUIController);
    ReopenedPage = WoRM_vCfgFix(Menus.TopPage());
    if (ReopenedPage == None)
    {
        Check(false, "reopening Motorpool after preset B returns its page");
        return;
    }
    Check(moComboBox(ReopenedPage.Controls[26]).GetText() ~= "Preset regression B" &&
        ReopenedPage.SelectedPoolTexts[0] ~= "Onslaught.ONSAttackCraft", "reopening after invalid save keeps preset B loaded");

    PoolPage = ReopenedPage;
    PoolPage.DeletePresetFixed(None);
    PoolPage.DeletePresetFixed(None);
    Check(class'MutWoRM_vFix'.default.LastSavedPresetName == "",
        "deleting the default preset clears its saved name");

    PoolPage.CancelAndClose(None);
    PC.ClientOpenMenu("WoRM2k4Fix.WoRM_vCfgFix");
    Menus = GUIController(PC.Player.GUIController);
    ReopenedPage = WoRM_vCfgFix(Menus.TopPage());
    if (ReopenedPage == None)
    {
        Check(false, "reopening Motorpool after default deletion returns its page");
        return;
    }
    Check(moComboBox(ReopenedPage.Controls[26]).GetText() ~= "New set name" &&
        !(ReopenedPage.SelectedPoolTexts[0] ~= "Onslaught.ONSAttackCraft"), "reopening after deletion does not load a stale default preset");
    PoolPage = ReopenedPage;
    class'WoRM2k4Fix.WoRM_vCfgFix'.default.CustomPreset.Length = 0;
    class'MutWoRM_vFix'.default.VehicleGroupPresets.Length = 0;
    class'MutWoRM_vFix'.default.GoliathGroupPresets.Length = 0;
    class'WoRM2k4Fix.WoRM_vCfgFix'.static.StaticSaveConfig();
    class'MutWoRM_vFix'.static.StaticSaveConfig();
}

function Timer()
{
    local Controller C;
    local PlayerController PC;
    local GUIController Menus;
    local VehicleStuffFix.VehicleProperties VP;
    local int FirstMember, FirstNonMember, CountBeforeDelete;
    local GUIList List;
    foreach DynamicActors(class'PlayerController', PC)
        if (PC.Player != None) break;
    if (PC == None || PC.Player == None) return;
    C = PC;
    if (C == None) return;
    Menus = GUIController(PC.Player.GUIController);
    if (Stage == 0)
    {
        // Keep an underlying page while testing close/reopen. Closing the
        // last standalone menu otherwise returns to the main menu/disconnects.
        PC.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox");
        PC.ClientOpenMenu("WoRM2k4Fix.WoRM_vCfgFix");
        Menus = GUIController(PC.Player.GUIController);
        PoolPage = WoRM_vCfgFix(Menus.TopPage());
        TestPresetDefaults(PC);
        // The test owns the highlighted key, so use a stable UI slot rather
        // than depending on a user's saved Motorpool replacement layout.
        PoolPage.CurrentSlot = 0;
        GUIListBox(PoolPage.Controls[20]).List.SetIndex(PoolPage.CurrentSlot);
        PoolPage.SlotListChange(PoolPage.Controls[20]);
        PoolPage.SelectedPoolTexts[PoolPage.CurrentSlot] = "Onslaught.ONSHoverTank|Onslaught.ONSHoverTank#1";
        PoolPage.SelectedCars[PoolPage.CurrentSlot] = "Onslaught.ONSHoverTank";
        PoolPage.HighlightedVehicleClasses[PoolPage.CurrentSlot] = "Onslaught.ONSHoverTank#1";
        PoolPage.bInGroupFirst = true;
        moCheckBox(PoolPage.Controls[37]).SetComponentValue("True", true);
        PoolPage.RebuildVehicleList();
        PoolPage.UpdateStrategyCombo();
        PoolPage.UpdateGroupControls();
        List = GUIListBox(PoolPage.Controls[22]).List;
        FirstMember = List.FindIndex("Onslaught.ONSHoverTank#1", true, true);
        FirstNonMember = List.FindIndex("none", true, true);
        Check(FirstMember >= 0 && FirstMember < FirstNonMember, "in-group first retains variant identity");
        moEditBox(PoolPage.Controls[21]).SetText("no-matching-vehicle");
        PoolPage.RebuildVehicleList();
        List = GUIListBox(PoolPage.Controls[42]).List;
        List.SetIndex(List.FindIndex("Onslaught.ONSHoverTank", true, true));
        PoolPage.GroupRosterChange(PoolPage.Controls[42]);
        Check(PoolPage.HighlightedVehicleClasses[0] == "Onslaught.ONSHoverTank" &&
            GUIListBox(PoolPage.Controls[22]).List.GetExtra() == "Onslaught.ONSHoverTank",
            "roster selection clears conflicting search and selects browser member");
        List.SetIndex(List.FindIndex("Onslaught.ONSHoverTank#1", true, true));
        PoolPage.GroupRosterChange(PoolPage.Controls[42]);
        Check(PoolPage.HighlightedVehicleClasses[0] == "Onslaught.ONSHoverTank#1",
            "roster preserves exact variant identity for tuning");
    }
    else if (Stage == 1)
    {
        if (!bNavigationTested)
        {
            TestBrowserMembershipNavigation();
            TestHealthAndPackageSorts();
            PoolPage.SelectedStrategies[0]=0;
            PoolPage.SaveWithoutClosing(None);
            Check(Menus.TopPage()==PoolPage,"Motorpool Save keeps page open");
            Check(class'MutWoRM_vFix'.default.ReplacementPoolClassNames[0]==PoolPage.SelectedPoolTexts[0],
                "Motorpool Save commits exact ordered variant group");
            PoolPage.SelectedStrategies[0]=1;
            PoolPage.CancelAndClose(None);
            Menus.OpenMenu("WoRM2k4Fix.WoRM_vCfgFix");PoolPage=WoRM_vCfgFix(Menus.TopPage());
            Check(PoolPage.SelectedStrategies[0]==0,"Motorpool Cancel discards only changes after Save");
            Check(GUILabel(PoolPage.Controls[23]).TextColor.R==255 &&
                InStr(GUILabel(PoolPage.Controls[48]).Caption,"Synchronized in-order")>=0,
                "Motorpool has red group summary and explicit order disclaimer");
            bNavigationTested = true;
            return;
        }
        PC.ConsoleCommand("shot");
        if (BrowserScreenshotStage == 0)
        {
            SelectBrowserSort("PACKAGE");
            GUIListBox(PoolPage.Controls[22]).List.SetTopItem(0);
            BrowserScreenshotStage++;
            return;
        }
        PoolPage.HighlightedVehicleClasses[0] = "Onslaught.ONSHoverTank#1";
        PoolPage.RebuildVehicleList();
        Log("[VehicleSuiteEditor] shortcut slot=" $ PoolPage.CurrentSlot @ "key=" $ PoolPage.HighlightedVehicleClasses[PoolPage.CurrentSlot] @ "row=" $ GUIListBox(PoolPage.Controls[22]).List.GetExtra());
        PoolPage.OpenHighlightedTuning(None);
        Editor = VSGUI(Menus.TopPage());
        Check(Editor != None, "Motorpool shortcut opens tuning");
        if (Editor != None)
        {
            VP = Editor.GetCurrentVP();
            Log("[VehicleSuiteEditor] editor key=" $ class'VehicleStuffFix'.static.ProfileKey(VP) @ "index=" $ Editor.CurrentIndex);
            Check(VP.ProfileId == 1, "Motorpool shortcut selects exact variant");
            SourceProfileId = VP.ProfileId;
            SourceHealth = VP.Health;
        }
    }
    else if (Stage == 2)
    {
        PC.ConsoleCommand("shot");
        Editor.DuplicateVehicle(None);
        VP = Editor.GetCurrentVP();
        Check(VP.ProfileId != SourceProfileId && VP.Health == SourceHealth, "duplicate copies tuning with new identity");
        DuplicateProfileId = VP.ProfileId;
        VP.VehicleName = "Independent preview variant";
        Editor.SetCurrentVP(VP);
        Editor.UpdateDisplay();
        GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab, true);
        moEditBox(Editor.MountTab.Controls[12]).SetComponentValue("12", true);
        moEditBox(Editor.MountTab.Controls[13]).SetComponentValue("-6", true);
        moEditBox(Editor.MountTab.Controls[14]).SetComponentValue("30", true);
        moEditBox(Editor.MountTab.Controls[18]).SetComponentValue("0.85", true);
        Editor.MountTab.MountChanged(Editor.MountTab.Controls[14]);
        VP = Editor.GetCurrentVP();
        Check(VP.DWeapons[0].MountOffset.Z == 30 && VP.DWeapons[0].MountScale == 0.85, "placement inputs accept zero angles and signed offsets");
    }
    else if (Stage == 3)
    {
        PC.ConsoleCommand("shot");
        Check(Editor.MountTab.PreviewWeapons[0] != None, "placement has an attached weapon preview");
        if (Editor.MountTab.PreviewWeapons[0] != None)
            Check(VSize(Editor.GetCurrentVP().DWeapons[0].MountOffset - vect(12,-6,30)) < 0.1, "preview retains placement inputs");
        Editor.OpenAdvancedHealth(None);
        moSlider(Editor.HealthTab.Controls[2]).SetComponentValue("0.9", true);
        Editor.HealthTab.HealthChanged(Editor.HealthTab.Controls[2]);
        VP = Editor.GetCurrentVP();
        Check(Abs(VP.HealthMin - 0.9) < 0.001 && VP.HealthMax == 1.2, "health slider edits a separate spawn multiplier");
    }
    else if (Stage == 4)
    {
        PC.ConsoleCommand("shot");
        if (Editor.HealthTab != None) Editor.HealthTab.CloseWindow(None);
        CountBeforeDelete = Editor.VPsLength;
        Editor.DeleteVehicleVariant(None);
        Check(Editor.VPsLength == CountBeforeDelete - 1, "delete removes selected variant");
        Check(Editor.FindVehicleClass("Onslaught.ONSHoverTank#" $ String(DuplicateProfileId)) < 0, "deleted variant identity is gone");
        Editor.SelectProfile("Onslaught.ONSHoverTank");
        if (Editor.HealthTab != None) Editor.HealthTab.CloseWindow(None);
        CountBeforeDelete = Editor.VPsLength;
        Editor.DeleteVehicleVariant(None);
        Check(Editor.VPsLength == CountBeforeDelete, "original vehicle rejects delete action");
        Editor.SaveAndClose(None);
    }
    else if (Stage == 5)
    {
        List = GUIListBox(PoolPage.Controls[20]).List;
        Check(List.FindIndex("11", true, true) < 0 && List.FindIndex("12", true, true) < 0,
            "Motorpool contains only factory-spawned stock vehicle slots");
        PC.ClientOpenMenu("VehicleStuffFix.VSGUI");
        Editor = VSGUI(Menus.TopPage());
        Check(Editor != None, "Vehicle Tuning opens directly");
        if (Editor != None)
        {
            Editor.SelectProfile("Onslaught.ONSManualGunPawn");
            VP = Editor.GetCurrentVP();
            Check(VP.VehicleClass ~= "Onslaught.ONSManualGunPawn",
                "node turret remains tunable in Vehicle Tuning");
            Editor.SelectProfile("UT2k4Assault.ASTurret_Minigun");
            VP = Editor.GetCurrentVP();
            Check(VP.VehicleClass ~= "UT2k4Assault.ASTurret_Minigun",
                "minigun turret remains tunable in Vehicle Tuning");
        }
    }
    else if (Stage == 6)
    {
        PC.ConsoleCommand("shot");
        Log("[VehicleSuiteEditor] RESULT failures=" $ Failures);
    }
    else PC.ConsoleCommand("exit");
    Stage++;
}

defaultproperties
{
    FriendlyName="Vehicle Suite isolated editor tests"
}
