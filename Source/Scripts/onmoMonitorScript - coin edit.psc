Scriptname onmoMonitorScript extends activemagiceffect  
Actor target
Int despawnMode
Int despawnCondition
Form[] items 
int[] itemCounts
onmoMCMScript property mcm auto
string purseID = ""

Actor Property player Auto



Activator Property onmoEffectMarker Auto
Flora Property onmoCoinPurse  Auto 
MiscObject Property Gold001  Auto
FormList Property DES_CoinsList Auto
; MiscObject Property DES_Auri  Auto
; MiscObject Property DES_Mede  Auto
; MiscObject Property DES_Sancar  Auto
; MiscObject Property DES_Ulfric  Auto
; MiscObject Property DES_Harald  Auto
; MiscObject Property DES_Gold  Auto
; MiscObject Property DES_DrakrOwl  Auto
; MiscObject Property DES_DrakrMoth  Auto
; MiscObject Property DES_DrakrWhale  Auto
; MiscObject Property DES_DrakrDragon  Auto
; MiscObject Property DES_Nchuark  Auto

; Custom event from MCM
Event onStopScript(string eventName, string strArg, float numArg, Form sender)
	Debug.Notification("Stopping DoD Script")
	quit()
EndEvent

; Custom event from MCM
Event onManualDespawn(string eventName, string strArg, float numArg, Form sender)
	handleDespawn()
    quit()
EndEvent


Event OnInit()
	RegisterForModEvent("onmoStopScriptEvent", "onStopScript")
	RegisterForModEvent("onmoManualDespawnEvent", "onManualDespawn")
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
	GoToState("alive")
EndEvent


State alive

	Event OnDying(Actor akKiller)
		despawnMode = mcm.CurrentDespawnMode
		despawnCondition = mcm.CurrentDespawnCondition
        
        Form[] inventory = PO3_SKSEFunctions.AddAllItemsToArray(target, false, false, true) ; For filtering quest items
        itemCounts = Utility.CreateIntArray(inventory.length); Int array of the calculated needed size
        items = Utility.CreateFormArray(inventory.length); Array of dropped items
		int index = items.length
		While (index > 0)
			index -= 1
			Form item = inventory[index]
            ; Checks if item is not none, is playable, is not equipped OR an equipped weapon, is allowed to drop in MCM
			if (item != NONE && item.IsPlayable() && (!target.IsEquipped(item) || (target.GetEquippedWeapon() != NONE && target.GetEquippedWeapon().GetFormID() == item.GetFormID())) && checkDropToggles(item))
				int itemCount = target.GetItemCount(item)
				ObjectReference droppedItem = NONE
				if (item.GetFormID() == 15) ; If item is coins and coindrops are enabled in mcm
					target.RemoveItem(Gold001, itemCount, true) ; remove the coins from inv
					ObjectReference purse = target.PlaceAtMe(onmoCoinPurse, 1, false, true) ; Create custom coin purse with script
					(purse as onmoCoinPurseScript).amount = itemCount ; Give coin purse the amount of coin
					(purse as onmoCoinPurseScript).coinType = Gold001
					purse.SetPosition(target.GetPositionX(), target.GetPositionY(), target.GetPositionZ()+50) ; Move coin purse to on top of corpse
					purse.SetActorOwner(NONE)
					(purse as onmoCoinPurseScript).startPurse()
					purse.Enable() ; Make purse visible
					droppedItem = purse
					purseID = purse.GetFormID()+""
				elseif DES_CoinsList.HasForm(item)
					Int iIndex = DES_CoinsList.Find(item)
					Form coinForm = DES_CoinsList.GetAt(iIndex)
					Miscobject coinObject = coinForm as miscobject
					target.RemoveItem(coinObject, itemCount, true) ; remove the coins from inv
					ObjectReference purse = target.PlaceAtMe(onmoCoinPurse, 1, false, true) ; Create custom coin purse with script
					(purse as onmoCoinPurseScript).amount = itemCount ; Give coin purse the amount of coin
					(purse as onmoCoinPurseScript).coinType = coinObject ; Give coin purse the amount of coin
					purse.SetPosition(target.GetPositionX(), target.GetPositionY(), target.GetPositionZ()+50) ; Move coin purse to on top of corpse
					purse.SetActorOwner(NONE)
					(purse as onmoCoinPurseScript).startPurse()
					purse.Enable() ; Make purse visible
					droppedItem = purse
					purseID = purse.GetFormID()+""
				else
					droppedItem = target.DropObject(item,itemCount)
				endIf
				if (droppedItem != NONE && (droppedItem.Is3DLoaded() || !droppedItem.Is3DLoaded()))
					waitFor3D(droppedItem)
                
					items[index] = droppedItem
					itemCounts[index] = itemCount
					
					if(mcm.CurrentFlickerEnabled)
						ObjectReference marker = target.placeAtMe(onmoEffectMarker,1)
						(marker as onmoEffectMarkerScript).item = droppedItem as ObjectReference
						(marker as onmoEffectMarkerScript).itemCount = itemCount
						(marker as onmoEffectMarkerScript).startEffect()
					endIF
				endIF
			endIf
		EndWhile
		GoToState("dead")
	EndEvent
