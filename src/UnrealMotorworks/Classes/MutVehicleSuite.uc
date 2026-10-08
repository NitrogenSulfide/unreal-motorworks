class MutVehicleSuite extends Mutator config(UnrealMotorworks);

const WoRMMutatorClassName = "UnrealMotorworks.MutWoRM_vFix";
const VehicleStuffMutatorClassName = "UnrealMotorworks.VehicleStuffFix";

var bool bBackendsReady;
var config string VehicleServerPackages[32];
var config string VoiceServerPackages[32];

function RegisterNetworkPackages()
{
	local int i;
	local int VehicleCount;
	local int VoiceCount;

	// Package-map registration is only needed when this game is acting as a
	// server. Leaving standalone mode before touching the arrays keeps normal
	// Instant Action package loading exactly as it was before the suite.
	if (Level.NetMode == NM_Standalone)
	{
		Log("[VehicleSuite] Standalone mode; skipped network package registration.");
		return;
	}

	for (i = 0; i < ArrayCount(VehicleServerPackages); i++)
	{
		if (VehicleServerPackages[i] == "")
			continue;

		AddToPackageMap(VehicleServerPackages[i]);
		VehicleCount++;
		Log("[VehicleSuite] Registered vehicle package for clients:" @ VehicleServerPackages[i]);
	}

	for (i = 0; i < ArrayCount(VoiceServerPackages); i++)
	{
		if (VoiceServerPackages[i] == "")
			continue;

		AddToPackageMap(VoiceServerPackages[i]);
		VoiceCount++;
		Log("[VehicleSuite] Registered voice package for clients:" @ VoiceServerPackages[i]);
	}

	Log("[VehicleSuite] Network package registration complete: vehicles=" $
		VehicleCount $ " voices=" $ VoiceCount);
}

function int CountMutatorClass(class<Mutator> WantedClass)
{
	local Mutator M;
	local int Count;

	if ((WantedClass == None) || (Level.Game == None))
		return 0;

	for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
		if (M.Class == WantedClass)
			Count++;

	return Count;
}

function bool EnsureBackend(string BackendClassName, string BackendLabel)
{
	local class<Mutator> BackendClass;
	local int Count;

	BackendClass = class<Mutator>(DynamicLoadObject(BackendClassName, class'Class', true));
	if (BackendClass == None)
	{
		Log("[VehicleSuite] ERROR: Required backend is missing:" @ BackendClassName);
		return false;
	}

	Count = CountMutatorClass(BackendClass);
	if (Count == 0)
	{
		Level.Game.AddMutator(BackendClassName, false);
		Count = CountMutatorClass(BackendClass);
	}

	if (Count != 1)
	{
		Log("[VehicleSuite] ERROR:" @ BackendLabel @ "backend count is" @ Count @ "instead of 1.");
		return false;
	}

	Log("[VehicleSuite] Ready:" @ BackendLabel @ "->" @ BackendClassName);
	return true;
}

function PostBeginPlay()
{
	local bool bWoRMReady;
	local bool bVehicleStuffReady;

	Super.PostBeginPlay();
	RegisterNetworkPackages();

	if (Level.Game == None)
	{
		Log("[VehicleSuite] ERROR: No active GameInfo; backends were not started.");
		return;
	}

	// GameInfo adds this coordinator to the chain after Spawn() completes. Adding
	// the two backends here therefore places their independent timers ahead of
	// the suite without copying either runtime into this class.
	bWoRMReady = EnsureBackend(WoRMMutatorClassName, "Motorpool Remastered");
	bVehicleStuffReady = EnsureBackend(VehicleStuffMutatorClassName, "VehicleStuff tuning");
	bBackendsReady = bWoRMReady && bVehicleStuffReady;

	if (bBackendsReady)
		Log("[VehicleSuite] All backends are active exactly once.");
	else
		Log("[VehicleSuite] ERROR: Suite startup is incomplete; review the preceding backend errors.");
}

function Mutate(string MutateString, PlayerController Sender)
{
	if ((MutateString ~= "VehicleSuite Config") && (Sender != None) &&
		((Level.NetMode == NM_Standalone) ||
		 ((Sender.PlayerReplicationInfo != None) && Sender.PlayerReplicationInfo.bAdmin)))
	{
		Sender.ClientOpenMenu("UnrealMotorworks.VehicleSuiteConfig");
	}

	Super.Mutate(MutateString, Sender);
}

defaultproperties
{
	// General-purpose defaults: extra client packages are opt-in server settings.
	// Keep both arrays empty so a new installation has no custom-content dependency.
	bAddToServerPackages=True
	ConfigMenuClassName="UnrealMotorworks.VehicleSuiteConfig"
	GroupName="VehicleArena"
	IconMaterialName="MutatorArt.nosym"
	FriendlyName="Unreal Motorworks: Motorpool + Tuning"
	Description="Choose vehicle replacement groups, then tune the spawned vehicles with VehicleStuff through one configuration hub."
}
