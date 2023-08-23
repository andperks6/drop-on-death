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
    unregisterAll()
EndEvent

Function startEffect()
    RegisterForSingleUpdate(0.1)
    enable()
endFunction

Function unregisterAll()
    delete()
    UnregisterForUpdate()
    UnregisterForUpdateGameTime()
    UnregisterForAllModEvents()
    goToState("gone")
endFunction

Event onItemReady(string eventName, string arg, float numArg, Form sender)
    RegisterForSingleUpdate(0.1)
    enable()
EndEvent

Event OnUpdate()
    Bool underFlickerAmount = (mcm.CurrentFlickerAmount > 0 && loopCount < mcm.CurrentFlickerAmount)
    if (underFlickerAmount && mcm.CurrentFlickerEnabled && item != NONE  && item.is3DLoaded() && !pickedUp)
        SetPosition(item.GetPositionX(), item.GetPositionY(), item.GetPositionZ())
        explosionRef = placeAtMe(markerExplosion, 1)
        loopCount = loopCount + 1
    else
        unregisterAll()
    endIF    
    RegisterForSingleUpdate(mcm.CurrentFlickerInterval)
EndEvent



state gone
endState