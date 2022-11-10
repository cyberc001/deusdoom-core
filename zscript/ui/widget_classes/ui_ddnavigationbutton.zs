class UI_DDNavigationButton : UI_DDSmallButton
{
	UI_Navigation parent_nav;
	string wnd_togg_event;

	override void processUIInput(UiEvent e)
	{
		super.processUIInput(e);
		if(e.type == UiEvent.Type_LButtonDown){
			if(parent_nav.container){
				parent_nav.container.closeWindow(parent_nav.ev_handler, parent_nav.child_wnd);
				parent_nav.container.closeWindow(parent_nav.ev_handler, parent_nav);
				for(uint i = 0; i < allClasses.size(); ++i){
					if(allClasses[i] is "DD_EventHandlerBase" && allClasses[i].getClassName() != "DD_EventHandlerBase"){
						DD_EventHandlerBase(StaticEventHandler.Find(allClasses[i].GetClassName()))._ConsoleProcess(wnd_togg_event);
					}
				}
			}
		}
	}
}
