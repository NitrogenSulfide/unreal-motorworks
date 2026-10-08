// Exercise native tab transitions and reject edits to mounts absent from the vehicle.
class MutWeaponSlotStateTest extends MutCustomProjectileTest;
var VehicleStuffFix.VehicleProperties BeforeTabs;
function CheckSlots(string Context)
{
 local int i;local moComboBox Box;
 for(i=1;i<6;i++)
 {
  if(i==2)continue; // The stock Goliath has one passenger turret.
  Box=moComboBox(Editor.WeapTab.Controls[i]);
  Check(Box.MenuState==MSAT_Disabled && Box.MyComboBox.MenuState==MSAT_Disabled && Box.MyComboBox.Edit.MenuState==MSAT_Disabled && Box.MyComboBox.MyShowListBtn.MenuState==MSAT_Disabled,Context @ "keeps absent slot" @ i @ "and its children disabled");
  Check(Editor.WeapTab.Controls[i+6].MenuState==MSAT_Disabled && Editor.WeapTab.Controls[i+12].MenuState==MSAT_Disabled && Editor.WeapTab.Controls[i+18].MenuState==MSAT_Disabled && Editor.WeapTab.Controls[i+24].MenuState==MSAT_Disabled,Context @ "keeps absent slot options disabled" @ i);
 }
 Check(Editor.WeapTab.Controls[0].MenuState!=MSAT_Disabled && Editor.WeapTab.Controls[2].MenuState!=MSAT_Disabled,Context @ "retains valid driver and passenger controls");
 Check(Editor.ProfilesEqual(BeforeTabs,Editor.GetCurrentVP()),Context @ "preserves exact profile");
}
function Timer()
{
 local PlayerController PC;local GUIController Menus;local moComboBox Box;local int i;local VehicleStuffFix.VehicleProperties VP;
 foreach DynamicActors(class'PlayerController',PC)if(PC.Player!=None)break;
 if(PC==None || PC.Player==None)return;
 Menus=GUIController(PC.Player.GUIController);
 if(Stage==0){Super.Timer();BeforeTabs=Editor.GetCurrentVP();return;}
 else if(Stage==1){CheckSlots("initial Weapons");Cue(Editor.MainTab.MyButton);}
 else if(Stage==2)Cue(Editor.WeapTab.MyButton);
 else if(Stage==3){CheckSlots("Vehicle to Weapons");PC.ConsoleCommand("shot");Cue(Editor.MountTab.MyButton);}
 else if(Stage==4)Cue(Editor.WeapTab.MyButton);
 else if(Stage==5){CheckSlots("Placement to Weapons");PC.ConsoleCommand("shot");Cue(moComboBox(Editor.WeapTab.Controls[1]).MyComboBox.Edit);}
 else if(Stage==6)
 {
  Box=moComboBox(Editor.WeapTab.Controls[1]);
  Check(!Box.MyComboBox.MyListBox.bVisible,"physical click cannot open absent weapon dropdown");
  // Native callbacks can arrive during focus invalidation. They must not write a slot.
  Box.SetIndex(1);
  Editor.SetWeaponClass("Onslaught.ONSAttackCraftGun",1);
  Editor.SetWeaponOccupantHidden(1,true);
  Check(Editor.ProfilesEqual(BeforeTabs,Editor.GetCurrentVP()),"absent mount rejects selection callbacks and direct setters");
  Editor.UpdateDisplay();
  for(i=0;i<3;i++) {Editor.WeapTab.ShowPanel(false);Editor.WeapTab.ShowPanel(true);Editor.WeapTab.MyButton.ChangeActiveState(true,true);}
 }
 else if(Stage==7){CheckSlots("repeated visibility and focus");PC.ConsoleCommand("shot");}
 else if(Stage==8)
 {
  VP=Editor.GetCurrentVP();VP.VehicleClass="VehicleSuiteTest.SlotStateDualGunTank";
  VP.DWeapons[1].WeaponClass="Onslaught.ONSAttackCraftGun";
  Editor.SetCurrentVP(VP);Editor.UpdateDisplay();
 }
 else if(Stage==9)Cue(Editor.MainTab.MyButton);
 else if(Stage==10)Cue(Editor.WeapTab.MyButton);
 else if(Stage==11)
 {
  Box=moComboBox(Editor.WeapTab.Controls[1]);
  Check(Box.MenuState!=MSAT_Disabled && Box.MyComboBox.Edit.MenuState!=MSAT_Disabled && Box.MyComboBox.MyShowListBtn.MenuState!=MSAT_Disabled,"real second driver mount remains editable after tab roundtrip");
  Check(Editor.WeapTab.Controls[7].MenuState!=MSAT_Disabled && Editor.WeapTab.Controls[13].MenuState!=MSAT_Disabled && Editor.WeapTab.Controls[19].MenuState!=MSAT_Disabled && Editor.WeapTab.Controls[25].MenuState!=MSAT_Disabled,"real second driver mount retains all supported options");
  Editor.SetWeaponClass("Onslaught.ONSHoverTankCannon",1);
  Check(Editor.GetCurrentVP().DWeapons[1].WeaponClass=="Onslaught.ONSHoverTankCannon","supported second driver mount still accepts gun changes");
 }
 else if(Stage==12){Finish(PC);return;}
 Stage++;
}
