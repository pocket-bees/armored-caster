ScriptName _ArmoredCaster_MCM_Quest extends MCM_ConfigBase

; Read-only properties for MCM display
string Property strBootWeightRatio = "uninitialized" Auto
string Property strCuirassWeightRatio = "uninitialized" Auto
string Property strGauntletWeightRatio = "uninitialized" Auto
string Property strHelmetWeightRatio = "uninitialized" Auto
string Property strShieldWeightRatio = "uninitialized" Auto

; Constants for slots
int mskBoot 	= 0x080
int mskCuirass 	= 0x004
int mskGauntlet = 0x008
int mskHelmet 	= 0x002
int mskShield   = 0x200

; Version info
int major_version = 0
int minor_version = 1
int patch_version = 0
string Property strVersion = "uninitialized" Auto

Event OnConfigInit()
	ConsoleUtil.PrintMessage("ArmoredCaster: Initializing MCM")
EndEvent

Event OnConfigOpen()
	; Compute version string
	strVersion = "" + major_version + "." + minor_version + "." + patch_version

	; Fetch current weight ratios to display
	int weightRatioMap = JDB.solveObj(".ArmoredCaster.mapWeightRatios")
	strBootWeightRatio = "" + JIntMap.GetFlt(weightRatioMap, mskBoot)
	strCuirassWeightRatio = "" + JIntMap.GetFlt(weightRatioMap, mskCuirass)
	strGauntletWeightRatio = "" + JIntMap.GetFlt(weightRatioMap, mskGauntlet)
	strHelmetWeightRatio = "" + JIntMap.GetFlt(weightRatioMap, mskHelmet)
	strShieldWeightRatio = "" + JIntMap.GetFlt(weightRatioMap, mskShield)
EndEvent

Event OnSettingChange(string a_ID)
	int handle = ModEvent.Create("_ArmoredCaster_SettingChange")
	ModEvent.PushString(handle, a_ID)
	ModEvent.Send(handle)
EndEvent