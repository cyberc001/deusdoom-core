class UI_DDSkillButton : UI_Widget
{
	ui TextureID norm_center, norm_left, norm_right;
	ui TextureID pressed_center, pressed_left, pressed_right;
	ui TextureID checklet;

	ui Font skill_name_font;
	ui Font text_font;
	ui int text_color;

	ui int skill_id;

	UI_Skills parent_wnd;

	ui bool pressed;
	ui bool disabled; // if false than it's pressable

	override void UIInit()
	{
		norm_center = TexMan.CheckForTexture("UIBUTN14");
		norm_left = TexMan.CheckForTexture("UIBUTN15");
		norm_right = TexMan.CheckForTexture("UIBUTN16");

		pressed_center = TexMan.CheckForTexture("UIBUTN11");
		pressed_left = TexMan.CheckForTexture("UIBUTN12");
		pressed_right = TexMan.CheckForTexture("UIBUTN13");

		checklet = TexMan.CheckForTexture("DXUI06");
	}


	override void drawOverlay(RenderEvent e)
	{
		TextureID left, right, center;
		if(pressed){left = pressed_left; right = pressed_right; center = pressed_center;}
		else	   {left = norm_left; right = norm_right; center = norm_center;}

		double dlx = UI_Draw.texWidth(left, 0, h);
		double drx = UI_Draw.texWidth(right, 0, h);
		UI_Draw.texture(left, x, y, 0, h);
		UI_Draw.texture(center, x + dlx, y, w - dlx - drx, h);
		UI_Draw.texture(right, x + w - drx, y, 0, h);

		DD_Skill sk = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.getSkill(skill_id);

		if(sk){
			int sk_lvl = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.getPlayerSkillLevel(players[consoleplayer].mo, skill_id);

			UI_Draw.texture(sk.icon, x + dlx, y + 2, 0, h - 4);
			UI_Draw.str(skill_name_font, sk._name, text_color, x + dlx + UI_Draw.texWidth(sk.icon, 0, h - 4) + 2, y + 4, 0, h - 7.5);
			UI_Draw.str(text_font,
						sk_lvl == 0 ? "UNTRAINED" : sk_lvl == 1 ? "TRAINED" : sk_lvl == 2 ? "ADVANCED" : "MASTER",
						text_color, x + dlx + UI_Draw.texWidth(sk.icon, 0, h - 4) + 57, y + 4, 0, h - 8);

			double sx = x + 102;
			double sy = y + 4;
			double chk_gap = 0.44;
			for(uint lvl = 0; lvl <= sk_lvl; ++lvl)
			{
				UI_Draw.texture(checklet, sx, sy, 0, h - 9);
				sx += UI_Draw.texWidth(checklet, 0, h - 9) + chk_gap;
			}

			if(sk_lvl < 3)
				UI_Draw.str(text_font, String.Format("%d", sk.level_cost[sk_lvl]), text_color, x + dlx + UI_Draw.texWidth(sk.icon, 0, h - 4) + 112, y + 4, 0, h - 8);
		}
	}


	override void processUIInput(UiEvent e)
	{
		if(disabled) return;

		if(e.type == UiEvent.Type_LButtonDown && DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.getSkill(skill_id)){
			parent_wnd.selected_skill = skill_id;
			parent_wnd.skill_disp_name.text = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.getSkill(skill_id)._name;
			parent_wnd.skill_disp_desc.text = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.getSkill(skill_id).desc;
			SoundUtils.uiStartSound("ui/menu/press", players[consoleplayer].mo);
		}
		pressed = parent_wnd.selected_skill == skill_id;
	}
}
