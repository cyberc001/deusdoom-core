struct DD_EventHandlerQueue
{
	// queued state of ui processor
	bool qstate;
	bool ui_init;
}

class DD_EventHandler : StaticEventHandler
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
		ui UI_Skills wnd_skills;

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

	override void consoleProcess(ConsoleEvent e)
	{
		if(e.name == "dd_toggle_ui_skills")
		{
			// Open/close skills UI
			// Arguments: none
			wndmgr.addWindow(self, wnd_skills, 7.5, 5);
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		PlayerInfo plr = players[e.Player];
		if(!plr || !plr.mo)
			return;

		if(e.name == "dd_upgrade_skill"){
			skill_utils.upgradeSkill(plr.mo, e.args[0]);
		}
	}

	override void UiTick()
	{
		if(!queue.ui_init)
		{
			queue.ui_init = true;
			if(!wndmgr)
			{
				aug_ui_font = Font.getFont("DD_UI");
				aug_ui_font_bold = Font.getFont("DD_UIBold");
				aug_overlay_font_bold = Font.getFont("DD_OverlayBold");
				wndmgr = new("UI_WindowManager");
				wnd_skills = new("UI_Skills");
			}
		}
		if(wndmgr)
			wndmgr.uiTick();
	}
}
