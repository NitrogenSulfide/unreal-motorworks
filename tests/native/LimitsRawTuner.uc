// Fixture-only legacy configuration injection; never shipped to players.
class LimitsRawTuner extends VehicleStuffFix;
function BeginPlay() {}
simulated function PostBeginPlay() {}
function SetRaw(VehicleStuffFix.VehicleProperties VP) { VPs[0]=VP;VPsLength=1; }
