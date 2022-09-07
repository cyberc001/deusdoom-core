class UI_DDLabel : UI_Widget
{
	// Should be set explicitly:
	ui String text;
	ui Font text_font;
	ui int text_color;
	ui double text_w, text_h; // used for rendering string, obey the same rules as UI_Draw.str() method.

	override void drawOverlay(RenderEvent e)
	{
		UI_Draw.str(text_font, text, text_color, x, y, text_w, text_h);
	}
}	
