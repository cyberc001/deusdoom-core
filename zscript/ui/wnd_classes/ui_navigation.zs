class UI_Navigation : UI_Window
{
	// Fonts
	ui Font aug_font;
	ui Font aug_font_bold;

	// Textures
	ui TextureID bg;
	ui TextureID frame;

	UI_Window child_wnd;

	// Widgets
	array<UI_DDNavigationButton> nav_butns;

	override void UIinit()
	{
		x = 0; y = 0;
		w = 250; h = 40;

		// Fonts
		aug_font = Font.GetFont("DD_UI");
		aug_font_bold = Font.GetFont("DD_UIBold");

		// Textures
		bg = TexMan.CheckForTexture("DXUI09");
		frame = TexMan.CheckForTexture("DXUI10");

		// Widgets
		double cx = 11;
		for(uint i = 0; i < allClasses.size(); ++i)
			if(allClasses[i] is "UI_Window" && !allClasses[i].isAbstract() && !(allClasses[i] is "UI_Navigation")){
				let wnd = UI_Window(new(allClasses[i]));
				if(!wnd.getName()){
					wnd.destroy();
					continue;
				}
				nav_butns.push(UI_DDNavigationButton(new("UI_DDNavigationButton")));
				uint s = nav_butns.size() - 1;
				nav_butns[s].x = cx; nav_butns[s].y = 3.5;
				nav_butns[s].w = UI_Draw.strWidth(aug_font, wnd.getName(), 0, 6 - 2) + 6; nav_butns[s].h = 6;
				nav_butns[s].text = wnd.getName();
				nav_butns[s].text_font = aug_font;
				nav_butns[s].text_color = 0xFFFFFF;
				nav_butns[s].parent_nav = self; nav_butns[s].wnd_togg_event = wnd.getToggEvent();
				addWidget(nav_butns[s]);
				wnd.destroy();
				cx += UI_Draw.strWidth(aug_font, wnd.getName(), 0, 6 - 2) + 8.5;
			}
		let exit_butn = UI_DDExitButton(new("UI_DDExitButton"));
		exit_butn.x = 234; exit_butn.y = 3.5;
		exit_butn.w = 18; exit_butn.h = 6;
		exit_butn.text = "Exit";
		exit_butn.text_font = aug_font;
		exit_butn.text_color = 0xFFFFFF;
		exit_butn.parent_nav = self;
		addWidget(exit_butn);
	}

	override void drawOverlay(RenderEvent e)
	{
		UI_Draw.texture(bg, x + 8, y + 2, 0, 9);
		UI_Draw.texture(frame, x + 1.5, y, 0, 26);

		super.drawOverlay(e);
	}

	override bool demandsUIProcessor() { return true; }

	override void UITick()
	{
		super.UITick();
		if(container && (!child_wnd || !container.hasWindow(child_wnd)))
			container.closeWindow(ev_handler, self);
	}

	override void close()
	{
		if(child_wnd && container.hasWindow(child_wnd))
			container.closeWindow(ev_handler, child_wnd);
		child_wnd = null;
	}
}
