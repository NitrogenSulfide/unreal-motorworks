class MutPreviewPolishTest extends Mutator;
var int Stage, Failures;
var VehicleSuiteConfig Hub;
var VSGUI Editor;
var WoRM_vCfgFix Pool;
var string AKey, BKey;
var float OldZoom, OldY, OldZ, OldDistance;
var int OldYaw, OldPitch;
var rotator OldPoolRotation;
function Check(bool OK,string Message)
{
    if(OK) Log("[PreviewPolish] PASS" @ Message);
    else { Failures++; Log("[PreviewPolish] FAIL" @ Message); }
}
event PreBeginPlay()
{
    local VehicleStuffFix.VehicleProperties Empty, VP;
    local int i;
    Super.PreBeginPlay();
    for(i=0;i<512;i++) class'VehicleStuffFix'.static.SetVPElement(i,Empty);
    VP.VehicleClass="Onslaught.ONSHoverTank";VP.VehicleName="Goliath";VP.Health=800;
    VP.SpeedScale=1;VP.Friction=1;VP.Mass=1;VP.WheelScale=1;VP.JumpHeight=1;VP.HoverHeight=1;
    VP.DWeapons[0].WeaponClass="Onslaught.ONSHoverTankCannon";
    VP.PWeapons[0].WeaponClass="Onslaught.ONSTankSecondaryTurret";
    class'VehicleStuffFix'.static.SetVPElement(0,VP);
    VP.VehicleClass="Onslaught.ONSHoverBike";VP.VehicleName="Manta";
    VP.DWeapons[0].WeaponClass="Onslaught.ONSHoverBikePlasmaGun";
    VP.PWeapons[0]=Empty.PWeapons[0];
    class'VehicleStuffFix'.static.SetVPElement(1,VP);
    VP.VehicleClass="Onslaught.ONSManualGunPawn";VP.VehicleName="Node turret";
    VP.DWeapons[0].WeaponClass="Onslaught.ONSAttackCraftGun";
    class'VehicleStuffFix'.static.SetVPElement(2,VP);class'VehicleStuffFix'.default.VPsLength=3;
}
function PostBeginPlay() { SetTimer(4,true); }
function Hover(float X,float Y,optional bool Drag)
{
    local FileLog F;
    F=Spawn(class'FileLog');F.OpenLog("PreviewPolishInput-" $ Stage,,true);
    if (Drag) F.Logf("DRAG" @ int(X) @ int(Y));
    else F.Logf("HOVER" @ int(X) @ int(Y));F.CloseLog();F.Destroy();
}
function VerifyHover(GUIController Menus,GUIComponent Input,bool Inside)
{
    Check((Input.MouseCursorIndex==5)==Inside,"drag cursor only inside viewport stage=" $ Stage);
    Log("[PreviewPolish] CURSOR stage=" $ Stage @ Menus.MouseX @ Menus.MouseY @ "index=" $ Input.MouseCursorIndex @ "active=" $ Menus.ActiveControl);
}
function Timer()
{
    local PlayerController PC;
    local GUIController Menus;
    local VehicleStuffFix.VehicleProperties VP;
    local VehicleStuffFix.VehicleWeaponProperties W, Passenger;
    foreach DynamicActors(class'PlayerController',PC) if(PC.Player!=None) break;
    if(PC==None || PC.Player==None) return;
    Menus=GUIController(PC.Player.GUIController);
    if(Stage==0)
    {
        PC.ClientOpenMenu("GUI2K4.UT2K4GenericMessageBox");PC.ClientOpenMenu("UnrealMotorworks.VehicleSuiteConfig");
        Hub=VehicleSuiteConfig(Menus.TopPage());Hub.OpenVehicleTuning(None);Editor=VSGUI(Menus.TopPage());
        // Reproduce the user's full-screen editor, as well as the regular modal fixture.
        Editor.bBoundToParent=false;Editor.bScaleToParent=false;Editor.bNeverScale=true;
        Editor.SetPosition(0,0,Menus.ResX,Menus.ResY);
        Check(Editor.bModifiedFirst && moCheckBox(Editor.Controls[18]).IsChecked(),"Modified first defaults on in model and checkbox");
        Editor.SelectProfile("Onslaught.ONSHoverTank");Editor.DuplicateVehicle(None);
        Check(Editor.GetCurrentVP().VehicleName=="Goliath variant 1","first Goliath variant is numbered 1");
        Editor.SelectProfile("Onslaught.ONSHoverBike");Editor.DuplicateVehicle(None);BKey=class'VehicleStuffFix'.static.ProfileKey(Editor.GetCurrentVP());
        Check(Editor.GetCurrentVP().VehicleName=="Manta variant 1","first Manta variant is numbered independently");
        Editor.DuplicateVehicle(None);
        Check(Editor.GetCurrentVP().VehicleName=="Manta variant 2","duplicating a variant uses base name and next free local number");
        Editor.SelectProfile("Onslaught.ONSHoverTank");Editor.DuplicateVehicle(None);AKey=class'VehicleStuffFix'.static.ProfileKey(Editor.GetCurrentVP());
        Check(Editor.GetCurrentVP().VehicleName=="Goliath variant 2","Goliath numbering ignores Manta variants");
        Check(AKey!=BKey,"variant identity keys remain unique");
    }
    else if(Stage==1)
    {
        Check(Editor.Controls[19].ActualLeft()+Editor.Controls[19].ActualWidth()+8 < Editor.Controls[5].ActualLeft(),"Save and Save Close have a real pixel gutter in fullscreen");
        VP=Editor.GetCurrentVP();VP.DWeapons[0].WeaponClass="Custom";VP.DWeapons[0].bUseOriginalAppearance=true;
        VP.DWeapons[0].Mode[0]="XWeapons.FlakShell";VP.DWeapons[0].MountOffset=vect(12,-6,30);
        VP.DWeapons[0].MountRotation=rot(0,4096,0);VP.DWeapons[0].MountScale=0.85;
        VP.PWeapons[0].MountOffset=vect(0,0,17);Editor.SetCurrentVP(VP);Editor.UpdateDisplay();
        GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MountTab,true);
    }
    else if(Stage==2)
    {
        Check(Editor.MountTab.Controls[24].bVisible,"original appearance warning is visible");
        Check(Editor.MountTab.Controls[12].MenuState!=MSAT_Disabled,"original appearance leaves placement editable");
        Check(Editor.MountTab.PreviewWeapons[0].Mesh==class'ONSHoverTankCannon'.default.Mesh,"original appearance uses original cannon mesh in tuning");
        Editor.MountTab.PreviewZoom=1.4;Editor.MountTab.PreviewPanY=45;Editor.MountTab.PreviewPanZ=-25;
        Editor.MountTab.PreviewYaw=12000;Editor.MountTab.PreviewPitch=-2000;
        PC.ConsoleCommand("shot");
    }
    else if(Stage==3)
    {
        OldZoom=Editor.MountTab.PreviewZoom;OldY=Editor.MountTab.PreviewPanY;OldZ=Editor.MountTab.PreviewPanZ;
        OldYaw=Editor.MountTab.PreviewYaw;OldPitch=Editor.MountTab.PreviewPitch;OldDistance=Editor.MountTab.PreviewDistance;
        Passenger=Editor.GetVehicleWeapons(false,2);Editor.MountTab.ResetMount(None);W=Editor.GetVehicleWeapons(true,0);
        Check(W.MountOffset==vect(0,0,0) && W.MountRotation==rot(0,0,0) && W.MountScale==1,"restore defaults resets only current mount values");
        Check(W.bCustomProjectiles && W.bUseOriginalAppearance && W.Mode[0]=="XWeapons.FlakShell","restore mount preserves projectile and appearance settings");
        Check(Editor.GetVehicleWeapons(false,2).MountOffset==Passenger.MountOffset,"restore mount preserves other mount values");
        Check(Editor.MountTab.PreviewZoom==OldZoom && Editor.MountTab.PreviewPanY==OldY && Editor.MountTab.PreviewPanZ==OldZ &&
            Editor.MountTab.PreviewYaw==OldYaw && Editor.MountTab.PreviewPitch==OldPitch && Editor.MountTab.PreviewDistance==OldDistance,"restore values preserves all viewport state");
        W.MountOffset=vect(12,-6,30);W.MountRotation=rot(0,4096,0);W.MountScale=0.85;
        W.WeaponClass="Onslaught.ONSRVWebLauncher";W.bUseOriginalAppearance=false;Editor.SetMount(0,W);Editor.UpdateDisplay();
        Editor.SaveWithoutClosing(None);GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.WeapTab,true);
    }
    else if(Stage==4)
    {
        PC.ConsoleCommand("shot");Editor.SaveAndClose(None);Hub.OpenMotorpool(None);Pool=WoRM_vCfgFix(Menus.TopPage());
        Check(Pool.bInGroupFirst && moCheckBox(Pool.Controls[37]).IsChecked(),"In group first defaults on in model and checkbox");
        Pool.CurrentSlot=3;Pool.SelectedPoolTexts[3]="Onslaught.ONSHoverTank|" $ AKey $ "|" $ BKey;
        Pool.HighlightedVehicleClasses[3]=AKey;Pool.UpdateSelectedDetails();Pool.UpdateGroupControls();
    }
    else if(Stage==5)
    {
        Check(Pool.PreviewWeapons[0].Mesh==class'ONSRVWebLauncher'.default.Mesh,"Motorpool variant shows saved replacement gun mesh");
        Check(Pool.PreviewWeapons[0].RelativeLocation==vect(12,-6,30) && Pool.PreviewWeapons[0].RelativeRotation.Yaw==4096,"Motorpool variant shows saved mount transform");
        Check(Abs(Pool.PreviewWeapons[0].DrawScale-class'ONSRVWebLauncher'.default.DrawScale*0.85)<0.001,"Motorpool variant shows saved mount scale");
        Check(Abs(Pool.PreviewInput.ActualTop()-Pool.PreviewViewTop)<1 && Abs(Pool.PreviewInput.ActualHeight()-Pool.PreviewViewHeight)<1,"Motorpool input and drawn viewport bounds match");
        Pool.bSpinPreview=false;
        Hover(Pool.PreviewViewLeft+Pool.PreviewViewWidth*0.5,Pool.PreviewViewTop-35);
    }
    else if(Stage==6)
    {
        Check(!Pool.MouseInsidePreview(),"real pointer above viewport is outside");VerifyHover(Menus,Pool.PreviewInput,false);PC.ConsoleCommand("shot");
        OldPoolRotation=Pool.PreviewActor.Rotation;
        Hover(Pool.PreviewViewLeft+Pool.PreviewViewWidth*0.7,Pool.PreviewViewTop+Pool.PreviewViewHeight*0.7,true);
    }
    else if(Stage==7)
    {
        Check(Pool.PreviewActor.Rotation!=OldPoolRotation,"real inside drag rotates Motorpool model");
        Check(Pool.MouseInsidePreview(),"real pointer inside viewport is inside");VerifyHover(Menus,Pool.PreviewInput,true);PC.ConsoleCommand("shot");
        Hover(Pool.PreviewViewLeft+Pool.PreviewViewWidth*0.5,Pool.PreviewViewTop+Pool.PreviewViewHeight+22);
    }
    else if(Stage==8)
    {
        Check(!Pool.MouseInsidePreview(),"real pointer below viewport is outside");VerifyHover(Menus,Pool.PreviewInput,false);PC.ConsoleCommand("shot");
        Pool.HighlightedVehicleClasses[3]="Onslaught.ONSHoverTank";Pool.UpdateSelectedDetails();
        Check(Pool.PreviewWeapons[0].Mesh==class'ONSHoverTankCannon'.default.Mesh,"base vehicle retains base gun preview");
        Check(Pool.PreviewWeapons[0].RelativeLocation==vect(0,0,0),"base vehicle retains base mount preview");
        Pool.UpdatePreview("Onslaught.ONSManualGunPawn");
        Check(Pool.PreviewActor.Mesh==class'ONSAttackCraftGun'.default.Mesh,"Motorpool node turret shows saved replacement gun");
        Pool.HighlightedVehicleClasses[3]=AKey;Pool.UpdateSelectedDetails();Pool.OpenHighlightedTuning(None);Editor=VSGUI(Menus.TopPage());
        W=Editor.GetVehicleWeapons(true,0);W.WeaponClass="Custom";W.bUseOriginalAppearance=true;
        Editor.SetMount(0,W);Editor.SaveAndClose(None);
    }
    else if(Stage==9)
    {
        Check(Menus.TopPage()==Pool,"Save Close returns to Motorpool");
        Check(Pool.PreviewWeapons[0].Mesh==class'ONSHoverTankCannon'.default.Mesh,"same variant refreshes saved appearance on returning from tuning");
        Check(Pool.PreviewWeapons[0].RelativeLocation==vect(12,-6,30),"original appearance retains adjusted muzzle mount");
        Hover(Pool.Controls[49].ActualLeft()+Pool.Controls[49].ActualWidth()*0.5,Pool.Controls[49].ActualTop()+Pool.Controls[49].ActualHeight()*0.5);
    }
    else if(Stage==10)
    {
        Log("[PreviewPolish] SAVE HOVER" @ Menus.MouseX @ Menus.MouseY @ "state=" $ Pool.Controls[49].MenuState @ "active=" $ Menus.ActiveControl);
        Check(Menus.MouseX>=Pool.Controls[49].ActualLeft() && Menus.MouseX<Pool.Controls[49].ActualLeft()+Pool.Controls[49].ActualWidth() &&
            Menus.MouseY>=Pool.Controls[49].ActualTop() && Menus.MouseY<Pool.Controls[49].ActualTop()+Pool.Controls[49].ActualHeight(),"real pointer hovers colored Save button");PC.ConsoleCommand("shot");
        Pool.OpenHighlightedTuning(None);Editor=VSGUI(Menus.TopPage());
        GUITabControl(Editor.Controls[3]).ActivateTabByPanel(Editor.MainTab,true);
        Editor.MainTab.bSpinPreview=false;
    }
    else if(Stage==11)
        Hover(Editor.MainTab.PreviewViewLeft+Editor.MainTab.PreviewViewWidth+10,Editor.MainTab.PreviewViewTop+30);
    else if(Stage==12)
    {
        Check(!Editor.MainTab.MouseInsidePreview(),"real pointer beside tuning viewport is outside");VerifyHover(Menus,Editor.MainTab.PreviewInput,false);PC.ConsoleCommand("shot");
        OldYaw=Editor.MainTab.PreviewYaw;
        Hover(Editor.MainTab.PreviewViewLeft+Editor.MainTab.PreviewViewWidth*0.5,Editor.MainTab.PreviewViewTop+Editor.MainTab.PreviewViewHeight*0.5,true);
    }
    else if(Stage==13)
    {
        Check(Editor.MainTab.PreviewYaw!=OldYaw,"real inside drag rotates tuning model");
        Check(Editor.MainTab.MouseInsidePreview(),"real pointer in tuning viewport is inside");VerifyHover(Menus,Editor.MainTab.PreviewInput,true);PC.ConsoleCommand("shot");
        Editor.CancelAndClose(None);Pool.CancelAndClose(None);
        Log("[PreviewPolish] RESULT failures=" $ Failures);PC.ConsoleCommand("exit");return;
    }
    Stage++;
}
