class UI_DDSmallButton : UI_Widget
{
	ui TextureID norm_center, norm_left, norm_right;
	ui TextureID pressed_center, pressed_left, pressed_right;

	ui Font text_font;
	ui int text_color;
	ui String text;

	ui bool pressed;
	ui bool disabled; // if false than it's pressable

	override void UIInit()
	{
		norm_center = TexMan.CheckForTexture("UIBUTN01");
		norm_left = TexMan.CheckForTexture("UIBUTN02");
		norm_right = TexMan.CheckForTexture("UIBUTN03");

		pressed_center = TexMan.CheckForTexture("UIBUTN04");
		pressed_left = TexMan.CheckForTexture("UIBUTN05");
		pressed_right = TexMan.CheckForTexture("UIBUTN06");
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

		UI_Draw.str(text_font, text, text_color, x + dlx + 0.5, y + 1, 0, h - 2);
	}


	override void processUIInput(UiEvent e)
	{
		if(disabled) return;

		if(e.type == UiEvent.Type_LButtonDown){
			pressed = true;
			SoundUtils.uiStartSound("ui/menu/press", players[consoleplayer].mo);
		}
		else if(e.type == UiEvent.Type_LButtonUp){
			pressed = false;
		}
	}
}
