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
	DD_ModChecker mod_checker;
	DD_PatchChecker patch_checker;

	DD_EventHandlerQueue queue;

	// Font for augs holder
	ui Font aug_ui_font;
	ui Font aug_ui_font_bold;
	ui Font aug_overlay_font_bold;

	ui UI_WindowManager wndmgr;

	override void onRegister()
	{
		setOrder(999);

		snd_utils = new("SoundUtils");
		recg_utils = new("RecognitionUtils");
		recg_utils.loadLists();
		mod_checker = new("DD_ModChecker");
		mod_checker.init();
		patch_checker = new("DD_PatchChecker");
		patch_checker.init();

		queue.qstate = false;
	}

	override void worldTick()
	{
		snd_utils.worldTick();

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
			}
		}
		if(wndmgr)
			wndmgr.uiTick();
	}
}