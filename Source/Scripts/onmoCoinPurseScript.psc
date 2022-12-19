Scriptname onmoCoinPurseScript extends ObjectReference  

MiscObject Property Gold001  Auto 

int Property amount = 0 auto

Function startPurse()
	SetDisplayName("Coin Purse (" + amount + ")")
endFunction


Event OnActivate(ObjectReference user)
	user.AddItem(Gold001, amount)
	UnregisterForUpdate()
	UnregisterForUpdateGameTime()
	UnregisterForAllModEvents()
	delete()
EndEvent