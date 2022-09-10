class UI_Inventory : UI_Window
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

	override String getName() { return "Inventory"; }
	override String getToggEvent() { return "dd_toggle_ui_inventory"; }

	override void UIinit()
	{
		x = 7.5; y = 18;
		w = 105; h = 150;

		// Fonts
		aug_font = Font.GetFont("DD_UI");
		aug_font_bold = Font.GetFont("DD_UIBold");

		// Textures
		bg = TexMan.CheckForTexture("DXUI07");
		frame = TexMan.CheckForTexture("DXUI08");
	}

	override void drawOverlay(RenderEvent e)
	{
		UI_Draw.texture(bg, x + 6, y - 1.5, 0, 149);
		UI_Draw.texture(frame, x - 7.5, y - 5, 0, 180);

		UI_Draw.str(aug_font_bold, "Inventory", 11, 18, 18, 0, 5);
		UI_Draw.str(aug_font_bold, "Credits", 11, 85, 18, 0, 5);
		UI_Draw.str(aug_font_bold, "0", 11, 107, 18.5, 0, 4.5);

		super.drawOverlay(e);
	}

	override bool demandsUIProcessor() { return true; }

	override bool processUIInput(UiEvent e)
	{
		super.processUIInput(e);
		if(e.type == UiEvent.Type_KeyDown)
		{
			if(KeyBindUtils.checkBind(KeyBindUtils.keyCharToScan(e.KeyChar), "dd_togg_ui_inventory")
			|| e.KeyChar == UiEvent.Key_Escape)
			{
				container.closeWindow(ev_handler, self);
			}
		}	
		return false;
	}
}
