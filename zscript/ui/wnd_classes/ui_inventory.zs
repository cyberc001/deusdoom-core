class UI_Inventory : UI_Window
{
	// Fonts
	ui Font aug_font;
	ui Font aug_font_bold;

	// Textures
	ui TextureID bg;
	ui TextureID frame;

	ui TextureID ammo_icon;

	// Widgets
	UI_DDSkillButton skill_butns[11];
	UI_DDLabel skill_disp_name;
	UI_DDMultiLineLabel skill_disp_desc;

	UI_DDLabel itemname;
	UI_DDMultiLineLabel itemdesc;
	UI_DDInventoryDisplay invdisp;

	override String getName() { return "Inventory"; }
	override String getToggEvent() { return "dd_toggle_ui_inventory"; }

	override void UIinit()
	{
		x = 7.5; y = 18;
		w = 220; h = 150;

		// Fonts
		aug_font = Font.GetFont("DD_UI");
		aug_font_bold = Font.GetFont("DD_UIBold");

		// Textures
		bg = TexMan.CheckForTexture("DXUI07");
		frame = TexMan.CheckForTexture("DXUI08");
		ammo_icon = TexMan.CheckForTexture("DXICO01");

		// Widgets
		invdisp = UI_DDInventoryDisplay(new("UI_DDInventoryDisplay"));
		invdisp.x = x + 10; invdisp.y = y + 7;
		invdisp.w = 128 - invdisp.x; invdisp.h = 157 - invdisp.y;
		invdisp.font = aug_font;
		invdisp.parent_wnd = self;
		addWidget(invdisp);

		let usebutn = UI_DDUseButton(new("UI_DDUseButton"));
		usebutn.x = x + 30; usebutn.y = y + 139.5;
		usebutn.w = 15; usebutn.h = 6.5;
		usebutn.text = "Use"; usebutn.text_font = aug_font; usebutn.text_color = 0xFFFFFF;
		usebutn.invdisp = invdisp;
		addWidget(usebutn);

		let dropbutn = UI_DDDropButton(new("UI_DDDropButton"));
		dropbutn.x = x + 46; dropbutn.y = y + 139.5;
		dropbutn.w = 20; dropbutn.h = 6.5;
		dropbutn.text = "Drop"; dropbutn.text_font = aug_font; dropbutn.text_color = 0xFFFFFF;
		dropbutn.invdisp = invdisp;
		addWidget(dropbutn);

		let equipbutn = UI_DDEquipButton(new("UI_DDEquipButton"));
		equipbutn.x = x + 10; equipbutn.y = y + 139.5;
		equipbutn.w = 19; equipbutn.h = 6.5;
		equipbutn.text = "Equip"; equipbutn.text_font = aug_font; equipbutn.text_color = 0xFFFFFF;
		equipbutn.invdisp = invdisp;
		addWidget(equipbutn);

		let chgammobutn = UI_DDChangeAmmoButton(new("UI_DDChangeAmmoButton"));
		chgammobutn.x = x + 67; chgammobutn.y = y + 139.5;
		chgammobutn.w = 35; chgammobutn.h = 6.5;
		chgammobutn.text = "Change ammo"; chgammobutn.text_font = aug_font; chgammobutn.text_color = 0xFFFFFF;
		chgammobutn.invdisp = invdisp;
		addWidget(chgammobutn);

		itemname = UI_DDLabel(new("UI_DDLabel"));
		itemname.x = x + 147; itemname.y = y + 6;
		itemname.text_w = 0; itemname.text_h = 4;
		itemname.text_font = aug_font_bold; itemname.text_color = 0xFFFFFF;
		itemname.text = " ";
		addWidget(itemname);

		itemdesc = UI_DDMultiLineLabel(new("UI_DDMultiLineLabel"));
		itemdesc.x = x + 147; itemdesc.y = y + 15;
		itemdesc.h = 80;
		itemdesc.text_w = 0; itemdesc.text_h = 4;
		itemdesc.line_gap = 1;
		itemdesc.text_font = aug_font; itemdesc.text_color = 0xFFFFFF;
		itemdesc.text = " ";
		addWidget(itemdesc);
	}

	override void drawOverlay(RenderEvent e)
	{
		UI_Draw.texture(bg, x + 6, y - 1.5, 0, 149);
		UI_Draw.texture(frame, x - 7.5, y - 5, 0, 180);

		UI_Draw.texture(ammo_icon, x + 199, y + 118.5, 0, 20);

		UI_Draw.str(aug_font_bold, "Inventory", 0xFFFFFF, 18, 18, 0, 5);
		UI_Draw.str(aug_font_bold, "Credits", 0xFFFFFF, 85, 18, 0, 5);
		UI_Draw.str(aug_font_bold, "0", 0xFFFFFF, 107, 18.5, 0, 4.5);

		UI_Draw.str(aug_font, "Click icon to", 0xFFFFFF, x + 220, y + 121.5, 0, 4);
		UI_Draw.str(aug_font, "see a list of", 0xFFFFFF, x + 220, y + 126.5, 0, 4);
		UI_Draw.str(aug_font, "Ammo.", 0xFFFFFF, x + 226, y + 131.5, 0, 4);

		name ddwepcls = "DDWeapon";
		if(display_ammo){
			string ammo_types;
			for(uint i = 0; i < AllActorClasses.size(); ++i){
				if(AllActorClasses[i] is "Ammo"){
					Inventory inv = players[consoleplayer].mo.findInventory(AllActorClasses[i].getClassName());
					if(inv && inv.MaxAmount != 0xFFFFFFFF){
						int cnt = players[consoleplayer].mo.countInv(AllActorClasses[i].getClassName());
						if(cnt > 0)
							ammo_types = String.Format("%s%s: %d\n", ammo_types, inv.getTag(inv.getClassName()), cnt);
					}
				}
			}
			itemname.text = "Available ammo";
			itemdesc.text = ammo_types;
		}

		super.drawOverlay(e);
	}

	override bool demandsUIProcessor() { return true; }

	bool display_ammo;

	override bool processUIInput(UiEvent e)
	{
		super.processUIInput(e);
		if(e.type == UiEvent.Type_LButtonDown){
			int mousex = e.MouseX * 320 / Screen.getWidth();
			int mousey = e.MouseY * 200 / Screen.getHeight();
			display_ammo = (mousex >= x + 199 && mousex <= x + 199 + UI_Draw.texWidth(ammo_icon, 0, 20)
							&& mousey >= y + 118.5 && mousey <= y + 118.5 + 20);
		}
		else if(e.type == UiEvent.Type_KeyDown){
			if(KeyBindUtils.checkBind(KeyBindUtils.keyCharToScan(e.KeyChar), "dd_togg_ui_inventory")
			|| e.KeyChar == UiEvent.Key_Escape)
			{
				container.closeWindow(ev_handler, self);
			}
		}	
		return false;
	}
}

