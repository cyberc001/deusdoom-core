class DD_ModChecker
{
	bool mod_loaded_cache[2];
	// Indicies:
	// 0 - HDest
	// 1 - DeathStrider

	void init()
	{
		for(uint i = 0; i < AllActorClasses.size(); ++i){
			if(AllActorClasses[i].getClassName() == "HDPlayerPawn") mod_loaded_cache[0] = true;
			else if(AllActorClasses[i].getClassName() == "DSPlayer") mod_loaded_cache[1] = true;
		}
	}
	static DD_ModChecker getInstance()
	{
		return DD_EventHandler(StaticEventHandler.find("DD_EventHandler")).mod_checker;
	}

	static bool isLoaded_HDest() { let inst = getInstance(); return inst.mod_loaded_cache[0]; }
	static bool isLoaded_DeathStrider() { let inst = getInstance(); return inst.mod_loaded_cache[1]; }
}

class DD_PatchChecker
{
	bool patch_loaded_cache[2];
	// Indicies:
	// 0 - HDest
	// 1 - DeathStrider

	void init()
	{
		for(uint i = 0; i < AllActorClasses.size(); ++i){
			if(AllActorClasses[i].getClassName() == "DD_HDHealthGiver") patch_loaded_cache[0] = true;
			if(AllActorClasses[i].getClassName() == "DD_DSHealthGiver") patch_loaded_cache[1] = true;
		}
	}
	static DD_PatchChecker getInstance()
	{
		return DD_EventHandler(StaticEventHandler.find("DD_EventHandler")).patch_checker;
	}

	static bool isLoaded_HDest() { let inst = getInstance(); return inst.patch_loaded_cache[0]; }
	static bool isLoaded_DeathStrider() { let inst = getInstance(); return inst.patch_loaded_cache[1]; }
}
