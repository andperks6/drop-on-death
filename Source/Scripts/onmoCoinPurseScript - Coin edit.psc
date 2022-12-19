Scriptname onmoCoinPurseScript extends ObjectReference  

MiscObject Property Gold001 Auto 

MiscObject Property CoinType Auto
int Property amount = 0 auto

Function startPurse()
	SetDisplayName("Coin Purse (" + amount + ")")
endFunction


Event OnActivate(ObjectReference user)
	user.AddItem(CoinType, amount)
	UnregisterForUpdate()
	UnregisterForUpdateGameTime()
	UnregisterForAllModEvents()
	delete()
EndEvent