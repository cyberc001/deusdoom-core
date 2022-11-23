class DD_Skill
{
	string _name;
	string desc;
	int level_cost[3];
	TextureID icon;
}

class DD_SkillState : Inventory
{ // skills status on an actual players
	default
	{
		+DONTGIB;
		+THRUACTORS;
	}

	int skill_levels[32]; // trying to access a dynamic array of DD_SkillState spawned in DD_EventHandler results in a crash lol

	const skill_award_perlevel = 170;
	const skill_award_per100secrets = 130;
	array<string> visited_maps; // don't give points for re-visiting a hub map
	override void Travelled()
	{
		if(visited_maps.find(level.MapName) == visited_maps.size()){
			int total_award = skill_award_perlevel;
			let ddeh = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler"));
			total_award += ddeh.prev_level_secret_ratio * skill_award_per100secrets;
			owner.giveInventory("DD_SkillPoints", ceil(ddeh.skill_utils.skill_points_mult * total_award));
			visited_maps.push(level.MapName);
		}
	}

	override void BeginPlay()
	{
		visited_maps.push(level.MapName);
	}
}

class DD_SkillPoints : Inventory
{
	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 999999;
		Inventory.InterHubAmount 999999;
		+Inventory.UNDROPPABLE;
	}
}

class SkillUtils
{
	array<DD_Skill> skills;

	int registerSkill(string _name, string desc, TextureID icon, int level_cost_1, int level_cost_2, int level_cost_3)
	{
		DD_Skill sk = new("DD_Skill");
		sk._name = _name;
		sk.desc = desc;
		sk.icon = icon;
		sk.level_cost[0] = level_cost_1; sk.level_cost[1] = level_cost_2; sk.level_cost[2] = level_cost_3;
		skills.push(sk);
		return skills.size() - 1;
	}
	DD_Skill getSkill(uint id) { return id >= skills.size() ? null : skills[id]; }

	int getPlayerSkillLevel(PlayerPawn pp, int skill_id)
	{
		let skst = DD_SkillState(pp.findInventory("DD_SkillState"));
		if(skst)
			return skst.skill_levels[skill_id];
		return 0;
	}

	bool canUpgradeSkill(PlayerPawn pp, int skill_id)
	{
		DD_SkillState skst = DD_SkillState(pp.findInventory("DD_SkillState"));
		if(!skst)
			return false;
		DD_Skill sk = getSkill(skill_id);
		return skst.skill_levels[skill_id] < 3 && sk.level_cost[skst.skill_levels[skill_id]] <= pp.countInv("DD_SkillPoints");
	}
	play void upgradeSkill(PlayerPawn pp, int skill_id)
	{
		DD_SkillState skst = DD_SkillState(pp.findInventory("DD_SkillState"));
		DD_Skill sk = getSkill(skill_id);
		if(canUpgradeSkill(pp, skill_id))
		{ ++skst.skill_levels[skill_id]; pp.takeInventory("DD_SkillPoints", sk.level_cost[skst.skill_levels[skill_id] - 1]); }
	}

	double skill_points_mult;
	void updateSkillPointsMult()
	{
		skill_points_mult = CVar.getCVar("dd_skill_award_mult").getFloat();
	}
	play void awardEveryoneSkillPoints(uint amt)
	{
		amt = ceil(amt * skill_points_mult);
		for(uint i = 0; i < MAXPLAYERS; ++i)
			if(playeringame[i])
				players[i].mo.GiveInventory("DD_SkillPoints", amt);
	}
}
