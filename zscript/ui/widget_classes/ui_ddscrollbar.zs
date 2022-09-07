class UI_DDScrollBar : UI_Widget
{
	UI_DDMultiLineLabel mlabel;

	ui TextureID butn_up;
	ui TextureID butn_up_pr;
	ui TextureID butn_down;
	ui TextureID butn_down_pr;
	ui TextureID scrollbg;


	override void UIInit()
	{
		butn_up = TexMan.CheckForTexture("UIBUTN09");
		butn_up_pr = TexMan.CheckForTexture("UIBUTN10");
		butn_down = TexMan.CheckForTexture("UIBUTN07");
		butn_down_pr = TexMan.CheckForTexture("UIBUTN08");
		scrollbg = TexMan.CheckForTexture("AUGUI41");
	}

	override void drawOverlay(RenderEvent e)
	{
		UI_Draw.texture(butn_up, x, y, w, 0);
		UI_Draw.texture(scrollbg, x, y + UI_Draw.texHeight(butn_up, w, 0),
				w, h - UI_Draw.texHeight(butn_up, w, 0) - UI_Draw.texHeight(butn_down, w, 0));
		UI_Draw.texture(butn_down, x, y + h - UI_Draw.texHeight(butn_down, w, 0), w, 0);
	}


	override void processUIInput(UiEvent e)
	{
		if(e.type == UiEvent.Type_LButtonDown)
		{
			int mousey = e.MouseY * 240 / Screen.getHeight();
			if(mousey <= y + UI_Draw.texHeight(butn_up, w, 0))
			{ // go up
				if(mlabel) mlabel.scroll(-1);
			}
			else if(mousey >= y + h - UI_Draw.texHeight(butn_down, w, 0))
			{ // go down
				if(mlabel) mlabel.scroll(1);
			}
		}
	}
}
