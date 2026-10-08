class MutMotorworksNetworkTest extends MutVehicleSuiteFeatureTest;
var NetworkProbe Probe;
var int Ticks, Ack, ClientChecks, ClientFailures, TestFactory;
event PreBeginPlay()
{
 local int i;
 local VehicleStuffFix.VehicleProperties VP;
 Super.PreBeginPlay();
 VP=class'VehicleStuffFix'.static.GetDefaultProfile(1);
 VP.DWeapons[0].WeaponClass="Custom";
 VP.DWeapons[0].Mode[0]="XWeapons.FlakShell";
 VP.DWeapons[0].Mode[1]="XWeapons.RocketProj";
 VP.DWeapons[0].Rate[0]=0.60;
 VP.DWeapons[0].Rate[1]=0.90;
 VP.DWeapons[0].bUseOriginalAppearance=true;
 class'VehicleStuffFix'.static.SetVPElement(1,VP);
 for(i=0;i<11;i++) class'MutWoRM_vFix'.default.WoRMVehClassName[i]=string(class'MutWoRM_vFix'.default.ReplacedVehicleClass[i]);
}
function PostBeginPlay() { AddToPackageMap("MotorworksNetworkTest"); AddToPackageMap("VehicleStuffFix"); Stage=0; TestFactory=-1; SetTimer(1,true); }
function Receive(int P,int C,int F) { Ack=P; ClientChecks=C; ClientFailures=F; }
function Timer()
{
 local PlayerController PC;
 local int i,Index;
 local ONSVehicle V;
 local VehicleStuffFix.VehicleProperties VP;
 Ticks++;
 if(Probe!=None && Ticks%10==0) Log("[MotorworksNetworkServer] stage=" $ Stage $ " probePhase=" $ Probe.Phase $ " target=" $ Probe.Target $ " remote=" $ Probe.RemoteRole);
 if(Ticks>120)
 {
  Log("[MotorworksNetworkServer] RESULT timeout stage=" $ Stage $ " client_checks=" $ ClientChecks);
  ConsoleCommand("exit"); return;
 }
 foreach DynamicActors(class'MutWoRM_vFix',Motorpool) break;
 foreach DynamicActors(class'VehicleStuffFix',Tuner) break;
 if(Motorpool==None || Tuner==None) return;
 if(Probe==None)
 {
  foreach DynamicActors(class'PlayerController',PC)
   if(PC.Player!=None && !PC.IsA('DemoRecSpectator')) break;
  if(PC==None || PC.Player==None) return;
  Probe=Spawn(class'NetworkProbe',PC); Probe.Harness=self;
  Log("[MotorworksNetworkServer] probe=" $ Probe $ " remote=" $ Probe.RemoteRole $ " owner=" $ Probe.Owner $ " player=" $ PC.Player);
  Check(Level.NetMode==NM_DedicatedServer,"real dedicated server");
  for(i=0;i<Motorpool.VehicleFactories.Length;i++)
   if(Motorpool.VehicleFactories[i].Factory.VehicleClass==class'ONSHoverTank')
   {
    TestFactory=i;
    Motorpool.VehicleFactories[i].Factory.bActive=true;
    Motorpool.VehicleFactories[i].Factory.TeamNum=0;
    if(Motorpool.VehicleFactories[i].Factory.LastSpawned==None) Motorpool.VehicleFactories[i].Factory.SpawnVehicle();
    break;
   }
  Check(TestFactory>=0,"stock tank factory found");
  Stage=1; return;
 }
 if(Stage==1 && TestFactory>=0)
 {
  V=ONSVehicle(Motorpool.VehicleFactories[TestFactory].Factory.LastSpawned);
  if(V==None || V.Health!=1000) return;
  V.bAlwaysRelevant=true;
  PC=PlayerController(Probe.Owner); PC.SetViewTarget(V); PC.ClientSetViewTarget(V);
  Probe.Target=V; Probe.TargetWeapon=V.Weapons[0]; Probe.ExpectedHealth=V.Health; Probe.ExpectedMax=V.HealthMax; Probe.Phase=1;
  Stage=2; return;
 }
 if(Stage==2 && Ack==1)
 {
  Probe.Target.Destroy(); Probe.Target=None;
  Motorpool.VehicleFactories[TestFactory].Factory.LastSpawned=None;
  Motorpool.VehicleFactories[TestFactory].bWaitingForSpawn=false;
  Motorpool.Timer();
  Check(Motorpool.RuntimeProfileIds[Motorpool.VehicleFactories[TestFactory].CurrentPoolIndex]==1,"factory advances to variant on respawn");
  Motorpool.VehicleFactories[TestFactory].Factory.SpawnVehicle(); Stage=3; return;
 }
 if(Stage==3)
 {
  V=ONSVehicle(Motorpool.VehicleFactories[TestFactory].Factory.LastSpawned);
  if(V==None || V.Weapons.Length==0 || V.Weapons[0]==None || CustomVehicleWeapon(V.Weapons[0])==None || !CustomVehicleWeapon(V.Weapons[0]).bSetupReady) return;
  Check(V.Health>=1600 && V.Health<=2400,"server variant health roll");
  V.bAlwaysRelevant=true;
  PC=PlayerController(Probe.Owner); PC.SetViewTarget(V); PC.ClientSetViewTarget(V);
  Probe.Target=V; Probe.TargetWeapon=V.Weapons[0]; Probe.ExpectedHealth=V.Health; Probe.ExpectedMax=V.HealthMax;
  Probe.ExpectedScale=class'ONSHoverTankCannon'.default.DrawScale*0.75; Probe.Phase=2; Stage=4; return;
 }
 if(Stage==4 && Ack==2)
 {
  V=Probe.Target;
  VP=class'VehicleStuffFix'.static.GetDefaultProfile(1);
  VP.DWeapons[0].WeaponClass="Onslaught.ONSAttackCraftGun";
  VP.DWeapons[0].bUseOriginalAppearance=true;
  VP.PWeapons[0].WeaponClass="Onslaught.ONSAttackCraftGun";
  VP.PWeapons[0].bUseOriginalAppearance=true;
  Tuner.SetLiveProfile(1,VP);Tuner.ChangeVehicleProps(V,1);
  Check(V.Weapons[0].Class==class'ONSAttackCraftGun' && V.Weapons[0].Mesh==class'ONSHoverTankCannon'.default.Mesh,"ordinary replacement keeps behavior class and gets stock driver mesh");
  Check(V.WeaponPawns[0].Gun.Class==class'ONSAttackCraftGun' && V.WeaponPawns[0].Gun.Mesh==class'ONSTankSecondaryTurret'.default.Mesh,"ordinary passenger replacement gets original mesh");
  Probe.TargetWeapon=V.Weapons[0];Probe.TargetPassenger=V.WeaponPawns[0].Gun;
  Probe.Phase=6;Stage=8;return;
 }
 if(Stage==8 && Ack==6)
 {
  V=Probe.Target;
  VP=class'VehicleStuffFix'.static.GetDefaultProfile(1);
  VP.DWeapons[0].bUseOriginalAppearance=false;
  VP.PWeapons[0].bUseOriginalAppearance=false;
  Tuner.SetLiveProfile(1,VP);Tuner.ChangeVehicleProps(V,1);
  Probe.TargetWeapon=V.Weapons[0];Probe.TargetPassenger=V.WeaponPawns[0].Gun;
  Probe.ExpectedScale=class'ONSAttackCraftGun'.default.DrawScale*0.75;
  Probe.Phase=7;Stage=9;return;
 }
 if(Stage==9 && Ack==7)
 {
  PC=PlayerController(Probe.Owner);PC.PlayerReplicationInfo.bAdmin=True;
  Probe.Phase=3;Stage=5;return;
 }
 if(Stage==5 && Ack==3)
 {
  Index=Tuner.FindVehicleFromClass("Onslaught.ONSHoverTank");
  Check(Index>=0,"saved tank profile exists on server");
  if(Index>=0) VP=class'VehicleStuffFix'.static.GetDefaultProfile(Index);
  Check(Index>=0 && VP.Health==2345,"remote Save committed acknowledged health on server");
  PC=PlayerController(Probe.Owner);PC.PlayerReplicationInfo.bAdmin=False;
  Probe.Phase=4;Stage=6;return;
 }
 if(Stage==6 && Ack==4)
 {
  Index=Tuner.FindVehicleFromClass("Onslaught.ONSHoverTank");
  Check(Index>=0,"saved tank profile exists on server");
  if(Index>=0) VP=class'VehicleStuffFix'.static.GetDefaultProfile(Index);
  Check(Index>=0 && VP.Health==2345,"rejected remote Save preserves server settings");
  Log("[MotorworksNetworkServer] RESULT server_failures=" $ Failures $ " client_checks=" $ ClientChecks $ " client_failures=" $ ClientFailures);
  Probe.Phase=5;Stage=7;Ticks=0;return;
 }
 if(Stage==7 && Ticks>4) ConsoleCommand("exit");
}

defaultproperties { bAddToServerPackages=True }
