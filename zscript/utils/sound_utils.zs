struct SoundUtils_Queue
{
	array<string> ui_snd;
	array<Actor> ui_snd_plr;
}

class SoundUtils
{
	SoundUtils_Queue queue;

	// Engine events

	play void worldTick()
	{
		while(queue.ui_snd.size() > 0)
		{
			if(queue.ui_snd_plr[0])
				queue.ui_snd_plr[0].giveInventoryType("UISound");
			queue.ui_snd.delete(0);
			queue.ui_snd_plr.delete(0);
		}
	}


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
		int pnum = -1;
		for(int i = 0; i < MAXPLAYERS; ++i)
		{
			if(playeringame[i] && players[i].mo == plr)
			{ pnum = i; break; }
		}
		if(pnum != -1)
			EventHandler.sendNetworkEvent("dd_ui_sound:" .. snd_name, pnum);
	}
}

class UISound : Inventory
{
	default
	{
		+Inventory.ALWAYSPICKUP;
	}
	states
	{
		Spawn:
			TNT0 A 0;
			Stop;
	}
	override void AttachToOwner(Actor other)
	{
		SoundUtils snd_utils = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).snd_utils;
		if(snd_utils.queue.ui_snd.size() > 0)
			pickupSound = snd_utils.queue.ui_snd[0];
		PlayPickupSound(other);
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
			snd_utils.queue.ui_snd.push(snd_name);
			snd_utils.queue.ui_snd_plr.push(players[e.args[0]].mo);
		}
	}
}
