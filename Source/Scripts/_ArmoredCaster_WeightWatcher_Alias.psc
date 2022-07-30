ScriptName _ArmoredCaster_WeightWatcher_Alias extends ReferenceAlias
{
	Converts player equipment events into events consumable by the ArmoredCaster Manager
}

; bitmask of slots that need to be updated
int mskSlotsToUpdate

Event OnInit()
	; allow other scripts to trigger recalcs, too
	RegisterForModEvent("_ArmoredCaster_ReferenceWeight_Change", "OnSlotUpdate")
EndEvent

; We can't guarantee that we will process unequip/equip events in the propr
;  order even though the game engine will always send them in that order.
;  Instead, set a slot mask to update.

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject As Armor
		UpdateSlot((akBaseObject As Armor).GetSlotMask())
	EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If akBaseObject As Armor
		UpdateSlot((akBaseObject As Armor).GetSlotMask())
	EndIf
EndEvent

Event OnSlotUpdate(int _msk)
	UpdateSlot(_msk)
EndEvent

Function UpdateSlot(int _updateMask)
	_DoUpdateSlot(_updateMask)
EndFunction

Function _DoUpdateSlot(int _updateMask)
	GoToState("Working")
	ConsoleUtil.PrintMessage("ArmoredCaster: Calculating update for mask " + _updateMask)
	
	Actor PlayerRef = GetReference() As Actor
	
	; Stash the update mask, zero it, and merge the new mask
	int msk = mskSlotsToUpdate
	mskSlotsToUpdate = 0
	msk = Math.LogicalOr(msk, _updateMask)
	
	; Keep track of the slot weights that have changed
	int mskChanged = 0x0
	
	int referenceWeightMap = JDB.solveObj(".ArmoredCaster.mapReferenceWeights")
	int weightRatioMap = JDB.solveObj(".ArmoredCaster.mapWeightRatios")
	
	; Loop to check for concurrent update requests
	While msk
		; Iterate the slots we want to keep weight for, and update accordingly
		int k = JIntMap.nextKey(referenceWeightMap, -1, -1)
		While k != -1 && msk
			If Math.LogicalAnd(msk, k)
				; this slot has potentially changed; stash current value
				float currentRatio = JIntMap.getFlt(weightRatioMap, k, -1.0)
				Armor worn = PlayerRef.GetWornForm(k) As Armor
				
				; determine if we need to update
				If worn && (worn.IsLightArmor() || worn.IsHeavyArmor() || worn.IsShield())
					; armor/shield is in this slot
					int wornMsk = worn.GetSlotMask()
					float referenceWeight = 0.0
					
					; add up any relevant reference weights--consider a bodysuit covering cuirass, boots, and gloves
					int j = JIntMap.nextKey(referenceWeightMap, -1, -1)
					While j != -1
						If Math.LogicalAnd(wornMsk, j)
							referenceWeight += JIntMap.getFlt(referenceWeightMap, j)
						EndIf
						
						j = JIntMap.nextKey(referenceWeightMap, j, -1)
					EndWhile
					
					float ratio = 0.0
					
					If referenceWeight > 0.0
						ratio = worn.GetWeight() / referenceWeight
					EndIf
					
					If ratio != currentRatio
						JIntMap.SetFlt(weightRatioMap, k, ratio)
						mskChanged = Math.LogicalOr(mskChanged, wornMsk)
					EndIf
					
					; remove the slot mask we checked from our mask
					msk = Math.LogicalAnd(msk, Math.LogicalNot(wornMsk))
				ElseIf currentRatio != 0.0
					; was wearing armor, now wearing nothing/clothing
					JIntMap.setFlt(weightRatioMap, k, 0.0)
					mskChanged = Math.LogicalOr(mskChanged, k)
					
					; remove the slot mask we checked from our mask
					msk = Math.LogicalAnd(msk, Math.LogicalNot(k))
				EndIf
			EndIf
			
			k = JIntMap.nextKey(referenceWeightMap, k, -1)
		EndWhile
		
		; check to see if an update has been queued
		msk = mskSlotsToUpdate
		mskSlotsToUpdate = 0x0
		
		ConsoleUtil.PrintMessage("ArmoredCaster: Calculating update for mask " + msk)
	EndWhile
	
	; We are no longer checking for updates, so enable a new update thread
	GoToState("")
	
	; Finally, send an event including the update mask we just invalidated
	If mskChanged
		ConsoleUtil.PrintMessage("ArmoredCaster: Pushing update for mask " + mskChanged)
		int handle = ModEvent.Create("_ArmoredCaster_WeightRatio_Change")
		ModEvent.PushInt(handle, mskChanged)
		ModEvent.Send(handle)
	EndIf
EndFunction

; Defer all updates 
State Working
	Function _DoUpdateSlot(int _updateMask)
		ConsoleUtil.PrintMessage("ArmoredCaster: Pushing update for " + _updateMask)
		mskSlotsToUpdate = Math.LogicalOr(mskSlotsToUpdate, _updateMask)
	EndFunction
EndState