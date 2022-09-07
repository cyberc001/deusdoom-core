// Collection of functions for drawing objects over UI.

enum UI_DrawFlags
{
	UI_Draw_FlipX = 1,
	UI_Draw_FlipY = 2
}
class UI_Draw
{

	// Name: UI_Draw::texture
	// Description:
	// Draw a texture on screen within 320x200 resolution.
	// Arguments:
	//	id - texture id, obtained through TexMan methods.
	//	x, y - location of texture on screen (top left corner).
	//	w, h - destination size of texture.
	//	       one of dimensions can be passed as:
	//	       -1 - to keep original value of dimension.
	//	        0 - to fit original aspect ratio.
	//	       <0 - to have their original value multiplied by absolute value of passed value.
	// Return value:
	//	double - value of dimension that was fit to aspect ratio, or 0.0 if none.
	static ui double texture(TextureID id, double x, double y, double w, double h, UI_DrawFlags flags = 0, double alpha = 1.0)
	{
		int tex_w, tex_h;
		[tex_w, tex_h] = TexMan.GetSize(id);
		double ret_val = 0.0;
	
		if(w == 0){
			w = h * (double(tex_w)/tex_h);
			ret_val = w;
		}
		else if(w < 0){
			w = tex_w * -w;
		}
		if(h == 0){
			h = w * (double(tex_h)/tex_w);
			ret_val = h;
		}
		else if(h < 0){
			h = tex_h * -h;
		}

		x = x / 320 * Screen.getWidth();
		y = y / 200 * Screen.getHeight();
		w = w / 320 * Screen.getWidth();
		h = h / 200 * Screen.getHeight();
		Screen.DrawTexture(id, false,
					x, y,
					//DTA_320X200, true,
					DTA_LEFTOFFSETF, 0.0,
					DTA_TOPOFFSETF, 0.0,
					DTA_DESTWIDTHF, w,
					DTA_DESTHEIGHTF, h,
					DTA_FLIPX, flags & UI_Draw_FlipX,
					DTA_FLIPY, flags & UI_Draw_FlipY,
					DTA_ALPHA, alpha);

		return ret_val;
	}

	// Name: UI_Draw::textureStencil
	// Description:
	// same as texture(), but stenciled with a specified color
	// Arguments:
	//	id - texture id, obtained through TexMan methods.
	//	x, y - location of texture on screen (top left corner).
	//	w, h - destination size of texture.
	//	       one of dimensions can be passed as:
	//	       -1 - to keep original value of dimension.
	//	        0 - to fit original aspect ratio.
	//	       <0 - to have their original value multiplied by absolute value of passed value.
	//	clr - color to fill texture with.
	// Return value:
	//	double - value of dimension that was fit to aspect ratio, or 0.0 if none.
	static ui double textureStencil(TextureID id, double x, double y, double w, double h,
					int clr, UI_DrawFlags flags = 0)
	{
		int tex_w, tex_h;
		[tex_w, tex_h] = TexMan.GetSize(id);
		double ret_val = 0.0;
	
		if(w == 0){
			w = h * (double(tex_w)/tex_h);
			ret_val = w;
		}
		else if(w < 0){
			w = tex_w * -w;
		}
		if(h == 0){
			h = w * (double(tex_h)/tex_w);
			ret_val = h;
		}
		else if(h < 0){
			h = tex_h * -h;
		}

		x = x / 320 * Screen.getWidth();
		y = y / 200 * Screen.getHeight();
		w = w / 320 * Screen.getWidth();
		h = h / 200 * Screen.getHeight();
		Screen.DrawTexture(id, false,
					x, y,
					DTA_LEFTOFFSETF, 0.0,
					DTA_TOPOFFSETF, 0.0,
					DTA_DESTWIDTHF, w,
					DTA_DESTHEIGHTF, h,
					DTA_FILLCOLOR, clr,
					DTA_FLIPX, flags & UI_Draw_FlipX,
					DTA_FLIPY, flags & UI_Draw_FlipY);

		return ret_val;
	}

	// Name: UI_Draw::str
	// Description:
	// Draws a string on screen within 320x200 resolution.
	// Arguments:
	//	font - font object, obtained through Font.GetFont() static method.
	//	clr - color of displayed string.
	//	x, y - location of text on screen (top left corner).
	//	w, h - destination size of string.
	//	       one of dimensions can be passed as:
	//	       -1 - to keep original value of dimension.
	//	        0 - to fit original aspect ratio.
	//	       <0 - to have their original value multiplied by absolute value of passed value.
	static ui void str(Font font, string text, int clr, double x, double y, double w, double h)
	{
		double font_w = font.StringWidth(text);
		double font_h = font.GetHeight();
		
		if(w == 0){
			w = h * (double(font_w)/font_h);
		}
		else if(w < 0){
			w = font_w * -w;
		}
		if(h == 0){
			h = w * (double(font_h)/font_w);
		}
		else if(h < 0){
			h = font_h * -h;
		}

		Screen.DrawText(font, clr,
					x * (double(font_w) / w), y * (double(font_h) / h),
					text,
					DTA_VIRTUALWIDTHF, font_w * 320 / w,
					DTA_VIRTUALHEIGHTF, font_h * 200 / h,
					DTA_KEEPRATIO, true
					);
	}


	// Name: UI_Draw::texWidth
	// Description:
	// Returns width of a texture in 320x200 resolution.
	// Arguments:
	//	id - id of texture being rendered.
	//	w, h - destination size dimensions (for scaling/fitting to aspect ratio)
	static ui double texWidth(TextureID id, double w, double h)
	{
		int tex_w, tex_h;
		[tex_w, tex_h] = TexMan.GetSize(id);
		if(w == 0){
			w = h * (double(tex_w)/tex_h);
		}
		else if(w < 0){
			w = tex_w * -w;
		}
		return w;
	}
	// Name: UI_Draw::texHeight
	// Description:
	// Returns height of a texture in 320x200 resolution.
	// Arguments:
	//	id - id of texture being rendered.
	//	w, h - destination size dimensions (for scaling/fitting to aspect ratio)
	static ui double texHeight(TextureID id, double w, double h)
	{
		int tex_w, tex_h;
		[tex_w, tex_h] = TexMan.GetSize(id);
		if(h == 0){
			h = w * (double(tex_h)/tex_w);
		}
		else if(h < 0){
			h = tex_h * -h;
		}
		return h;
	}

	// Name: UI_Draw::strWidth
	// Description:
	// Returns width of a string in 320x200 resolution.
	// Arguments:
	//	font - font of the string being rendered.
	//	text - a source string.
	//	w, h - desination size dimensions (for scaling/fitting to aspect ratio)
	// Return value:
	//	width of the string.
	static ui double strWidth(Font font, string text, double w, double h)
	{
		double font_w = font.StringWidth(text);
		double font_h = font.GetHeight();
		if(w == 0){
			w = h * (double(font_w)/font_h);
		}
		else if(w < 0){
			w = font_w * -w;
		}
		return w;
	}
	// Name: UI_Draw::strHeight
	// Description:
	// Returns height of a string in 320x200 resolution.
	// Arguments:
	//	font - font of the string being rendered.
	//	text - a source string.
	//	w, h - desination size dimensions (for scaling/fitting to aspect ratio)
	// Return value:
	//	height of the string.
	static ui double strHeight(Font font, string text, double w, double h)
	{
		double font_w = font.StringWidth(text);
		double font_h = font.GetHeight();
		if(h == 0){
			h = w * (double(font_h)/font_w);
		}
		else if(h < 0){
			h = font_h * -h;
		}
		return h;
	}

}
