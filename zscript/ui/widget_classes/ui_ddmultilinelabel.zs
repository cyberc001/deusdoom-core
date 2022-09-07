class UI_DDMultiLineLabel : UI_DDLabel
{
	ui double line_gap; // vertical gap between lines
	ui int scrolli; // scroll index (starting line offset)

	void scroll(int amt)
	{
		int linesonscr = h / (UI_Draw.strHeight(text_font, text, text_w, text_h) + line_gap);
		if(amt < 0)
			scrolli = max(scrolli + amt, 0);
		else{
			array<string> lines;
			text.split(lines, "\n");
			scrolli = min(lines.size() - linesonscr, scrolli + amt);
		}
	}

	override void drawOverlay(RenderEvent e)
	{
		// We don't account for wrapping lines yet
		array<string> lines;
		text.split(lines, "\n");
		double sx = x;
		double sy = y;
		for(uint i = scrolli; i < lines.size() && sy + UI_Draw.strHeight(text_font, lines[i], text_w, text_h) < y + h; ++i)
		{
			if(lines[i].length() > 0){
				UI_Draw.str(text_font, lines[i], text_color, sx, sy,
						text_w, text_h);
			}
			sy += UI_Draw.strHeight(text_font, lines[i], text_w, text_h) + line_gap;
		}
	}
}
