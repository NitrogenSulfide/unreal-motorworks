class MutVehicleSuiteFeatureTest extends Mutator;

var int Stage, Failures, VariantState;
var MutWoRM_vFix Motorpool;
var VehicleStuffFix Tuner;
var ONSStationaryWeaponPawn NodeTurret;
var ASTurret_Minigun MiniTurret;
var int StableHealth;

function Check(bool Condition, string Message)
{
    if (!Condition) { Failures++; Log("[VehicleSuiteFeatures] FAIL" @ Message); }
    else Log("[VehicleSuiteFeatures] PASS" @ Message);
}

event PreBeginPlay()
{
    local VehicleStuffFix.VehicleProperties VP;
    local int Slot;
    local bool NoCustomDefaults;
    Super.PreBeginPlay();
    NoCustomDefaults = true;
    for (Slot = 0; Slot < 32; Slot++)
        if (class'MutVehicleSuite'.default.VehicleServerPackages[Slot] != "" ||
            class'MutVehicleSuite'.default.VoiceServerPackages[Slot] != "")
            NoCustomDefaults = false;
    Check(NoCustomDefaults, "fresh suite has no custom vehicle or voice package defaults");
    VP.VehicleClass = "Onslaught.ONSHoverTank";
    VP.VehicleName = "Feature test base tank";
    VP.Health = 1000;
    VP.SpeedScale = 1;
    VP.Friction = 1;
    VP.Mass = 1;
    VP.WheelScale = 1;
    VP.JumpHeight = 1;
    VP.HoverHeight = 1;
    VP.DWeapons[0].WeaponClass = "Onslaught.ONSHoverTankCannon";
    VP.PWeapons[0].WeaponClass = "Onslaught.ONSTankSecondaryTurret";
	VP.PWeapons[0].bHideOccupant = True;
    class'VehicleStuffFix'.static.SetVPElement(0, VP);
    VP.ProfileId = 1;
    VP.VehicleName = "Feature test independent variant";
    VP.Health = 2000;
    VP.bRandomHealth = true;
    VP.HealthMin = 0.8;
    VP.HealthMax = 1.2;
    VP.DWeapons[0].WeaponClass = "Onslaught.ONSAttackCraftGun";
    VP.DWeapons[0].MountOffset = vect(12,-6,24);
    VP.DWeapons[0].MountRotation = rot(0,4096,0);
    VP.DWeapons[0].MountScale = 0.75;
    class'VehicleStuffFix'.static.SetVPElement(1, VP);
    VP.ProfileId = 0;
    VP.VehicleClass = "Onslaught.ONSManualGunPawn";
    VP.VehicleName = "Feature test node turret";
    VP.Health = 777;
    VP.bRandomHealth = false;
    VP.DWeapons[0].WeaponClass = "Onslaught.ONSAttackCraftGun";
    VP.DWeapons[0].MountOffset = vect(0,0,0);
    VP.DWeapons[0].MountRotation = rot(0,0,0);
    VP.DWeapons[0].MountScale = 1;
    class'VehicleStuffFix'.static.SetVPElement(2, VP);
    VP.VehicleClass = "UT2k4Assault.ASTurret_Minigun";
    VP.VehicleName = "Feature test minigun turret";
    VP.Health = 888;
    VP.DWeapons[0].WeaponClass = "UT2k4AssaultFull.Weapon_Turret_IonCannon";
    class'VehicleStuffFix'.static.SetVPElement(3, VP);
    class'VehicleStuffFix'.default.VPsLength = 4;
    class'VehicleStuffFix'.default.StationaryProfileIds[0] = 0;
    class'VehicleStuffFix'.default.StationaryProfileIds[1] = 0;
    for (Slot = 0; Slot < 11; Slot++)
        if (class'MutWoRM_vFix'.default.ReplacedVehicleClass[Slot] == class'ONSHoverTank')
        {
            class'MutWoRM_vFix'.default.ReplacementPoolClassNames[Slot] = "Onslaught.ONSHoverTank|Onslaught.ONSHoverTank#1";
            class'MutWoRM_vFix'.default.ReplacementStrategies[Slot] = 0;
        }
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    VariantState = -1;
    Stage = -1;
    SetTimer(3, true);
}

