class UI_DDSmallButton_UpgradeSkill : UI_DDSmallButton
{
	UI_Skills parent_wnd; // parent window

	override void processUIInput(UiEvent e)
	{
		if(pressed && e.type == UiEvent.Type_LButtonUp)
		{
			PlayerInfo plr = players[consoleplayer];
			EventHandler.sendNetworkEvent("dd_upgrade_skill", parent_wnd.selected_skill);
		}
		super.processUIInput(e);
	}

	override void uiTick()
	{
		if(!self)
			return;

		PlayerInfo plr = players[consoleplayer];
		if(plr.mo){
			if(!DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.getSkill(parent_wnd.selected_skill) || DD_EventHandler(StaticEventHandler.Find("DD_EventHandler")).skill_utils.canUpgradeSkill(plr.mo, parent_wnd.selected_skill)){
				disabled = false;
				text_color = 0xFFFFFF;
				text = "Upgrade";
			}
			else{
				disabled = true;
				text_color = 0x888888;
			}
		}
	}
}
