class VehicleSuiteConfig extends PopupPageBase;

function bool HasLiveVehicleStuff()
{
	local Mutator M;
	local class<Mutator> VehicleStuffClass;

	VehicleStuffClass = class<Mutator>(DynamicLoadObject("VehicleStuffFix.VehicleStuffFix", class'Class', true));
	if ((VehicleStuffClass == None) || (PlayerOwner() == None))
		return false;

	foreach PlayerOwner().DynamicActors(class'Mutator', M)
		if (M.Class == VehicleStuffClass)
			return true;

	return false;
}

function bool OpenMotorpool(GUIComponent Sender)
{
	Controller.OpenMenu("WoRM2k4Fix.WoRM_vCfgFix");
	return true;
}

function bool OpenVehicleTuning(GUIComponent Sender)
{
	if (HasLiveVehicleStuff())
		PlayerOwner().ConsoleCommand("mutate VehicleStuffFix Config");
	else
		Controller.OpenMenu("VehicleStuffFix.VSGUI");
	return true;
}

function bool OpenCredits(GUIComponent Sender)
{
	Controller.OpenMenu("VehicleStuffFix.VSLegacyCredits");
	return true;
}

function bool CloseHub(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}

function bool LayoutHub(Canvas C)
{
    local int i;
    bBoundToParent = false;
    bScaleToParent = false;
    bNeverScale = true;
    SetPosition(0, 0, C.ClipX, C.ClipY);
    for (i = 0; i < Controls.Length; i++)
    {
        Controls[i].bBoundToParent = false;
        Controls[i].bScaleToParent = false;
        Controls[i].bNeverScale = true;
    }
    Controls[0].SetPosition(0, 0, C.ClipX, C.ClipY);
    Controls[1].SetPosition(0, 0, C.ClipX, C.ClipY);
    Controls[2].SetPosition(C.ClipX * 0.22, C.ClipY * 0.045, C.ClipX * 0.56, C.ClipY * 0.09);
    Controls[9].SetPosition(C.ClipX * 0.82, C.ClipY * 0.04, C.ClipX * 0.15, C.ClipY * 0.07);
    Controls[3].SetPosition(C.ClipX * 0.135, C.ClipY * 0.20, C.ClipX * 0.73, C.ClipY * 0.13);
    Controls[4].SetPosition(C.ClipX * 0.135, C.ClipY * 0.35, C.ClipX * 0.73, C.ClipY * 0.04);
    Controls[5].SetPosition(C.ClipX * 0.135, C.ClipY * 0.45, C.ClipX * 0.73, C.ClipY * 0.13);
    Controls[6].SetPosition(C.ClipX * 0.135, C.ClipY * 0.60, C.ClipX * 0.73, C.ClipY * 0.04);
    Controls[7].SetPosition(C.ClipX * 0.135, C.ClipY * 0.70, C.ClipX * 0.73, C.ClipY * 0.05);
    Controls[8].SetPosition(C.ClipX * 0.30, C.ClipY * 0.83, C.ClipX * 0.40, C.ClipY * 0.09);
    return true;
}

