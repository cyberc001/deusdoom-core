class UI_DDUseButton : UI_DDSmallButton
{
	UI_DDInventoryDisplay invdisp;

	override void processUIInput(UiEvent e)
	{
		PlayerInfo plr = players[consoleplayer];
		let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
		super.processUIInput(e);
		if(e.type == UiEvent.Type_LButtonDown && invdisp.selected_item){
			EventHandler.SendNetworkEvent("dd_inventory_use_item", ddih.items.find(invdisp.selected_item), 0);
		}
	}
}
