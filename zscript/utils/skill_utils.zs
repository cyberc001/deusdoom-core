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
}

class DD_SkillPoints : Inventory
{
	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 999999;
		Inventory.InterHubAmount 999999;
	}
}

class SkillUtils
{
	array<DD_Skill> skills;

	void registerSkill(string _name, string desc, TextureID icon, int level_cost_1, int level_cost_2, int level_cost_3)
	{
		DD_Skill sk = new("DD_Skill");
		sk._name = _name;
		sk.desc = desc;
		sk.icon = icon;
		sk.level_cost[0] = level_cost_1; sk.level_cost[1] = level_cost_2; sk.level_cost[2] = level_cost_3;
		skills.push(sk);
	}
	DD_Skill getSkill(uint id) { return id >= skills.size() ? null : skills[id]; }

	int getPlayerSkillLevel(PlayerPawn pp, int skill_id)
	{
		return DD_SkillState(pp.findInventory("DD_SkillState")).skill_levels[skill_id];
	}

	bool canUpgradeSkill(PlayerPawn pp, int skill_id)
	{
		DD_SkillState skst = DD_SkillState(pp.findInventory("DD_SkillState"));
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
}
