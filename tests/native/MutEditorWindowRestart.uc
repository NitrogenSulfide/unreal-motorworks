class MutEditorWindowRestart extends Mutator;
var int Failures;
function Check(bool OK,string Message) { if(OK)Log("[EditorWindow] PASS"@Message);else{Failures++;Log("[EditorWindow] FAIL"@Message);} }
function PostBeginPlay(){SetTimer(2,false);}
function Timer()
{
 local string Key;
 local int Count;
 local MutWoRM_vFix M;
 local VehicleStuffFix.VehicleProperties VP;
 Count=class'VehicleStuffFix'.default.DeletedVariantKeys.Length;
 Check(Count>0,"deletion journal survives process restart");
 if(Count>0)Key=class'VehicleStuffFix'.default.DeletedVariantKeys[Count-1];
 Check(!class'VehicleStuffFix'.static.HasDefaultProfile(Key),"deleted profile remains absent after restart");
 Check(class'MutWoRM_vFix'.default.ReplacementPoolClassNames[3]=="Onslaught.ONSHoverTank|Onslaught.ONSHoverBike","startup repairs stale group from durable journal");
 Check(class'MutWoRM_vFix'.default.VehicleGroupPresets[0].PoolClassNames[3]=="Onslaught.ONSHoverTank|Onslaught.ONSHoverBike","held preset survives restart with other members in order");
 // Reusing a deleted highest ID must not cause its new reference to disappear.
 VP=class'VehicleStuffFix'.static.GetDefaultProfile(0);
 VP.VehicleClass=class'VehicleStuffFix'.static.BaseClassPath(Key);VP.ProfileId=class'VehicleStuffFix'.static.KeyProfileId(Key);
 Count=class'VehicleStuffFix'.default.VPsLength;
 class'VehicleStuffFix'.static.SetVPElement(Count,VP);class'VehicleStuffFix'.default.VPsLength=Count+1;
 class'MutWoRM_vFix'.default.ReplacementPoolClassNames[3]="Onslaught.ONSHoverTank|"$Key$"|Onslaught.ONSHoverBike";
 foreach DynamicActors(class'MutWoRM_vFix',M)break;
 if(M!=None){M.ProcessedDeletionCount=0;M.ProcessConfirmedVariantDeletions();}
 Check(M!=None && InStr(class'MutWoRM_vFix'.default.ReplacementPoolClassNames[3],Key)>=0,"recreated variant with reused ID wins over old journal");
 Log("[EditorWindow] RESULT failures="$Failures);ConsoleCommand("exit");
}
