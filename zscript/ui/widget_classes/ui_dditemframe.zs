class UI_DDItemFrame : UI_Widget
{
	ui class<Inventory> item_cls;	// item class to display
	ui Font disp_font;		// font of item's name and count
	ui string disp_name1;		// display name of the item, 1st line
	ui string disp_name2;		// display name of the item, 2nd line

	ui TextureID frame_tex;
	ui TextureID item_tex;		// item texture to display

	// Actual item texture dimensions
	ui double tex_w;
	ui double tex_h;
	// Item frame texture dimensions
	ui double frame_w;
	ui double frame_h;
	// Actual text dimensions
	ui double str_w;
	ui double str_h;

	override void UIInit()
	{
		frame_tex = TexMan.checkForTexture("AUGUI20");
	}

	override void drawOverlay(RenderEvent e)
	{
		PlayerInfo plr = players[consoleplayer];
		int cnt = plr.mo.countInv(item_cls);

		UI_Draw.texture(frame_tex, x, y, frame_w, frame_h);
		UI_Draw.texture(item_tex,
				x + UI_Draw.texWidth(frame_tex, frame_w, frame_h)/2
				  - UI_Draw.texWidth(item_tex, tex_w, tex_h)/2,
				y + UI_Draw.texHeight(frame_tex, frame_w, frame_h)/2
				  - UI_Draw.texHeight(item_tex, tex_w, tex_h)/2,
				tex_w, tex_h);
		UI_Draw.str(disp_font, disp_name1, 11, x+1, y+1, str_w, str_h);
		UI_Draw.str(disp_font, disp_name2, 11, x+1,
				y+1+UI_Draw.strHeight(disp_font, disp_name1, str_w, str_h), str_w, str_h);
		UI_Draw.str(disp_font, String.Format("%d", cnt), 11, x+1,
				y + UI_Draw.texHeight(frame_tex, frame_w, frame_h) - UI_Draw.strHeight(disp_font, disp_name1, str_w, str_h) - 1,
				str_w, str_h);
	}
}
