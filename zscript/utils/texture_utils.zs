class TextureUtils : Actor
{
	// Description:
	// Gets a sprite texture from a frame from actor's current state.
	// Return values:
	//	TextureID: sprite texture.
	//	bool: whether texture is flipped or not.
	//	bool: whether texture is wildcarded and default spawn state was used instead.
	static clearscope TextureID, bool, bool getActorSpriteTex(Actor ac, int byteang)
	{
		TextureID tex; bool flip;
		State st = ac.curState;

		bool wildcarded = false;
		if(!st.validateSpriteFrame()){
			[tex, flip] = ac.spawnState.getSpriteTexture(byteang);
			wildcarded = true;
		}
		else{
			[tex, flip] = st.getSpriteTexture(byteang);
		}
		return tex, !flip, wildcarded;
	}
	// Description:
	// Similar to getActorSpriteTexture, but byte angle is calculated depending on other actor's looking direction
	static clearscope TextureID, bool, bool getActorRenderSpriteTex(Actor ac, Actor looker)
	{
		double objang = deltaAngle(looker.angleTo(ac), ac.angle) + 180.0;
		int byteang =  ( (objang + 22.5) / 45) % 8;
		TextureID tex; bool flip; bool wildcarded;
		[tex, flip, wildcarded] = getActorSpriteTex(ac, byteang * 2);
		return tex, flip, wildcarded;
	}
}
