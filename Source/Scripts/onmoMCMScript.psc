scriptname onmoMCMScript extends SKI_ConfigBase

int property version = 2 auto

; Despawning:
Int despawnModeMenu
string[] despawnModeOptions
Int Property CurrentDespawnMode = 0 auto

Int despawnConditionMenu
string[] despawnConditionOptions
Int Property CurrentDespawnCondition = 0  auto

Int despawnRateSlider
float Property CurrentDespawnRate = 12.0  auto

Int vicinityDistanceSlider
float Property CurrentVicinityDistance = 250.0  auto

; Item effect:


Int flickerEnabledToggle
Bool Property CurrentFlickerEnabled = True auto

Int flickerIntervalSlider
float Property CurrentFlickerInterval = 5.0  auto

Int flickerAmountSlider
float Property CurrentFlickerAmount = 30.0  auto


; Return:
Int returnDistanceSlider
float Property CurrentReturnDistance = 600.0  auto

Int returnModeMenu
string[] returnModeOptions
Int Property CurrentReturnMode = 0  auto

; Filters:
Int[] Property filterTypes auto
string[] filterNames 
Int[] filterToggles
Bool[] Property CurrentFilterValues auto


; Advanced:
Int stopScriptToggle
Bool stopScriptValue

Int manualDespawnToggle
Bool manualDespawnValue

Int stopEffectsToggle
Bool stopEffectsValue

Int debugToggle
Bool Property inDebugMode = false auto

Int returnIntervalSlider
float Property CurrentReturnInterval = 10.0  auto

event OnConfigInit()


		Pages = new string[3]
		Pages[0] = "Settings"
		Pages[1] = "Filters"
		Pages[2] = "Advanced"
        
        ;Return
		despawnModeOptions = new string[3]
		despawnModeOptions[0] = "Put items back in body"
		despawnModeOptions[1] = "Delete items"
		despawnModeOptions[2] = "Don't despawn"

		despawnConditionOptions = new string[2]
		despawnConditionOptions[0] = "After x game hours"
		despawnConditionOptions[1] = "When cell unloads"
		
		returnModeOptions = new string[3]
		returnModeOptions[0] = "Once"
		returnModeOptions[1] = "Continuous"
		returnModeOptions[2] = "Disabled"
        
        ; Filters
        filterToggles = new int[10]
        
        CurrentFilterValues = new Bool[10]
        CurrentFilterValues[0] = true
        CurrentFilterValues[1] = true
        CurrentFilterValues[2] = true
        CurrentFilterValues[3] = true
        CurrentFilterValues[4] = false
        CurrentFilterValues[5] = true
        CurrentFilterValues[6] = true
        CurrentFilterValues[7] = true
        CurrentFilterValues[8] = true
        CurrentFilterValues[9] = true
        
        filterTypes = new int[10]
        filterTypes[0] = 41
        filterTypes[1] = 26
        filterTypes[2] = 32
        filterTypes[3] = 52
        filterTypes[4] = 45
        filterTypes[5] = 42
        filterTypes[6] = 27
        filterTypes[7] = 46
        filterTypes[8] = 9999
        filterTypes[9] = 30
        
        filterNames = new string[10]
        filterNames[0] = "Weapons"
        filterNames[1] = "Armor"
        filterNames[2] = "Misc"
        filterNames[3] = "Soul gem"
        filterNames[4] = "Keys"
        filterNames[5] = "Ammo"
        filterNames[6] = "Book"
        filterNames[7] = "Potion"
        filterNames[8] = "Coins"
        filterNames[9] = "Ingredient"
        
        
endEvent