defaultproperties
{
	Begin Object Class=GUIImage Name=HubOpaqueBackground
		Image=Texture'Engine.WhiteSquareTexture'
		ImageColor=(R=8,G=20,B=55,A=255)
		ImageStyle=ISTY_Stretched
		ImageRenderStyle=MSTY_Normal
		WinTop=0.140000
		WinLeft=0.170000
		WinWidth=0.660000
		WinHeight=0.720000
		bAcceptsInput=False
		bNeverFocus=True
	End Object
	Controls(0)=GUIImage'VehicleSuite.VehicleSuiteConfig.HubOpaqueBackground'

	Begin Object Class=GUIButton Name=HubBackground
		StyleName="SquareBar"
		WinTop=0.140000
		WinLeft=0.170000
		WinWidth=0.660000
		WinHeight=0.720000
		bAcceptsInput=False
		bNeverFocus=True
	End Object
	Controls(1)=GUIButton'VehicleSuite.VehicleSuiteConfig.HubBackground'

	Begin Object Class=VSScaledLabel Name=HubTitle
		Caption="UNREAL MOTORWORKS"
		TextAlign=TXTA_Center
		TextColor=(R=255,G=255,B=0,A=255)
		FontScale=FNS_Large
		WinTop=0.180000
		WinLeft=0.220000
		WinWidth=0.480000
		WinHeight=0.060000
	End Object
	Controls(2)=VSScaledLabel'VehicleSuite.VehicleSuiteConfig.HubTitle'

	Begin Object Class=VSScaledButton Name=CreditsButton
		Caption="Credits"
		bRedFill=True
		Hint="View Unreal Motorworks and original mod credits."
		WinTop=0.170000
		WinLeft=0.700000
		WinWidth=0.105000
		WinHeight=0.050000
		bNeverFocus=True
		OnClick=VehicleSuiteConfig.OpenCredits
	End Object
	Controls(9)=VSScaledButton'VehicleSuite.VehicleSuiteConfig.CreditsButton'

	Begin Object Class=VSScaledButton Name=MotorpoolButton
		Caption="Motorpool Remastered"
		Hint="Choose which vehicle classes replace each stock factory slot."
		WinTop=0.285000
		WinLeft=0.260000
		WinWidth=0.480000
		WinHeight=0.095000
		bNeverFocus=True
		OnClick=VehicleSuiteConfig.OpenMotorpool
	End Object
	Controls(3)=VSScaledButton'VehicleSuite.VehicleSuiteConfig.MotorpoolButton'

	Begin Object Class=GUILabel Name=MotorpoolDescription
		Caption="Replacement groups choose the vehicle before its factory spawns it."
		TextAlign=TXTA_Center
		TextColor=(R=210,G=220,B=245,A=255)
		FontScale=FNS_Small
		WinTop=0.385000
		WinLeft=0.230000
		WinWidth=0.540000
		WinHeight=0.035000
	End Object
	Controls(4)=GUILabel'VehicleSuite.VehicleSuiteConfig.MotorpoolDescription'

	Begin Object Class=VSScaledButton Name=VehicleTuningButton
		Caption="Vehicle Tuning & Weapons"
		Hint="Tune vehicle properties and weapon assignments with VehicleStuff Fix."
		WinTop=0.460000
		WinLeft=0.260000
		WinWidth=0.480000
		WinHeight=0.095000
		bNeverFocus=True
		OnClick=VehicleSuiteConfig.OpenVehicleTuning
	End Object
	Controls(5)=VSScaledButton'VehicleSuite.VehicleSuiteConfig.VehicleTuningButton'

	Begin Object Class=GUILabel Name=VehicleTuningDescription
		Caption="VehicleStuff tunes the actual vehicle instance after it appears."
		TextAlign=TXTA_Center
		TextColor=(R=210,G=220,B=245,A=255)
		FontScale=FNS_Small
		WinTop=0.560000
		WinLeft=0.230000
		WinWidth=0.540000
		WinHeight=0.035000
	End Object
	Controls(6)=GUILabel'VehicleSuite.VehicleSuiteConfig.VehicleTuningDescription'

	Begin Object Class=GUILabel Name=NextMapNotice
		Caption="Motorpool changes made during a match take effect when the next map starts."
		TextAlign=TXTA_Center
		TextColor=(R=255,G=190,B=80,A=255)
		FontScale=FNS_Small
		WinTop=0.625000
		WinLeft=0.220000
		WinWidth=0.560000
		WinHeight=0.040000
	End Object
	Controls(7)=GUILabel'VehicleSuite.VehicleSuiteConfig.NextMapNotice'

	Begin Object Class=VSScaledButton Name=CloseButton
		Caption="Close"
		WinTop=0.715000
		WinLeft=0.370000
		WinWidth=0.260000
		WinHeight=0.070000
		bNeverFocus=True
		OnClick=VehicleSuiteConfig.CloseHub
	End Object
	Controls(8)=VSScaledButton'VehicleSuite.VehicleSuiteConfig.CloseButton'

	OnPreDraw=VehicleSuiteConfig.LayoutHub
	bAllowedAsLast=True
	WinTop=0.000000
	WinLeft=0.000000
	WinWidth=1.000000
	WinHeight=1.000000
}
