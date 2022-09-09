#include "zscript/ui/wnd_classes/ui_skills.zs"

class UI_WindowManager ui
{
	// List of currently existing windows.
	ui Array<UI_Window> wnds;


	// -----------------------------------------------------
	// Engine events that should be called from EventHandler
	// -----------------------------------------------------

	ui void renderUnderlay(RenderEvent e)
	{
		for(uint i = 0; i < wnds.size(); ++i)
			wnds[i].drawUnderlay(e);
	}
	ui void renderOverlay(RenderEvent e)
	{
		for(uint i = 0; i < wnds.size(); ++i)
			wnds[i].drawOverlay(e);
	}
	ui bool uiProcess(UiEvent e)
	{
		if(e.type == UiEvent.Type_LButtonDown
		|| e.type == UiEvent.Type_RButtonDown
		|| e.type == UiEvent.Type_MButtonDown)
		{
			int mousex = e.MouseX * 320 / screen.getWidth();
			int mousey = e.MouseY * 200 / screen.getHeight();
			for(uint i = 0; i < wnds.size(); ++i)
			{
				if(mousex >= wnds[i].x && mousey >= wnds[i].y
				&& mousex <= wnds[i].x + wnds[i].w
				&& mousey <= wnds[i].y + wnds[i].h)
				{
					wnds[i].processUIInput(e);
				}
			}
			return false;
		}
		else
		{
			bool block_next = false;
			for(uint i = 0; i < wnds.size(); ++i)
			{
				if(wnds[i].processUIInput(e))
					block_next = true;
			}
			return block_next;
		}
	}
	ui bool inputProcess(InputEvent e)
	{
		bool block_next = false;
		for(uint i = 0; i < wnds.size(); ++i)
		{
			if(wnds[i].processInput(e))
				block_next = true;
		}
		return block_next;
	}
	ui void uiTick()
	{
		for(uint i = 0; i < wnds.size(); ++i)
		{
			if(!wnds[i].ui_init){
				wnds[i].ui_init = true;
				wnds[i].UIInit();
			}
			wnds[i].uiTick();
		}
	}

	// ------------------------------
	// Functions for managing windows
	// ------------------------------

	// Name: UI_WindowManager::addWindow()
	// Description:
	//	Adds a window to list of currently existing windows.
	// Arguments:
	//	eh - event handler which call this function.
	//	wnd - window object.
	//	x, y - coordinates of window's top left corner.
	ui void addWindow(DD_EventHandler eh, UI_Window wnd, double x = 0, double y = 0)
	{
		wnds.push(wnd);
		wnd.x = x;
		wnd.y = y;
		wnd.container = self;
		wnd.ev_handler = eh;

		if(wnd.demandsUIProcessor())
			eh.queue.qstate = true;
	}

	// Name: UI_WindowManager::closeWindow()
	// Description:
	//	Removes a window from list of currently existing windows.
	// Arguments:
	//	wnd - window object.
	ui void closeWindow(DD_EventHandler eh, UI_Window wnd)
	{
		uint wnd_i = wnds.find(wnd);
		if(wnd_i == wnds.size()) // window does not exist
			return;

		if(wnds[wnd_i].demandsUIProcessor())
			eh.queue.qstate = false;
		wnds[wnd_i].container = null;
		wnds[wnd_i].close();
		wnds.delete(wnd_i);
	}

	// Name: UI_WindowManager::hasWindow()
	// Description:
	//	Tries to find a target window object in the list of existing windows.
	// Arguments:
	//	wnd - window object.
	// Return value:
	//	true - window is present in the list.
	//	false - window is not in the list.
	ui bool hasWindow(UI_Window wnd)
	{
		return wnds.find(wnd) != wnds.size();
	}
}

class UI_Window ui
{
	ui double x, y; // window top-left coordinates
	// (can be, should not be implicitly changed in create(), but in UI_WindowManager.addWindow())
	ui double w, h; // actual window size (for input processing)

	// List of currently present widgets (for event handling and drawing)
	// Everything linked to them is handled in virtual functions,
	// so library user can just call superclass version of the function
	// first.
	ui array<UI_Widget> widgets;

	// Window manager that contains the window.
	// Gets set to NULL pointer if when the window is closed.
	ui UI_WindowManager container;

	// Event handler which processes window's windows manager events.
	ui DD_EventHandler ev_handler;

	// ------------------------
	// Window management events
	// ------------------------

	ui bool ui_init;

	// Called when attempted to render the first time.
	ui virtual void UIInit() {}
	ui virtual void close() {}


	// --------------
	// Drawing events
	// --------------

	// Called from RenderUnderlay() event
	ui virtual void drawUnderlay(RenderEvent e)
	{
		for(uint i = 0; i < widgets.size(); ++i)
		{
			if(!widgets[i].hidden)
				widgets[i].drawUnderlay(e);
		}
	}

	// Called from RenderOverlay() event
	ui virtual void drawOverlay(RenderEvent e)
	{
		for(uint i = 0; i < widgets.size(); ++i)
		{
			if(!widgets[i].hidden)
				widgets[i].drawOverlay(e);
		}
	}


	// ------------
	// Input events
	// ------------

	ui virtual bool demandsUIProcessor() { return false; }

	// Called from UiProcess() event,
	// and only if demandsUIProcessor == true.
	ui virtual bool processUIInput(UiEvent e)
	{
		if(e.type == UiEvent.Type_LButtonDown
		|| e.type == UiEvent.Type_RButtonDown
		|| e.type == UiEvent.Type_MButtonDown)
		{
			int mousex = round(double(e.MouseX) * 320 / screen.getWidth());
			int mousey = round(double(e.MouseY) * 200 / screen.getHeight());
			for(uint i = 0; i < widgets.size(); ++i)
			{
				if(mousex >= widgets[i].x && mousey >= widgets[i].y
				&& mousex <= widgets[i].x + widgets[i].w
				&& mousey <= widgets[i].y + widgets[i].h)
				{
					widgets[i].processUIInput(e);
				}
			}
		}
		else
		{
			for(uint i = 0; i < widgets.size(); ++i)
			{
				widgets[i].processUIInput(e);
			}
		}
		return false; // You're not bound to use the returned value from superclass version of the method
	}

	// Called from InputProcess() event,
	// processes generic input.
	ui virtual bool processInput(InputEvent e)
	{
		for(uint i = 0; i < widgets.size(); ++i)
		{
			widgets[i].processInput(e);
		}
		return false;
	}

	// Called from UiTick() event.
	ui virtual void uiTick()
	{
		for(uint i = 0; i < widgets.size(); ++i)
		{
			if(!widgets[i].ui_init){
				widgets[i].UIInit();
				widgets[i].ui_init = true;
			}
			widgets[i].uiTick();
		}
	}


	// ---------------
	// Other functions
	// --------------- 

	// Glorified way to add a widget to widgets list and call it's create() method.
	virtual void addWidget(UI_Widget widget)
	{
		widget.init();
		widgets.push(widget);
	}
}
