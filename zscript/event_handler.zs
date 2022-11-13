struct DD_EventHandlerQueue
{
	// queued state of ui processor
	bool qstate;
	bool ui_init;
}

class DD_EventHandlerBase : StaticEventHandler
{
	ui virtual void _ConsoleProcess(string e_name) {}
}

class DD_EventHandler : DD_EventHandlerBase
{
	SoundUtils snd_utils;
	RecognitionUtils recg_utils;
	SkillUtils skill_utils;
	SpawnUtils spawn_utils;
	DD_ModChecker mod_checker;
	DD_PatchChecker patch_checker;

	array<DD_InventoryWrapper> inv_descs;

	DD_EventHandlerQueue queue;

	// Font for augs holder
	ui Font aug_ui_font;
	ui Font aug_ui_font_bold;
	ui Font aug_overlay_font_bold;

	// Pickup borders
	ui TextureID entbd_lt;
	ui TextureID entbd_rt;
	ui TextureID entbd_lb;
	ui TextureID entbd_rb;
	ui TextureID entframe;

	// Hotbar background
	ui TextureID hotbar_bg;
	ui TextureID hotbar_frame;

	ui UI_WindowManager wndmgr;
		ui UI_Navigation wnd_nav;
		ui UI_Skills wnd_skills;
		ui UI_Inventory wnd_inventory;

	override void onRegister()
	{
		setOrder(999);

		snd_utils = new("SoundUtils");
		recg_utils = new("RecognitionUtils");
		recg_utils.loadLists();
		skill_utils = new("SkillUtils");
		skill_utils.updateSkillPointsMult();
		spawn_utils = new("SpawnUtils");
		mod_checker = new("DD_ModChecker");
		mod_checker.init();
		patch_checker = new("DD_PatchChecker");
		patch_checker.init();

		queue.qstate = false;

		proj_sw = new("DDLe_SWScreen");
		proj_gl = new("DDLe_GLScreen");
	}

	override void playerSpawned(PlayerEvent e)
	{
		PlayerPawn plr = players[e.PlayerNumber].mo;
		DD_SkillState skst = DD_SkillState(Inventory.Spawn("DD_SkillState"));
		if(plr.countInv("DD_SkillState") == 0)
			plr.addInventory(skst);
		else
			skst.destroy();

		DD_InventoryHolder ddih = DD_InventoryHolder(Inventory.Spawn("DD_InventoryHolder"));
		if(plr.countInv("DD_InventoryHolder") == 0)
			plr.addInventory(ddih);
		else{
			ddih.destroy();
			ddih = DD_InventoryHolder(plr.FindInventory("DD_InventoryHolder"));
		}
		ddih.GiveInventory("DD_SkillPoints", 4050);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		name ddwepcls = "DDWeapon";
		name ddcellcls = "DD_BioelectricCell";
		name ddaugcancls = "DD_AugmentationCanister";
		name ddaugupgrcls = "DD_AugmentationUpgradeCanister";
		name ddauglegdcls = "DD_AugmentationUpgradeCanisterLegendary";
		if(((ddwepcls && e.thing is ddwepcls) || e.thing is "DDItem" || e.thing is "Ammo"
			|| (ddcellcls && e.thing is ddcellcls) || (ddaugcancls && e.thing is ddaugcancls) || (ddaugupgrcls && e.thing is ddaugupgrcls) || (ddauglegdcls && e.thing is ddauglegdcls))
			&& !(e.thing is "DD_InventoryPickupWrapper")){
			let wrap = DD_InventoryPickupWrapper(Actor.Spawn("DD_InventoryPickupWrapper", e.thing.pos));
			wrap.init(Inventory(e.thing));
		}
	}

	override void worldTick()
	{
		self.isUIProcessor = queue.qstate;
		self.requireMouse = queue.qstate;
	}

	// Inventory pickup projections
	ui DDLe_ProjScreen proj_scr;
	DDLe_SWScreen proj_sw;
	DDLe_GLScreen proj_gl;
	ui DDLe_Viewport vwport;

	protected ui void pickup_prepareProjection()
	{
		CVar renderer_type = CVar.getCVar("vid_rendermode", players[consoleplayer]);

		if(renderer_type)
		{
			switch(renderer_type.getInt())
			{
				case 0: case 1: proj_scr = proj_sw; break;
				default:	proj_scr = proj_gl; break;
			}
		}
		else
			proj_scr = proj_gl;
	}