Event OnPageReset(string page)
	if (page == "")
		LoadCustomContent("dropondeath/dod_splash.dds", 80, -100)
		return
	else
		UnloadCustomContent()
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)
	endIf
	
	if (page == "Settings")
		AddHeaderOption("Despawning")
		despawnModeMenu = AddMenuOption("Despawn Mode", despawnModeOptions[CurrentDespawnMode])
		if (CurrentDespawnMode == 2)
			despawnConditionMenu = AddMenuOption("Condition", despawnConditionOptions[CurrentDespawnCondition], OPTION_FLAG_DISABLED)
			
		else
			despawnConditionMenu = AddMenuOption("Condition", despawnConditionOptions[CurrentDespawnCondition])
		endIf
		
		AddHeaderOption("Returning")
		returnModeMenu = AddMenuOption("Item Return mode", returnModeOptions[CurrentReturnMode])
		
	
		AddHeaderOption("Item effect")
        flickerEnabledToggle = AddToggleOption("Enabled?", CurrentFlickerEnabled)
        
        
        
		SetCursorPosition(1)
		AddHeaderOption("Variables")
		
		vicinityDistanceSlider = AddSliderOption("Skip radius", CurrentVicinityDistance, "Within {0} units")
		
		if (CurrentDespawnCondition != 0 || CurrentDespawnMode == 2)
			despawnRateSlider = AddSliderOption("Despawn Rate", CurrentDespawnRate, "After {1} hours", OPTION_FLAG_DISABLED)
		else
			despawnRateSlider = AddSliderOption("Despawn Rate", CurrentDespawnRate, "After {1} hours")
		endIf
		AddEmptyOption()
		if (CurrentReturnMode == 2)
			returnDistanceSlider = AddSliderOption("Item Return Distance", CurrentReturnDistance, "Outside {0} units", OPTION_FLAG_DISABLED)
		else
			returnDistanceSlider = AddSliderOption("Item Return Distance", CurrentReturnDistance, "Outside {0} units")
		endIf
        
        AddEmptyOption()
        
        if (CurrentFlickerEnabled)
            flickerIntervalSlider = AddSliderOption("Flicker interval", CurrentFlickerInterval, "Every {1} seconds")
            flickerAmountSlider = AddSliderOption("Flicker amount", CurrentFlickerAmount, "{0} times")
		else
            flickerIntervalSlider = AddSliderOption("Flicker interval", CurrentFlickerInterval, "Every {1} seconds", OPTION_FLAG_DISABLED)
            flickerAmountSlider = AddSliderOption("Flicker amount", CurrentFlickerAmount, "{0} times", OPTION_FLAG_DISABLED)
		endIf
		return
    elseif (page == "Filters")
        SetCursorFillMode(LEFT_TO_RIGHT)
        int index = 0
        while (index < filterNames.length)
            filterToggles[index] = AddToggleOption(filterNames[index], CurrentFilterValues[index])
            index = index + 1
        endWhile
		return
	elseif (page == "Advanced")
		AddHeaderOption("Debug")
		stopScriptValue = False;
		stopScriptToggle = AddToggleOption("Remove Scripts", stopScriptValue)
		manualDespawnValue = False;
		manualDespawnToggle = AddToggleOption("Manual Despawn", manualDespawnValue)
		stopEffectsValue = False;
		stopEffectsToggle = AddToggleOption("Remove visual effects of items", stopEffectsValue)
		
        
		debugToggle = AddToggleOption("Debug mode", inDebugMode)
        
        AddEmptyOption()
		
		AddHeaderOption("Advanced")
		
		returnIntervalSlider = AddSliderOption("Item return interval", CurrentReturnInterval, "Every {1} seconds")
		
		return
	endIf

endEvent

event OnOptionSliderOpen(int option)
	if (option == despawnRateSlider)
		SetSliderDialogStartValue(CurrentDespawnRate)
		SetSliderDialogDefaultValue(12)
		SetSliderDialogRange(0.5, 720)
		SetSliderDialogInterval(0.5)
	elseIf (option == vicinityDistanceSlider)
		SetSliderDialogStartValue(CurrentVicinityDistance)
		SetSliderDialogDefaultValue(250)
		SetSliderDialogRange(0, 1000)
		SetSliderDialogInterval(10)
	elseIf (option == returnDistanceSlider)
		SetSliderDialogStartValue(CurrentReturnDistance)
		SetSliderDialogDefaultValue(600)
		SetSliderDialogRange(300, 3000)
		SetSliderDialogInterval(50)
	elseIf (option == returnIntervalSlider)
		SetSliderDialogStartValue(CurrentReturnInterval)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(8, 60)
		SetSliderDialogInterval(0.5)
	elseIf (option == flickerIntervalSlider)
		SetSliderDialogStartValue(CurrentFlickerInterval)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(3, 30)
		SetSliderDialogInterval(0.5)
    elseIf (option == flickerAmountSlider)
		SetSliderDialogStartValue(CurrentFlickerAmount)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	endIf
endEvent

Event OnOptionSliderAccept(int option, float value)
	if (option == despawnRateSlider)
		CurrentDespawnRate = value
		SetSliderOptionValue(option, value, "After {1} hours")
	elseIf (option == vicinityDistanceSlider)
		CurrentVicinityDistance = value
		SetSliderOptionValue(option, value, "Within {0} units")
	elseIf (option == returnDistanceSlider)
		CurrentReturnDistance = value
		SetSliderOptionValue(option, value, "Outside {0} units")
	elseIf (option == returnIntervalSlider)
		CurrentReturnInterval = value
		SetSliderOptionValue(option, value, "Every {1} seconds")
	elseIf (option == flickerIntervalSlider)
		CurrentFlickerInterval = value
		SetSliderOptionValue(option, value, "Every {1} seconds")
	elseIf (option == flickerAmountSlider)
		CurrentFlickerAmount = value
		SetSliderOptionValue(option, value, "{0} times")
	endIf
endEvent

event OnOptionMenuOpen(int option)
	if (option == despawnConditionMenu)
		SetMenuDialogStartIndex(CurrentDespawnCondition)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(despawnConditionOptions)
	elseif (option == despawnModeMenu)
		SetMenuDialogStartIndex(CurrentDespawnMode)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(despawnModeOptions)
	elseif (option == returnModeMenu)
		SetMenuDialogStartIndex(CurrentReturnMode)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(returnModeOptions)
	endIf
endEvent

