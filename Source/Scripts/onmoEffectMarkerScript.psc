Scriptname onmoEffectMarkerScript extends ObjectReference  

onmoMCMScript property mcm auto

Explosion Property markerExplosion auto

ObjectReference Property item auto
int Property itemCount auto

ObjectReference explosionRef = NONE

float delay = 3.0
int loopCount = 0

Bool disabled = False
Bool pickedUp = False

Event onObjectGrabbedOrPulled(string eventName, string formId, float numArg, Form sender)
    removeEffectOfItem(formId)
EndEvent

bool function removeEffectOfItem(string formID)
    if (item != NONE  && (item.GetFormID()+"" == formID))
        pickedUp = true
        return true
    endIF
    return false
endFunction


Event onInit()
    RegisterForModEvent("onmoItemReadyEvent", "onItemReady")
    RegisterForModEvent("onmoObjectPulledOrGrabbed", "onObjectGrabbedOrPulled")
    RegisterForModEvent("onmoStopEffectsEvent", "onStopEffect")
endEvent

Event onStopEffect(string eventName, string arg, float numArg, Form sender)
    delete()
    UnregisterForUpdate()
    UnregisterForUpdateGameTime()
    UnregisterForAllModEvents()
    goToState("gone")
EndEvent

Function startEffect()
    RegisterForSingleUpdate(0.2)
    enable()
endFunction


Event onItemReady(string eventName, string arg, float numArg, Form sender)
    RegisterForSingleUpdate(0.2)
    enable()
EndEvent

Event OnUpdate()
    if(item != NONE)
        if (item.GetPositionX())
            SetPosition(item.GetPositionX(), item.GetPositionY(), item.GetPositionZ())
        endif
        if (!mcm.CurrentFlickerEnabled || !item.is3DLoaded() || pickedUp || (mcm.CurrentFlickerAmount > 0 && loopCount > mcm.CurrentFlickerAmount))
            delete()
            UnregisterForUpdate()
            UnregisterForUpdateGameTime()
            UnregisterForAllModEvents()
            goToState("gone")
        else 
            explosionRef = placeAtMe(markerExplosion, 1)
            loopCount = loopCount + 1
        endIF    
        RegisterForSingleUpdate(mcm.CurrentFlickerInterval)
    endIF
EndEvent



state gone
endState