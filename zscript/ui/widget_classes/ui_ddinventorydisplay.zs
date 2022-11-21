class UI_DDInventoryDisplay : UI_Widget
{
	UI_Inventory parent_wnd;
	Font font;

	DD_InventoryWrapper grabbed_item;
	int grab_x, grab_y; // relative to the item
	DD_InventoryWrapper selected_item;

	int last_mouse_x, last_mouse_y;
	int mouse_delta; // accumulated absolute value of mouse movement until an item is finally grabbed (grabbing == 1)
	const mouse_delta_max = 8;
	int grabbing; // 0 - mouse button not pressed, 1 - mouse button pressed, item not grabbed yet, 2 - mouse button pressed, item grabbed

	TextureID wepmod_overlay;
	TextureID select_rect;

	override void UIInit()
	{
		wepmod_overlay = TexMan.CheckForTexture("DXUI11");
		select_rect = TexMan.CheckForTexture("DXUI12");
		last_mouse_x = last_mouse_y = -1;
	}

	TextureID getItemTex(Inventory item)
	{
		TextureID tex = item.Icon;
		if(!tex) tex = item.AltHUDIcon;
		if(!tex && item.SpawnState) tex = item.SpawnState.getSpriteTexture(0);
		return tex;
	}

	override void drawOverlay(RenderEvent e)
	{
		PlayerInfo plr = players[consoleplayer];
		let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));

		// render a highlight rectangle under selected item
		if(!grabbed_item && selected_item){
			if(ddih.items.find(selected_item) == ddih.items.size())
				selected_item = null;
			else
				UI_Draw.texture(select_rect, x + selected_item.x * 22, y + selected_item.y * 22 - 0.5, 22 * selected_item.w, 22 * selected_item.h);
		}

		name ddwepcls = "DDWeapon";
		// render green tint over weapons to which grabbed weapon mod is applicable to
		if(grabbed_item && grabbed_item.item is "DDItem"){
			for(uint i = 0; i < ddih.items.size(); ++i){
				Inventory item = ddih.items[i].item;
				DD_InventoryWrapper wrap = ddih.items[i];
				if(!(item is ddwepcls) || !DDItem(grabbed_item.item).isApplicable(item))
					continue;
				UI_Draw.texture(wepmod_overlay, x + wrap.x * 22, y + wrap.y * 22 - 0.5, 22 * wrap.w, 22 * wrap.h);
			}	
		}

		// render all the items
		for(uint i = 0; i < ddih.items.size(); ++i){
			if(ddih.items[i] == grabbed_item)
				continue;
			Inventory item = ddih.items[i].item;
			DD_InventoryWrapper wrap = ddih.items[i];
			if(item && getItemTex(item))
				UI_Draw.texture(getItemTex(item), x + 4 + wrap.x * 22 + wrap.icon_x, y + 2 + wrap.y * 22 + wrap.icon_y, 0, (15 + 22 * (wrap.h - 1)) * wrap.icon_mulh);
			string str = " ";
			if(!ddwepcls || !(item is ddwepcls) || (!Weapon(item).AmmoType1 && wrap.amount > 1)) str = string.format("Count: %d", wrap.amount);
			else if(ddwepcls){
				Inventory ammo = item.owner.findInventory(Weapon(item).AmmoType1);
				if(ammo) str = ammo.getTag(ammo.getClassName());
				else str = " ";
			}
			double text_midx = ((x + wrap.x * 22) + (22 * wrap.w) / 2) - UI_Draw.StrWidth(font, str, 0, 3.5) / 2;
			UI_Draw.str(font, str, 0xFFFFFF, text_midx, y + 17 + wrap.y * 22 + 22 * (wrap.h - 1), 0, 3.5);
			
			// render hotbar weapon slot key
			int hbslot = ddih.findHotbarSlot(wrap);
			if(hbslot != -1)
				UI_draw.str(font, String.Format("%d", hbslot + 1 == 10 ? 0 : hbslot + 1), 0xFFFFFF, x - 4 + wrap.w * 22 + wrap.x * 22, y + 2 + wrap.y * 22, 0, 3.5);
		}

		// render currently grabbed item
		if(grabbed_item)
			UI_Draw.texture(getItemTex(grabbed_item.item), last_mouse_x - grab_x * 22.5 + grabbed_item.icon_x, last_mouse_y - grab_y * 22.5 + grabbed_item.icon_y, 0, (15 + 22.5 * (grabbed_item.h - 1)) * grabbed_item.icon_mulh);
	}

	override void ProcessUIInput(UiEvent e)
	{
		PlayerInfo plr = players[consoleplayer];
		let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));

		int mousex = e.MouseX * 320 / Screen.getWidth();
		int mousey = e.MouseY * 200 / Screen.getHeight();

		if(e.type == UIEvent.Type_MouseMove){
			if(last_mouse_x != -1 && last_mouse_y != -1)
				mouse_delta += abs(last_mouse_x - mousex) + abs(last_mouse_y - mousey);
			last_mouse_x = mousex; last_mouse_y = mousey;
			if(mouse_delta >= mouse_delta_max && grabbing == 1){
				grabbed_item = selected_item;
				grabbing = 2; mouse_delta = 0;
			}
		}

		if(e.type == UIEvent.Type_LButtondown){
			bool select = false;
			for(uint i = 0; i < ddih.items.size(); ++i)
				if(last_mouse_x >= x + ddih.items[i].x * 22.5 && last_mouse_x <= x + ddih.items[i].x * 22.5 + 20.7 * ddih.items[i].w
				&& last_mouse_y >= y + ddih.items[i].y * 22.5 && last_mouse_y <= y + ddih.items[i].y * 22.5 + 20.7 * ddih.items[i].h){
					selected_item = ddih.items[i];
					grab_x = floor(last_mouse_x - x) / 22.5 - selected_item.x; grab_y = floor(last_mouse_y - y) / 22.5 - selected_item.y;
					select = true;
					break;
			}
			if(!select){
				selected_item = null;
			}
			mouse_delta = 0; grabbing = 1;
		}
		else if(e.type == UIEvent.Type_LButtonUp){
			DD_InventoryWrapper apply_to = null;
			if(grabbed_item && grabbed_item.item && grabbed_item.item is "DDItem")
				for(uint i = 0; i < ddih.items.size(); ++i)
					if(mousex >= x + ddih.items[i].x * 22.5 && mousex <= x + ddih.items[i].x * 22.5 + 20.7 * ddih.items[i].w
					&& mousey >= y + ddih.items[i].y * 22.5 && mousey <= y + ddih.items[i].y * 22.5 + 20.7 * ddih.items[i].h
					&& DDItem(grabbed_item.item).isApplicable(ddih.items[i].item)){
						apply_to = ddih.items[i];
						break;
					}
			if(!apply_to){
				int x = floor((mousex - x) / 22.5), y = floor((mousey - y) / 22.5);
				EventHandler.SendNetworkEvent("dd_inventory_move_item", ddih.items.find(grabbed_item), x - grab_x, y - grab_y);
				grabbed_item = null;
				grabbing = 0;
			}
			else{
				EventHandler.SendNetworkEvent("dd_inventory_use_item", ddih.items.find(grabbed_item), ddih.items.find(apply_to));
				grabbed_item = null;
				grabbing = 0;
			}
		}
		else if(e.type == UIEvent.Type_KeyDown)
		{
			if(selected_item)
				for(uint i = 1; i <= 10; ++i)
					if(KeyBindUtils.checkBind(KeyBindUtils.keyCharToScan(e.KeyChar), String.format("slot %u", i == 10 ? 0 : i))){
						EventHandler.SendNetworkEvent("dd_inventory_set_hotbar", i - 1, ddih.items.find(selected_item));
						break;
					}
		}
	}

	override void UITick()
	{
		if(parent_wnd){
			if(selected_item && selected_item.item){
				parent_wnd.itemname.text = selected_item.item.getTag(" ");
				parent_wnd.itemdesc.text = selected_item.desc;
			}
			else{
				parent_wnd.itemname.text = " ";
				parent_wnd.itemdesc.text = " ";
			}
		}
	}
}

