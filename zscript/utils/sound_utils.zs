class SoundUtils
{
	// Functions

	static ui void uiStartSound(string snd_name, Actor plr)
	{
		int pnum = -1;
		for(int i = 0; i < MAXPLAYERS; ++i)
		{
			if(playeringame[i] && players[i].mo == plr)
			{ pnum = i; break; }
		}
		if(pnum != -1)
			EventHandler.sendNetworkEvent("dd_ui_sound:" .. snd_name, pnum);
	}
	static play void playStartSound(string snd_name, Actor plr)
	{
		plr.A_StartSound(snd_name, CHAN_AUTO, CHANF_UI | CHANF_LOCAL);
	}
}


class DD_SoundHandler : StaticEventHandler
{
	override void networkProcess(ConsoleEvent e)
	{
		if(e.name.indexOf("dd_ui_sound:") == 0)
		{
			let snd_utils = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).snd_utils;
			string snd_name = e.name.mid("dd_ui_sound:".length());
			if(players[e.player].mo)
				players[e.player].mo.A_StartSound(snd_name, CHAN_AUTO, CHANF_UI | CHANF_LOCAL);
		}
	}
}