function Timer()
{
    local int i, Index, BaseCount;
    local Vehicle V;
    local ONSVehicle Tank;
    local VSHealthRoll Roll;
    local VehicleStuffFix.VehicleProperties VP;
    local int OldHealth;
    local float OldScale;
    foreach DynamicActors(class'MutWoRM_vFix', Motorpool) break;
    foreach DynamicActors(class'VehicleStuffFix', Tuner) break;
    if (Stage < 0 && Motorpool != None)
    {
        for (i = 0; i < Motorpool.VehicleFactories.Length; i++)
            if (Motorpool.VehicleFactories[i].Factory.VehicleClass == class'ONSHoverTank')
            {
                Motorpool.VehicleFactories[i].Factory.bActive = true;
                Motorpool.VehicleFactories[i].Factory.TeamNum = 0;
                if (Motorpool.VehicleFactories[i].Factory.LastSpawned == None)
                    Motorpool.VehicleFactories[i].Factory.SpawnVehicle();
            }
        Stage = 0;
        return;
    }
    if (Stage == 0)
    {
        Check(Motorpool != None && Tuner != None, "suite backends active");
        if (Motorpool == None || Tuner == None) { ConsoleCommand("exit"); return; }
        VP = class'VehicleStuffFix'.static.GetDefaultProfile(1);
		Check(class'VehicleStuffFix'.static.GetDefaultProfile(0).PWeapons[0].bHideOccupant,
			"per-mount rider hiding is retained in the profile");
        Check(class'VehicleStuffFix'.static.RollHealth(VP, 0) == 1600, "health lower bound");
        Check(class'VehicleStuffFix'.static.RollHealth(VP, 1) == 2400, "health upper bound");
		Check(class'VehicleStuffFix'.static.RoundRandomHealth(3682) == 3700,
			"random health rounds to 50 HP steps");
        for (i = 0; i < Motorpool.VehicleFactories.Length; i++)
        {
            V = Motorpool.VehicleFactories[i].Factory.LastSpawned;
            if (V != None && V.Class == class'ONSHoverTank')
            {
                BaseCount++;
                Check(V.Health == 1000, "base tank keeps its own health");
                if (VariantState < 0) VariantState = i;
            }
        }
        Check(BaseCount >= 2, "multiple base tank factories spawned");
        Check(VariantState >= 0, "variant factory available");
        if (VariantState >= 0)
        {
            V = Motorpool.VehicleFactories[VariantState].Factory.LastSpawned;
            V.Destroy();
            Motorpool.VehicleFactories[VariantState].Factory.LastSpawned = None;
            Motorpool.VehicleFactories[VariantState].bWaitingForSpawn = false;
            Motorpool.Timer();
            Check(Motorpool.RuntimeProfileIds[Motorpool.VehicleFactories[VariantState].CurrentPoolIndex] == 1, "next spawn selects variant ID");
            Motorpool.VehicleFactories[VariantState].Factory.SpawnVehicle();
        }
        foreach AllActors(class'ONSStationaryWeaponPawn', NodeTurret) break;
        MiniTurret = Spawn(class'ASTurret_Minigun',,, vect(0,0,2000));
        Stage++;
        return;
    }
    if (Stage == 1)
    {
        if (VariantState >= 0)
        {
            Tank = ONSVehicle(Motorpool.VehicleFactories[VariantState].Factory.LastSpawned);
            Check(Tank != None, "variant actually spawned");
            if (Tank != None)
            {
                Check(Tank.Health >= 1600 && Tank.Health <= 2400, "variant spawn health within range");
                Check(Tank.HealthMax == Tank.Health, "health maximum matches rolled spawn health");
                Check(Tank.Weapons[0].Class == class'ONSAttackCraftGun', "variant weapon assignment");
                Check(VSize(Tank.Weapons[0].RelativeLocation - vect(12,-6,24)) < 0.1, "live mount translation");
                Check(Tank.Weapons[0].RelativeRotation.Yaw == 4096, "live mount rotation");
                OldScale = Tank.Weapons[0].Default.DrawScale * 0.75;
                Check(Abs(Tank.Weapons[0].DrawScale - OldScale) < 0.001, "live mount scale");
                OldHealth = Tank.Health;
                Index = Tuner.FindVehicleProfile(Tank);
                Tuner.ChangeVehicleProps(Tank, Index);
                Check(Tank.Health == OldHealth, "live apply preserves health roll");
                StableHealth = Tank.Health;
            }
        }
        Check(NodeTurret != None && NodeTurret.Health == 777, "placed node turret health");
        if (NodeTurret != None) Check(NodeTurret.Gun.Class == class'ONSAttackCraftGun', "placed node turret weapon");
        Check(MiniTurret != None && MiniTurret.Health == 888, "stationary minigun health");
        if (MiniTurret != None) Check(MiniTurret.DefaultWeaponClassName == "UT2k4AssaultFull.Weapon_Turret_IonCannon", "stationary minigun weapon mapping");
        foreach DynamicActors(class'VSHealthRoll', Roll)
            if (Roll.Owner == NodeTurret) { NodeTurret.Health = 0; Roll.Timer(); NodeTurret.Health = 450; Roll.Timer(); break; }
        Check(NodeTurret != None && NodeTurret.Health == 777, "same-actor turret respawn reapplies tuning");
        Stage++;
        return;
    }
    if (VariantState >= 0)
    {
        V = Motorpool.VehicleFactories[VariantState].Factory.LastSpawned;
        Check(V != None && V.Health == StableHealth, "timer does not reroll healthy vehicles");
    }
    Log("[VehicleSuiteFeatures] RESULT failures=" $ Failures);
    ConsoleCommand("exit");
}

defaultproperties
{
    FriendlyName="Vehicle Suite isolated feature tests"
}
