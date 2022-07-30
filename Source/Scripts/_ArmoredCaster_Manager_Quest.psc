ScriptName _ArmoredCaster_Manager_Quest Extends Quest

; Properties defining each armor slot's reference weight, used to determine
;  weight ratio.
float Property fBootReferenceWeight = 5.0 Auto
float Property fCuirassReferenceWeight = 20.0 Auto
float Property fGauntletReferenceWeight = 5.0 Auto
float Property fHelmetReferenceWeight = 4.0 Auto
float Property fShieldReferenceWeight = 7.0 Auto

; Constants for slots
int mskBoot 	= 0x080
int mskCuirass 	= 0x004
int mskGauntlet = 0x008
int mskHelmet 	= 0x002
int mskShield   = 0x200
int mskTotal    = 0x28E

Event OnInit()
	ConsoleUtil.PrintMessage("ArmoredCaster: Manager initializing")

	; Initialize data structures
	JDB.solveObjSetter(".ArmoredCaster.mapReferenceWeights", JIntMap.object(), true)
	JDB.solveObjSetter(".ArmoredCaster.mapWeightRatios", JIntMap.object(), true)
	
	RegisterForModEvent("_ArmoredCaster_SettingChange", "OnSettingChange")
	ConsoleUtil.PrintMessage("ArmoredCaster: Manager initialized")
	
	; Trigger an initial calculation
	OnSettingChange("MOD INITIALIZATION")
EndEvent

Event OnSettingChange(string _id)
	int referenceMap = JDB.solveObj(".ArmoredCaster.mapReferenceWeights")
	
	int mskUpdate = 0x0
	If JIntMap.getFlt(referenceMap, mskBoot) != fBootReferenceWeight
		JIntMap.setFlt(referenceMap, mskBoot, fBootReferenceWeight)
		mskUpdate = Math.LogicalOr(mskUpdate, mskBoot)
	EndIf
	If JIntMap.getFlt(referenceMap, mskCuirass) != fCuirassReferenceWeight
		JIntMap.setFlt(referenceMap, mskCuirass, fCuirassReferenceWeight)
		mskUpdate = Math.LogicalOr(mskUpdate, mskCuirass)
	EndIf
	If JIntMap.getFlt(referenceMap, mskGauntlet) != fGauntletReferenceWeight
		JIntMap.setFlt(referenceMap, mskGauntlet, fGauntletReferenceWeight)
		mskUpdate = Math.LogicalOr(mskUpdate, mskGauntlet)
	EndIf
	If JIntMap.getFlt(referenceMap, mskHelmet) != fHelmetReferenceWeight
		JIntMap.setFlt(referenceMap, mskHelmet, fHelmetReferenceWeight)
		mskUpdate = Math.LogicalOr(mskUpdate, mskHelmet)
	EndIf
	If JIntMap.getFlt(referenceMap, mskShield) != fShieldReferenceWeight
		JIntMap.setFlt(referenceMap, mskShield, fShieldReferenceWeight)
		mskUpdate = Math.LogicalOr(mskUpdate, mskShield)
	EndIf

	If mskUpdate
		int handle = ModEvent.Create("_ArmoredCaster_ReferenceWeight_Change")
		ModEvent.PushInt(handle, mskUpdate)
		ModEvent.Send(handle)
	EndIf
EndEvent