	override void renderUnderlay(RenderEvent e)
	{
		if(wndmgr)
			wndmgr.renderUnderlay(e);
		PlayerInfo plr = players[consoleplayer];
		// Inventory equip fake weapon sprite rendering
		if(plr.mo){
			let usewep = DD_InventoryUseWeapon(plr.mo.FindInventory("DD_InventoryUseWeapon"));
			if(usewep && usewep.item && usewep.item.item){
				TextureID sprtex = usewep.item.item.CurState.getSpriteTexture(8);
				double coff = 2;
				double texw = UI_Draw.texWidth(sprtex, -1, -1)
						* coff
						* abs(usewep.item.item.scale.x);
				double texh = UI_Draw.texHeight(sprtex, -1, -1)
						* coff
						* abs(usewep.item.item.scale.y);
				UI_Draw.texture(sprtex,
						160 - texw/2, 180 - texh/2,
						texw, texh,
						(usewep.item.item.scale.x < 0 ? UI_Draw_FlipX : 0)
						| (usewep.item.item.scale.y < 0 ? UI_Draw_FlipY : 0),
						0.4);
			}
		}
		// get what item player is currently looking at
		if(plr.mo){
			let pickup_tracer = new("DD_InventoryPickupTracer");
			pickup_tracer.source = plr.mo;
			vector3 dir = (Actor.AngleToVector(plr.mo.angle, cos(plr.mo.pitch)), -sin(plr.mo.pitch));
			pickup_tracer.trace(plr.mo.pos + (0, 0, PlayerPawn(plr.mo).viewHeight), plr.mo.curSector, dir, plr.mo.UseRange, 0);
			if(pickup_tracer.hit_obj || pickup_tracer.hit_actor){
				Actor hit_obj = null;
				if(pickup_tracer.hit_obj)
					hit_obj = pickup_tracer.hit_obj;
				else
					hit_obj = pickup_tracer.hit_actor;

				vwport.fromHUD();
				pickup_prepareProjection();

				proj_scr.cacheResolution();
				proj_scr.cacheFOV();
				proj_scr.orientForRenderOverlay(e);
				proj_scr.beginProjection();
				vector2 obj_norm;
				vector2 ind_pos;

				double height_dist_coff = 96 * hit_obj.height / (plr.mo.distance3D(hit_obj) == 0 ? 1 : plr.mo.distance3D(hit_obj));
				double radius_dist_coff = 96 * hit_obj.radius / (plr.mo.distance3D(hit_obj) == 0 ? 1 : plr.mo.distance3D(hit_obj));
				height_dist_coff = height_dist_coff <= 40 ? height_dist_coff : 40;
				height_dist_coff = height_dist_coff >= 6 ? height_dist_coff : 8;
				radius_dist_coff = radius_dist_coff <= 40 ? radius_dist_coff : 40;
				radius_dist_coff = radius_dist_coff >= 6 ? radius_dist_coff : 8;
				height_dist_coff *= pickup_tracer.hit_actor ? 2 : 1;
				radius_dist_coff *= pickup_tracer.hit_actor ? 2 : 1;

				// Left top
				proj_scr.projectWorldPos(hit_obj.pos + (0, 0, hit_obj.height / 2));
				obj_norm = proj_scr.projectToNormal();
				ind_pos = vwport.sceneToWindow(obj_norm);
				if(!vwport.isInside(obj_norm) || !proj_scr.isInScreen())
					return;
				ind_pos.x *= double(320) / screen.getWidth(); ind_pos.y *= double(200) / screen.getHeight();
				UI_Draw.texture(entbd_lt, ind_pos.x - radius_dist_coff, ind_pos.y - height_dist_coff, -0.2, -0.2);
				// Right top
				UI_Draw.texture(entbd_rt, ind_pos.x + radius_dist_coff, ind_pos.y - height_dist_coff, -0.2, -0.2);
				// Left bottom
				UI_Draw.texture(entbd_lb, ind_pos.x - radius_dist_coff, ind_pos.y + height_dist_coff, -0.2, -0.2);
				// Right bottom
				UI_Draw.texture(entbd_rb, ind_pos.x + radius_dist_coff, ind_pos.y + height_dist_coff, -0.2, -0.2);
				// Entity name
				string tdispname = pickup_tracer.hit_obj ? (pickup_tracer.hit_obj.item ? pickup_tracer.hit_obj.item.getTag("") : " ") : pickup_tracer.hit_actor.getTag("");
				UI_Draw.texture(entframe, ind_pos.x + 1, ind_pos.y + 1 - height_dist_coff,
						UI_Draw.strWidth(aug_ui_font, tdispname, -0.5, -0.5) + 2,
						UI_Draw.strHeight(aug_ui_font, tdispname, -0.5, -0.5) + 2);
				UI_Draw.str(aug_ui_font, tdispname, 0xFFFFFF,
					ind_pos.x + 2, ind_pos.y + 2 - height_dist_coff, -0.5, -0.5);
			}
		}
	}
	override void renderOverlay(RenderEvent e)
	{
		if(wndmgr)
			wndmgr.renderOverlay(e);

		/* Render inventory hotbar */
		PlayerInfo plr = players[consoleplayer];
		if(plr.mo){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(ddih){
				name ddwepcls = "DDWeapon";
				int yoff = ddih.hotbar_timer < ddih.hotbar_show_time ? 25 * (1 - double(ddih.hotbar_timer) / ddih.hotbar_show_time)
						: ddih.hotbar_timer > ddih.hotbar_show_time + ddih.hotbar_stay_time ? 25 * (double(ddih.hotbar_timer - ddih.hotbar_show_time - ddih.hotbar_stay_time) / (ddih.hotbar_hide_time))
						: 0;
				UI_Draw.texture(hotbar_bg, 160 - UI_Draw.texWidth(hotbar_bg, 0, 25)/2, 175 + yoff, 0, 25);
				UI_Draw.texture(hotbar_frame, 160 - UI_Draw.texWidth(hotbar_frame, 0, 25)/2, 175 + yoff, 0, 25);
				for(uint i = 0; i < DD_InventoryHolder.hotbar_size; ++i){
					if(ddih.hotbar[i]){
						DD_InventoryWrapper wrap = ddih.hotbar[i];
						Inventory item = wrap.item;
						UI_Draw.texture(wrap.item.AltHUDIcon, 171.5 - UI_Draw.texWidth(hotbar_bg, 0, 25)/2 - UI_Draw.texWidth(wrap.item.AltHUDIcon, 0, 12)/2 + 18.2*i, 179 + yoff, 0, 12);
						string str = " ";
						if(!ddwepcls || !(item is ddwepcls) || (!Weapon(item).AmmoType1 && wrap.amount > 1)) str = string.format("Count: %d", wrap.amount);
							else if(ddwepcls){
							Inventory ammo = item.owner.findInventory(Weapon(item).AmmoType1);
							if(ammo) str = ammo.getTag(ammo.getClassName());
							else str = " ";
						}
						UI_Draw.str(aug_ui_font, str, 0xFFFFFF, 172 - UI_draw.texWidth(hotbar_bg, 0, 25)/2 - UI_Draw.strWidth(aug_ui_font, str, 0, 2)/2 + 18.2*i, 192 + yoff, 0, 2);
					}
					UI_Draw.str(aug_ui_font, String.format("%u", i + 1 == 10 ? 0 : i + 1), 0xFFFFFF, 176 - UI_draw.texWidth(hotbar_bg, 0, 25)/2 + 18.2*i, 179 + yoff, 0, 3.5);
				}
			}
		}
	}


