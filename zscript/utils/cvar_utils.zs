class CVar_Utils
{
	// Description:
	// Gets a double-precision real number using a CVar name.
	// Return value:
	//	double-precision real number if CVar can be obtained, 1.0 otherwise.
	static double getScale(string cvar_name)
	{
		double sc = 1.0;
		CVar scvar = CVar.getCVar(cvar_name, players[consoleplayer]);
		if(scvar)
			sc = scvar.getFloat();
		return sc;
	}

	// Description:
	// Gets a pair of offsets (x,y) using a CVar name without "x"/"y" postfix.
	// Return value:
	//	2D vector containing offsets if CVars could be obtained, (0.0,0.0) otherwise.
	static vector2 getOffset(string cvar_name)
	{
		vector2 off;
		CVar offvar = CVar.getCVar(cvar_name .. "x", players[consoleplayer]);
		if(offvar)
			off.x = offvar.getFloat();
		offvar = CVar.getCVar(cvar_name .. "y", players[consoleplayer]);
		if(offvar)
			off.y = offvar.getFloat();
		return off;
	}

	static bool isHUDDebugEnabled()
	{
		CVar dbg_cvar = CVar.getCVar("dd_hud_debug", players[consoleplayer]);
		return !dbg_cvar || dbg_cvar.getBool();
	}
}
