class DDSpawner : Actor
{
	default
	{
		DDSpawner.VelocityMin 0.8;
		DDSpawner.VelocityMax 1.2;
		DDSpawner.SpawnChance 1;
		DDSpawner.ChanceMul 0;
		DDSpawner.PreserveItem false;
	}

	class<Actor> toreplace;
	property ToReplace: toreplace;
	array<class<Actor> > actors;
	array<uint> chances;
	array<int> flags;

	bool preserve_item;
	property PreserveItem: preserve_item;

	// spawn another guaranteed spawner(s) on top of this one.
	// watch out for recursion
	array<class<DDSpawner> > spawn_along;

	const FLAG_DONTDUP = 1; // obviously, shouldn't be on every item in a spawner.
	const FLAG_REMOVEAFTER = 2;

	double spawn_chance; // chance to actually spawn anything
	property SpawnChance: spawn_chance;
	double chance_mul; // multiplier spawn chance for each subsequent successful spawn tries
	property ChanceMul: chance_mul;

	double vel_min;
	property VelocityMin: vel_min;
	double vel_max;
	property VelocityMax: vel_max;
	override void BeginPlay()
	{
		double spchance = spawn_chance;
		while(frandom(0, 1) <= spchance){
			bool dec_spchance = true;
			Actor tospawn;
			uint ch_sum = 0;
			for(uint j = 0; j < actors.size(); ++j)
				ch_sum += chances[j];
			uint ch = random(0, ch_sum);
			ch_sum = 0;
			for(uint j = 0; j < actors.size(); ++j){
				if(ch_sum + chances[j] > ch){
					if(flags[j] & FLAG_DONTDUP){
						bool everyone_got_item = true;
						for(int i = 0; i < MAXPLAYERS; ++i)
							if(playeringame[i] && players[i].mo && players[i].mo.CountInv(actors[j].getClassName()) == 0)
							{ everyone_got_item = false; break; }
						if(everyone_got_item)
						{ spchance *= 0.8; dec_spchance = false; break; }
					}

					tospawn = Actor.Spawn(actors[j], pos);
					tospawn.A_ChangeVelocity(frandom(vel_min, vel_max) * (random(0,1) ? 1 : -1), frandom(vel_min, vel_max) * (random(0,1) ? 1 : -1));
					if(flags[j] & FLAG_REMOVEAFTER){
						actors.delete(j);
						chances.delete(j);
						flags.delete(j);
					}
					break;
				}
				ch_sum += chances[j];
			}
			if(dec_spchance)
				spchance *= chance_mul;
		}
		let spawn_utils = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).spawn_utils;
		class<Actor> repl = spawn_utils.getModReplacement(toreplace);
		if(repl != toreplace || preserve_item)
			Actor.Spawn(repl, pos);
		
		for(uint i = 0; i < spawn_along.size(); ++i)
			Actor.Spawn(spawn_along[i], pos);
	}
}

class SpawnReplacement
{
	class<Actor> replacee;
	class<Actor> replacement;
}
class SpawnUtils
{
	array<SpawnReplacement> mod_repls; // actors replaced by other mods: duplicate them when spawning through a DDSpawner
	void addModReplacee(class<Actor> replacee, class<Actor> replacement)
	{
		if(replacement is "DDSpawner")
			return;
		for(uint i = 0; i < mod_repls.size(); ++i)
			if(mod_repls[i].replacee == replacee){
				mod_repls[i].replacement = replacement;
				return;
			}
		let repl = new("SpawnReplacement");
		repl.replacee = replacee;
		repl.replacement = replacement;
		mod_repls.push(repl);
	}
	class<Actor> getModReplacement(class<Actor> replacee)
	{
		for(uint i = 0; i < mod_repls.size(); ++i)
			if(mod_repls[i].replacee == replacee)
				return mod_repls[i].replacement;
		return replacee;
	}
}
