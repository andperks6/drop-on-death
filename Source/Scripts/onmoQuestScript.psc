Scriptname onmoQuestScript extends Quest  



Event OnInit()
    HiggsVR.RegisterForPullEvent(Game.GetForm(GetFormID()))
    HiggsVR.RegisterForGrabEvent(Game.GetForm(GetFormID()))
endEvent

Event OnObjectPulled(ObjectReference refr, bool isLeft)
    SendModEvent("onmoObjectPulledOrGrabbed", refr.GetFormID()+"")
EndEvent

Event OnObjectGrabbed(ObjectReference refr, bool isLeft)
    SendModEvent("onmoObjectPulledOrGrabbed", refr.GetFormID()+"")
EndEvent
