Scriptname onmoMonitorScript extends activemagiceffect  
Actor target
Int despawnMode
Int despawnCondition
Form[] items 
int[] itemCounts
onmoMCMScript property mcm auto
string purseID = ""

int version

Actor Property player Auto

Activator Property onmoEffectMarker Auto
Flora Property onmoCoinPurse  Auto 
MiscObject Property Gold001  Auto


string debugPrefix = ""

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
    version = mcm.version
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
	target = akTarget
    
	GoToState("alive")
EndEvent

    ObjectReference Function placePurse(int coinCount)
        ObjectReference purse = target.PlaceAtMe(onmoCoinPurse, 1, false, true) ; Create custom coin purse with script
        (purse as onmoCoinPurseScript).amount = coinCount ; Give coin purse the amount of coin
        purse.SetPosition(target.GetPositionX(), target.GetPositionY(), target.GetPositionZ()+50) ; Move coin purse to on top of corpse
        purse.SetActorOwner(NONE)
        (purse as onmoCoinPurseScript).startPurse()
        purse.Enable() ; Make purse visible
        purseID = purse.GetFormID()+""
        return purse
    EndFunction
    
    Function placeMarker(ObjectReference droppedItem, int itemCount)
        ObjectReference marker = target.placeAtMe(onmoEffectMarker,1)
        (marker as onmoEffectMarkerScript).item = droppedItem as ObjectReference
        (marker as onmoEffectMarkerScript).itemCount = itemCount
        (marker as onmoEffectMarkerScript).startEffect()
    EndFunction
    


State alive

   
	Event OnDying(Actor akKiller)
    
        debugPrefix = "DropOnDeath debug: [" + target.getFormID() + ", " + target.getBaseObject().getName() + "] - "
        
        if (mcm.inDebugMode)
            debug.trace(debugPrefix + "is dying. Trying to drop inventory")
            debug.notification(target.getBaseObject().getName() + " is dying. Dropping inventory")
        endIF
       
    
		despawnMode = mcm.CurrentDespawnMode
		despawnCondition = mcm.CurrentDespawnCondition
        
        Form[] inventory = PO3_SKSEFunctions.AddAllItemsToArray(target, false, false, true) ; For filtering quest items
        
       
        
        itemCounts = Utility.CreateIntArray(inventory.length); Int array of the calculated needed size
        items = Utility.CreateFormArray(inventory.length); Array of dropped items
        
        
		int index = items.length
		While (index > 0)
			index -= 1
			Form item = inventory[index]
            int itemCount = target.GetItemCount(item)
            ; Checks if item is not none, is playable, is not equipped OR an equipped weapon, is allowed to drop in MCM
			if (item != NONE && item.IsPlayable() && (!target.IsEquipped(item) || (target.GetEquippedWeapon() != NONE && target.GetEquippedWeapon().GetFormID() == item.GetFormID())) && checkDropToggles(item) && itemCount > 0)
				
				ObjectReference droppedItem = NONE
				if (item.GetFormID() == 15 && itemCount > 0) ; If item is coins and coindrops are enabled in mcm
					target.RemoveItem(Gold001, itemCount, true) ; remove the coins from inv
                    droppedItem = placePurse(itemCount)
                    if (mcm.inDebugMode)
                        debug.trace(debugPrefix + "Dropped item is a coin purse")
                    endIF
				else
					droppedItem = target.DropObject(item,itemCount)
                    if (mcm.inDebugMode)
                        debug.trace(debugPrefix + "Dropped item is an item with formID: " + droppedItem.getFormID())
                    endIF
				endIf
                
                waitFor3D(droppedItem)
                
                items[index] = droppedItem
                itemCounts[index] = itemCount
                
                if(mcm.CurrentFlickerEnabled)
                    placeMarker(droppedItem, itemCount)
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
        if (item == NONE)
            return false
        endIf
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

