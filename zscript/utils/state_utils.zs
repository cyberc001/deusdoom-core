class StateUtils
{
	static string getTranslation(Actor ac)
	{
		state cs = ac.curState;
		if(!cs)
			return "Idle";

		if(ac.inStateSequence(cs, ac.findState("Spawn")))
			return "Idle";
		if(ac.inStateSequence(cs, ac.findState("Idle")))
			return "Idle";
		if(ac.inStateSequence(cs, ac.findState("See")))
			return "Chasing " .. (ac.target ? getActorName(ac.target) : "");
		if(ac.inStateSequence(cs, ac.findState("Missile")))
			return "Firing at " .. (ac.target ? getActorName(ac.target) : "");
		if(ac.inStateSequence(cs, ac.findState("Melee")))
			return "In close combat with " .. (ac.target ? getActorName(ac.target) : "");
		if(ac.inStateSequence(cs, ac.findState("Pain")))
			return "In pain";
		if(ac.inStateSequence(cs, ac.findState("Death")))
			return "Dying";
		if(ac.inStateSequence(cs, ac.findState("Raise")))
			return "Being resurrected";
		if(ac.inStateSequence(cs, ac.findState("Heal")))
			return "Healing";

		return " ";
	}
	protected static string getActorName(Actor ac)
	{
		if(ac is "PlayerPawn")
			return ac.player.getUserName();
		return ac.getTag("");
	}
}
