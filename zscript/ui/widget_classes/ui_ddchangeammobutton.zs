class UI_DDChangeAmmoButton : UI_DDSmallButton
{
	UI_DDInventoryDisplay invdisp;

	override void processUIInput(UiEvent e)
	{
		PlayerInfo plr = players[consoleplayer];
		let ddih = DD_InventoryHolder(plr.mo.FindInventory("DD_InventoryHolder"));
		super.processUIInput(e);
		if(e.type == UiEvent.Type_LButtonDown && invdisp.selected_item){
			EventHandler.SendNetworkEvent("dd_inventory_change_ammo", ddih.items.find(invdisp.selected_item));
		}
	}
}