EndState
    ; Checks the MCM config if an item should drop
    bool Function checkDropToggles(Form item)
        Bool[] filterValues = mcm.CurrentFilterValues ; Array of values of the mcm toggles
        int[] filterTypes = mcm.filterTypes ; Type numbers of items
        int index = 0
        if (item.GetFormID() == 15)
            return filterValues[8]
        endIF
        while (index<filterValues.length)
            if (item.GetType() == filterTypes[index] && filterValues[index] == true)
                return true
            endIf
            index = index + 1
        endWhile
        return false
    endFunction  

    ;Waits for 3d to be loaded, with a max time of 10 seconds
    bool Function waitFor3D(ObjectReference item)
        
        int effectIndex = 0
        while(!item.Is3DLoaded() && effectIndex < 50)
            Utility.Wait(0.1)
            effectIndex = effectIndex + 1
        endWhile
        return true
    endFunction
 
State dead

	Event OnBeginState()
		if (despawnMode != 2 && despawnCondition == 0) ; If mode is not disabled and condition is time interval
			float despawnRate = mcm.CurrentDespawnRate
			RegisterForSingleUpdateGameTime(despawnRate) ; Start timer for despawn
		endIf
		if (mcm.CurrentReturnMode != 2)
			RegisterForSingleUpdate(mcm.CurrentReturnInterval) ; Start timer to check item voiding
		endIf
		
	EndEvent
	
	Event OnCellDetach()
		if (despawnMode != 2 && despawnCondition == 1) ; If despawn mode is not disabled and condition is "on leaving cell"
			handleDespawn()
			quit()
		endIf
	endEvent
	
	Event OnUpdateGameTime()
		handleDespawn()
		quit()
	EndEvent
	
	Event OnUpdate()
        int index = 0
		While index < items.Length
			ObjectReference item = items[index] as ObjectReference
            ; If item is far away from the corpse but still close to the player
            if (item != NONE && item.Is3DLoaded()  && target.GetDistance(item) > mcm.CurrentReturnDistance && player.GetDistance(item) > mcm.CurrentVicinityDistance)
                item.SetMotionType(4)
                item.setPosition(target.getPositionx(),target.getPositiony(),target.getPositionz()+20)
                Utility.wait(0.1)
                item.SetMotionType(1)
                item.ApplyHavokImpulse(0.0, 0.0, 1.0, 0)
			endIf
			index += 1
		EndWhile
		if (mcm.CurrentReturnMode == 1) ; If return mode is continuous
			RegisterForSingleUpdate(mcm.CurrentReturnInterval)
		endIf
	EndEvent
EndState

	Function handleDespawn()
		Int index = 0
		While index < items.Length
			ObjectReference item = items[index] as ObjectReference ; Get item of dropped items array
			Float skipDistance = mcm.CurrentVicinityDistance ; Get the skip distance
			if (item != NONE && item.Is3DLoaded() && player.GetDistance(item) > skipDistance) ; If item is not null, is an 3d object and outside player range
				If(despawnMode == 1) ; If despawn mode is "delete items"
					item.Delete()
				else
                    item.activate(target) ; Let corpse pick it up
				endIf
			endIf
			index += 1
		EndWhile
	
	endFunction


	Function quit()
		UnregisterForUpdate()
		UnregisterForUpdateGameTime()
		UnregisterForAllModEvents()
		Dispel()
		gotoState("done")
	endFunction
	



State done
EndState

