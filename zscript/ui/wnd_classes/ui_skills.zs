class UI_Skills : UI_Window
{
	// Fonts
	ui Font aug_font;
	ui Font aug_font_bold;

	// Textures
	ui TextureID bg;
	ui TextureID frame;

	int selected_skill;

	// Widgets
	UI_DDSkillButton skill_butns[11];
	UI_DDLabel skill_disp_name;
	UI_DDMultiLineLabel skill_disp_desc;

	override String getName() { return "Skills"; }
	override String getToggEvent() { return "dd_toggle_ui_skills"; }

	override void UIinit()
	{
		x = 7.5; y = 18;
		w = 135; h = 180;

		// Fonts
		aug_font = Font.GetFont("DD_UI");
		aug_font_bold = Font.GetFont("DD_UIBold");

		// Textures
		bg = TexMan.CheckForTexture("DXUI03");
		frame = TexMan.CheckForTexture("DXUI04");

		// Widgets
		for(uint i = 0; i < 11; ++i){
			skill_butns[i] = UI_DDSkillButton(new("UI_DDSkillButton"));
			skill_butns[i].x = 13; skill_butns[i].y = 35 + i * 12.33;
			skill_butns[i].w = 137; skill_butns[i].h = 11.8;
			skill_butns[i].parent_wnd = self;

			skill_butns[i].skill_name_font = aug_font_bold;
			skill_butns[i].text_font = aug_font;
			skill_butns[i].text_color = 11;
			skill_butns[i].skill_id = i;
			addWidget(skill_butns[i]);
		}

		let butn_upgr = UI_DDSmallButton_UpgradeSkill(new("UI_DDSmallButton_UpgradeSkill"));
		butn_upgr.x = 12; butn_upgr.y = 170.5;
		butn_upgr.w = 25; butn_upgr.h = 6;
		butn_upgr.text = "Upgrade";
		butn_upgr.text_font = aug_font;	butn_upgr.text_color = 11;
		butn_upgr.parent_wnd = self;
		addWidget(butn_upgr);

		skill_disp_name = UI_DDLabel(new("UI_DDLabel"));
		skill_disp_name.x = 169; skill_disp_name.y = 28;
		skill_disp_name.text_w = 0; skill_disp_name.text_h = 5;
		skill_disp_name.text = " ";
		skill_disp_name.text_font = aug_font_bold; skill_disp_name.text_color = 11;
		addWidget(skill_disp_name);

		skill_disp_desc = UI_DDMultiLineLabel(new("UI_DDMultiLineLabel"));
		skill_disp_desc.x = 169; skill_disp_desc.y = 38;
		skill_disp_desc.h = 95;
		skill_disp_desc.text_w = 0; skill_disp_desc.text_h = 4;
		skill_disp_desc.line_gap = 1;
		skill_disp_desc.text = " ";
		skill_disp_desc.text_font = aug_font; skill_disp_desc.text_color = 11;
		addWidget(skill_disp_desc);
	}

	override void drawOverlay(RenderEvent e)
	{
		UI_Draw.texture(bg, x, y, 0, 163);
		UI_Draw.texture(frame, x - 8.2, y - 5.2, 0, 201.5);

		UI_Draw.str(aug_font_bold, "Skills", 11, 12, 19.5, 0, 6);

		UI_Draw.str(aug_font, "Skill Level", 11, 80, 29.5, 0, 4);
		UI_Draw.str(aug_font, "Points", 11, 115, 29.5, 0, 4);
		UI_Draw.str(aug_font, "Needed", 11, 135, 29.5, 0, 4);

		UI_Draw.str(aug_font_bold, "Skill Points", 11, 95, 173, 0, 4);
		UI_Draw.str(aug_font_bold, String.Format("%d", players[consoleplayer].mo.countInv("DD_SkillPoints")), 11, 123, 173, 0, 4);

		super.drawOverlay(e);
	}

	override bool demandsUIProcessor() { return true; }

	override bool processUIInput(UiEvent e)
	{
		super.processUIInput(e);
		if(e.type == UiEvent.Type_KeyDown)
		{
			if(KeyBindUtils.checkBind(KeyBindUtils.keyCharToScan(e.KeyChar), "dd_togg_ui_skills")
			|| e.KeyChar == UiEvent.Key_Escape)
			{
				container.closeWindow(ev_handler, self);
			}
		}	
		return false;
	}
}