event OnOptionMenuAccept(int option, int index)
	if (option == despawnConditionMenu)
		CurrentDespawnCondition = index
		SetMenuOptionValue(option, despawnConditionOptions[CurrentDespawnCondition])
		if (index != 0)
			SetOptionFlags(despawnRateSlider, OPTION_FLAG_DISABLED)
		else
			SetOptionFlags(despawnRateSlider, OPTION_FLAG_NONE)
		endIf
	elseif (option == despawnModeMenu)
		CurrentDespawnMode = index
		SetMenuOptionValue(option, despawnModeOptions[CurrentDespawnMode])
		if (index == 2)
			setOptionFlags(despawnConditionMenu, OPTION_FLAG_DISABLED)
			setOptionFlags(despawnRateSlider, OPTION_FLAG_DISABLED)
		else
			setOptionFlags(despawnRateSlider, OPTION_FLAG_NONE)
			setOptionFlags(despawnConditionMenu, OPTION_FLAG_NONE)
		endIf
	elseif (option == returnModeMenu)
		CurrentReturnMode = index
		SetMenuOptionValue(option, returnModeOptions[CurrentReturnMode])
		if (index == 2)
			setOptionFlags(returnDistanceSlider, OPTION_FLAG_DISABLED)
		else
			setOptionFlags(returnDistanceSlider, OPTION_FLAG_NONE)
		endIf
	endIf
endEvent

event OnOptionSelect(int option)
	if (option == stopScriptToggle)
		stopScriptValue = !stopScriptValue
		SetToggleOptionValue(option, stopScriptValue)
	elseIf (option == manualDespawnToggle)
		manualDespawnValue = !manualDespawnValue
		SetToggleOptionValue(option, manualDespawnValue)
    elseIf (option == stopEffectsToggle)
		stopEffectsValue = !stopEffectsValue
		SetToggleOptionValue(option, stopEffectsValue)
    elseIf (option == debugToggle)
		inDebugMode = !inDebugMode
		SetToggleOptionValue(option, inDebugMode)
    elseIf (option == flickerEnabledToggle)
		CurrentFlickerEnabled = !CurrentFlickerEnabled
		SetToggleOptionValue(option, CurrentFlickerEnabled)
        if (CurrentFlickerEnabled)
			setOptionFlags(flickerIntervalSlider, OPTION_FLAG_NONE)
			setOptionFlags(flickerAmountSlider, OPTION_FLAG_NONE)
		else
			setOptionFlags(flickerIntervalSlider, OPTION_FLAG_DISABLED)
			setOptionFlags(flickerAmountSlider, OPTION_FLAG_DISABLED)
		endIf
    else
        int index = 0
        while (index < filterToggles.length)
            if (option == filterToggles[index])
                bool next = !CurrentFilterValues[index]
                CurrentFilterValues[index] = next
                SetToggleOptionValue(option, next)
                return
            endIf
            index = index + 1
        endwhile
	endIf
endEvent

event OnOptionHighlight(int option)
	; Despawn:
	if (option == despawnModeMenu)
		SetInfoText("Determines what happens with items when despawning")
	elseif (option == despawnConditionMenu)
		SetInfoText("Determines under what condition the specified subject despawns")
	elseif (option == despawnRateSlider)
		SetInfoText("Determines after how many game hours the subject despawns")
	elseif (option == vicinityDistanceSlider)
		SetInfoText("Determines the radius around the player that stops items from despawning or returning. (E.g. while grabbing)")
	; Returning:
	elseif (option == returnDistanceSlider)
		SetInfoText("When items are outside this radius, they get returned.")
	elseif (option == returnModeMenu)
		SetInfoText("Whether items teleport back to the corpse if they are x units away. (E.g. clipped through world)")
	elseif (option == returnIntervalSlider)
		SetInfoText("After how long the items should be returned after dying.")
    ; Item Effect:
    elseif (option == flickerEnabledToggle)
		SetInfoText("Whether the item effect should be displayed.")
    elseif (option == flickerIntervalSlider)
		SetInfoText("Determines how often the item effect should be displayed.")
    elseif (option == flickerAmountSlider)
		SetInfoText("How many times an item should emit the pulse. 0 = infinite")
	; Advanced:
	elseif (option == stopScriptToggle)
		SetInfoText("Removes all DoD scripts from attached NPC's.")
    elseif (option == stopEffectsToggle)
		SetInfoText("Removes all visual effects from items.")
	elseif (option == manualDespawnToggle)
		SetInfoText("Button to manually despawn dropped items.")
    elseif (option == debugToggle)
		SetInfoText("Enables debug mode")
	endIf
endEvent

event OnConfigClose()
	if (stopScriptValue)
		SendModEvent("onmoStopScriptEvent")
	endIf
    if (inDebugMode)
		debug.notification("Enabled debug mode")
	endIf
    if (stopEffectsValue)
		SendModEvent("onmoStopEffectsEvent")
	endIf
	if (manualDespawnValue)
		SendModEvent("onmoManualDespawnEvent")
	endIf
endEvent