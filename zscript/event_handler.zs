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
	DD_ModChecker mod_checker;
	DD_PatchChecker patch_checker;

	DD_EventHandlerQueue queue;

	// Font for augs holder
	ui Font aug_ui_font;
	ui Font aug_ui_font_bold;
	ui Font aug_overlay_font_bold;

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
		mod_checker = new("DD_ModChecker");
		mod_checker.init();
		patch_checker = new("DD_PatchChecker");
		patch_checker.init();

		queue.qstate = false;
	}

	override void playerSpawned(PlayerEvent e)
	{
		PlayerPawn plr = players[e.PlayerNumber].mo;
		DD_SkillState skst = DD_SkillState(Inventory.Spawn("DD_SkillState"));
		if(plr.countInv("DD_SkillState") == 0)
			plr.addInventory(skst);
		else
			skst.destroy();
	}

	override void worldTick()
	{
		self.isUIProcessor = queue.qstate;
		self.requireMouse = queue.qstate;
	}

	override void renderUnderlay(RenderEvent e)
	{
		if(wndmgr)
			wndmgr.renderUnderlay(e);
	}
	override void renderOverlay(RenderEvent e)
	{
		if(wndmgr)
			wndmgr.renderOverlay(e);
	}


	override bool InputProcess(InputEvent e)
	{
		if(wndmgr)
			if(wndmgr.inputProcess(e))
				return true;
		return false;
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
			wndmgr.addWindow(self, wnd_skills);
			wnd_nav.child_wnd = wnd_skills;
			wndmgr.addWindow(self, wnd_nav);
		}
		else if(e_name == "dd_toggle_ui_inventory"){
			wndmgr.addWindow(self, wnd_inventory);
			wnd_nav.child_wnd = wnd_inventory;
			wndmgr.addWindow(self, wnd_nav);
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
				wndmgr = new("UI_WindowManager");
				wnd_nav = new("UI_Navigation");
				wnd_skills = new("UI_Skills");
				wnd_inventory = new("UI_Inventory");
			}
		}
		if(wndmgr)
			wndmgr.uiTick();
	}
}