	override bool InputProcess(InputEvent e)
	{
		/* Process hotbar slot binds */
		bool block = false;
		PlayerInfo plr = players[consoleplayer];
		if(plr.mo){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(ddih && e.Type == UIEvent.Type_KeyDown){
				for(uint i = 1; i <= 10; ++i)
					if(KeyBindUtils.checkBind(e.keyScan, String.format("slot %u", i == 10 ? 0 : i)) && ddih.hotbar[i - 1]){
						EventHandler.SendNetworkEvent("dd_inventory_equip_item", ddih.items.find(ddih.hotbar[i - 1]));
						EventHandler.SendNetworkEvent("dd_inventory_show_hotbar");
						block = true;
						break;
					}
			}
		}

		if(wndmgr)
			if(wndmgr.inputProcess(e))
				return true;
		return block;
	}
	override bool UiProcess(UiEvent e)
	{
		if(wndmgr)
			if(wndmgr.uiProcess(e))
				return true;
		return false;
	}

	override void consoleProcess(ConsoleEvent e) { _ConsoleProcess(e.name); }
	override void _ConsoleProcess(string e_name)
	{
		if(e_name == "dd_toggle_ui_skills"){
			if(!wnd_nav.child_wnd){
				wndmgr.addWindow(self, wnd_skills);
				wnd_nav.child_wnd = wnd_skills;
				wndmgr.addWindow(self, wnd_nav);
			}
		}
		else if(e_name == "dd_toggle_ui_inventory"){
			if(!wnd_nav.child_wnd){
				wndmgr.addWindow(self, wnd_inventory);
				wnd_nav.child_wnd = wnd_inventory;
				wndmgr.addWindow(self, wnd_nav);
			}
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		PlayerInfo plr = players[e.Player];
		if(!plr || !plr.mo)
			return;

		if(e.name == "dd_upgrade_skill"){
			if(skill_utils.getSkill(e.args[0]))
				skill_utils.upgradeSkill(plr.mo, e.args[0]);
		} else if(e.name == "dd_inventory_move_item"){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(e.args[0] < ddih.items.size())
				ddih.moveItem(ddih.items[e.args[0]], e.args[1], e.args[2]);
		} else if(e.name == "dd_inventory_use_item"){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(e.args[0] < ddih.items.size() && e.args[1] < ddih.items.size())
				ddih.useItem(ddih.items[e.args[0]], ddih.items[e.args[1]]);
		} else if(e.name == "dd_inventory_drop_item"){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(e.args[0] < ddih.items.size())
				ddih.dropItem(ddih.items[e.args[0]]);
		} else if(e.name == "dd_inventory_equip_item"){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(e.args[0] < ddih.items.size())
				ddih.equipItem(ddih.items[e.args[0]]);
		} else if(e.name == "dd_inventory_set_hotbar"){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			if(e.args[1] < ddih.items.size())
				ddih.setHotbarSlot(e.args[0], ddih.items[e.args[1]]);
		} else if(e.name == "dd_inventory_show_hotbar"){
			let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
			ddih.showHotbar();
		}
	}

	override void UiTick()
	{
		if(!queue.ui_init)
		{
			queue.ui_init = true;
			if(!wndmgr){
				aug_ui_font = Font.getFont("DD_UI");
				aug_ui_font_bold = Font.getFont("DD_UIBold");
				aug_overlay_font_bold = Font.getFont("DD_OverlayBold");

				entbd_lt = TexMan.checkForTexture("DXUI13");
				entbd_rt = TexMan.checkForTexture("DXUI14");
				entbd_lb = TexMan.checkForTexture("DXUI15");
				entbd_rb = TexMan.checkForTexture("DXUI16");
				entframe = TexMan.checkForTexture("DXUI17");

				hotbar_bg = TexMan.checkForTexture("DXUI18");
				hotbar_frame = TexMan.checkForTexture("DXUI19");

				wndmgr = new("UI_WindowManager");
				wnd_nav = new("UI_Navigation");
				wnd_skills = new("UI_Skills");
				wnd_inventory = new("UI_Inventory");
			}
		}
		if(wndmgr)
			wndmgr.uiTick();
	}

	// Titlemap replacements
	override void CheckReplacement(ReplaceEvent e)
	{
		if(e.replacement && e.replacee)
			spawn_utils.addModReplacee(e.replacee, e.replacement);
		if(level.MapName == "TITLEMAP"){
			if(e.replacee == "EvilEye")
				e.replacement = "DD_DXLogo";
			else if(e.replacee == "ExplosiveBarrel")
				e.replacement = "DD_DXText";
		}
	}

	// Award skill points
	const skill_award_perhp = 0.05;
	const skill_award_perkill = 1.75;
	const skill_award_boss_minhp = 1000;
	const skill_award_boss_bonus = 200;
	override void WorldThingDied(WorldEvent e)
	{
		if(!e.thing.bISMONSTER || e.thing is "PlayerPawn")
			return;

		skill_utils.awardEveryoneSkillPoints(ceil(e.thing.GetSpawnHealth() * skill_award_perhp + skill_award_perkill) + (e.thing.bBOSS && e.thing.GetSpawnHealth() >= skill_award_boss_minhp ? skill_award_boss_bonus : 0));
	}
	override void WorldLoaded(WorldEvent e)
	{
		skill_utils.updateSkillPointsMult();
	}

	// Keep track of previous level secret amount
	double prev_level_secret_ratio;
	override void WorldUnloaded(WorldEvent e)
	{
		prev_level_secret_ratio = level.total_secrets == 0 ? 0.75
									: double(level.found_secrets) / level.total_secrets;
	}
}
