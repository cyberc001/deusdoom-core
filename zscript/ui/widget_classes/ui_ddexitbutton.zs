class UI_DDExitButton : UI_DDSmallButton
{
	UI_Navigation parent_nav;

	override void processUIInput(UiEvent e)
	{
		if(pressed && e.type == UiEvent.Type_LButtonUp
		&& parent_nav.container)
			parent_nav.container.closeWindow(parent_nav.ev_handler, parent_nav);
		super.processUIInput(e);
	}
}
