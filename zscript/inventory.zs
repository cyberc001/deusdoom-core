// Inherit from this so game can recognize this as a DeusDoom item
class DDItem : Inventory
{
	default
	{
		Inventory.PickupSound "DDItem/item_pickup";
		DDItem.DropSound "DDItem/item_drop";
		DDItem.StayInInventory true;
	}

	override void BeginPlay()
	{
		super.BeginPlay();
		lastvel = vel;
		SetDropRotation();
	}

	override void Tick()
	{
		super.Tick();
		CheckDropSound();
		CheckDropRotation();
	}

	/* Drop sound */
	string drop_sound;
	property DropSound : drop_sound;

	vector3 lastvel;
	void CheckDropSound()
	{
		if(lastvel.length() > 0 && vel.length() == 0)
			A_StartSound(drop_sound);
		 lastvel = vel;
	}

	/* Drop rotation */
	double desired_angle, spin_per_tick;
	const spin_time = 8;
	void SetDropRotation()
	{
		spriteRotation = frandom(-180, 180);
		desired_angle = spriteRotation + frandom(90, 180) * (random(0, 1) ?1 : -1);
		spin_per_tick = (desired_angle - spriteRotation) / spin_time;
	}
	void CheckDropRotation()
	{
		if(spriteRotation != desired_angle)
			spriteRotation += spin_per_tick;
		if(vel.length() == 0)
			desired_angle = spriteRotation;
	}

	/* Applying items to another (weapon upgrades) */
	virtual clearscope bool isApplicable(Inventory another)
	{
		return false;
	}
	virtual void applyTo(Inventory another){}

	/* Ammo stuff */
	bool stay_in_inventory;
	property StayInInventory : stay_in_inventory;

	bool do_use_func; // Call Use(bool) instead of just giving the player the item
	property DoUseFunc : do_use_func;
}

class DD_InventoryWrapper
{
	Inventory item;
	name item_cls; // optional, used by item descriptors

	double icon_x, icon_y;
	double icon_mulh;

	int x, y;
	int w, h;

	int amount; int max_stack;

	string base_desc; // set once on register/create and never modified. Intended for DDWeapon
	string desc; // item description
}

class DD_InventoryPickupWrapper : Inventory
{
	Inventory item;

	default
	{
		+DONTGIB;
		+THRUACTORS;
	}

	void init(Inventory _item)
	{
		item = _item;
		item.bTHRUACTORS = true;
	}

	override void Tick()
	{
		if(!item || item.owner) { destroy(); return; }
		if(item && item.vel.length() > 0)
			Warp(item);
	}

	override bool Used(Actor user)
	{
		let ddih = DD_InventoryHolder(user.FindInventory("DD_InventoryHolder"));
		if(item.Amount == 0){
			item.TryPickUp(user);
			item.destroy();
			destroy();
			return true;
		}
		if(ddih && item){
			if(item is "Ammo" || (item is "DDItem" && !DDItem(item).stay_in_inventory)){
				if(user.GiveInventory(item.GetClass(), item.Amount)){
					user.A_StartSound("DDItem/item_pickup", CHANF_LOCAL);
					item.destroy();
					destroy();
					return true;
				}
			}
			else if(ddih.addItem(item)){
				user.A_StartSound(item.PickupSound, CHANF_LOCAL);
				item.warp(owner);
				item.A_ChangeLinkFlags(1, 1);
				name dts = "DDWeapon_DragonsToothSword";
				if(item is dts)
					item.TryPickup(user); 
				destroy();
				return true;
			}
		}
		return false;
	}

	override bool canPickup(Actor toucher) { return false; }
}

class DD_InventoryPickupTracer : LineTracer
{
	Actor source;
	DD_InventoryPickupWrapper hit_obj;
	Actor hit_actor;

	override ETraceStatus traceCallback()
	{
		Name cls_proj = "DDProjectile";
		if(results.hitType == TRACE_HitActor)
		{
			if(results.hitActor && results.hitActor == source)
				return TRACE_Skip;
			else if(results.hitActor && results.hitActor is "DD_InventoryPickupWrapper")
			{ hit_obj = DD_InventoryPickupWrapper(results.hitActor); return TRACE_Stop; }
			else if(results.hitActor && cls_proj && results.hitActor is cls_proj && !results.hitActor.bNOBLOCKMAP)
			{ hit_actor = results.hitActor; return TRACE_Stop; }
			else if(results.hitActor && results.hitActor.bSHOOTABLE && results.hitActor.bSOLID)
			{ hit_actor = results.hitActor; return TRACE_Stop; }
		} else if(results.hitType == TRACE_HitWall && results.tier == TIER_Middle && results.hitLine.flags & Line.ML_TWOSIDED > 0)
			return TRACE_Skip;
		else if(results.hitType == TRACE_HitWall || results.hitType == TRACE_HitFloor || results.hitType == TRACE_HitCeiling)
			return TRACE_Stop;
		return TRACE_Skip;
	}
}

class DD_InventoryUseWeapon : Weapon
{
	DD_InventoryWrapper item;
	default
	{
		+WEAPON.NOALERT;
		+WEAPON.NOAUTOFIRE;
	}

	states
	{
		Ready:
			TNT1 A 1 A_WeaponReady();
			Loop;
		Deselect:
			TNT1 A 0 takeInventory("DD_InventoryUseWeapon", 1);
			Stop;
		Select:
			Goto Ready;
		Fire:
			TNT1 A 0{
				let ddih = DD_InventoryHolder(findInventory("DD_InventoryHolder"));
				if(ddih.useItem(invoker.item))
					return ResolveState("Ready");
				return ResolveState(null);
			}
			TNT1 A 0 takeInventory("DD_InventoryUseWeapon", 1);
			Stop;
	}
}

class DD_InventoryHolder : Inventory
{
	default
	{
		Inventory.InterHubAmount 1;
		+DONTGIB;
		+THRUACTORS;
	}

	const inv_w = 5; const inv_h = 6;
	array<DD_InventoryWrapper> items;

	bool checkItemSpace(DD_InventoryWrapper wrap)
	{
		if(wrap.x + (wrap.w - 1) >= inv_w || wrap.y + (wrap.h - 1) >= inv_h || wrap.x < 0 || wrap.y < 0)
			return false;
		for(uint i = 0; i < items.size(); ++i)
			if(items[i] != wrap
			&& wrap.x + (wrap.w - 1) >= items[i].x && wrap.x <= items[i].x + (items[i].w - 1)
			&& wrap.y + (wrap.h - 1) >= items[i].y && wrap.y <= items[i].y + (items[i].h - 1))
				return false;
		return true;
	}
	DD_InventoryWrapper getAnyItemInRect(int x, int y, int w, int h)
	{
		for(uint i = 0; i < items.size(); ++i)
			if(items[i].x + (items[i].w - 1) >= x && items[i].x <= x + (w - 1)
			&& items[i].y + (items[i].h - 1) >= y && items[i].y <= y + (w - 1))
				return items[i];
		return null;
	}

	bool addItem(Inventory item)
	{
		let wrap = makeWrapperFromDescriptor(item);
		wrap.amount = item.amount;

		bool has_duplicates = false;
		// Stack with the same item type
		for(uint i = 0; i < items.size(); ++i)
			if(items[i].item && item.getClass() == items[i].item.getClass()){
				has_duplicates = true;
				if(items[i].amount < items[i].max_stack){
					items[i].amount = min(items[i].amount + wrap.amount, items[i].max_stack);
					return true;
				}
			}
		// Insert a new item
		if(!has_duplicates){
			for(int y = 0; y < inv_h; ++y)
				for(int x = 0; x < inv_w; ++x){
					wrap.x = x; wrap.y = y;
					if(checkItemSpace(wrap)){
						items.push(wrap);
						item.AttachToOwner(owner);
						// make a hotbar bind
						int prevslot = findHotbarSlot(wrap);
						if(prevslot == -1){
							for(uint i = 0; i < hotbar_size; ++i)
								if(!hotbar[i]){
									setHotbarSlot(i, wrap);
									break;
								}
						}
						return true;
					}
				}
		} else if(item is "Weapon" && Weapon(item).AmmoType1){
			Inventory _ammo = Inventory(Actor.Spawn(Weapon(item).AmmoType1));
			owner.GiveInventory(Weapon(item).AmmoType1, ceil(_ammo.Amount / 3.));
			_ammo.destroy();
			return true;
		}
		return false;
	}

	bool moveItem(DD_InventoryWrapper item, int x, int y)
	{ // swaps with another item if there isn't enough space
		int item_x = item.x, item_y = item.y;
		uint ind = items.find(item);

		// remove the item
		items.delete(ind);

		// check space, swap if necessary
		item.x = x; item.y = y;
		if(!checkItemSpace(item)){
			DD_InventoryWrapper wrap;
			array<DD_InventoryWrapper> looked;
			array<int> looked_x; array<int> looked_y;
			while(wrap = getAnyItemInRect(item.x, item.y, item.w, item.h)){
				uint look_i = looked.find(wrap);
				if(look_i != looked.size()){
					looked[look_i].x = looked_x[look_i];
					looked[look_i].y = looked_y[look_i];
					items.push(item);
					item.x = item_x; item.y = item_y;
					return false;
				}
				looked.push(wrap); looked_x.push(wrap.x); looked_y.push(wrap.y);
				if(!placeItem(wrap, item_x, item_y)){
					items.push(item);
					item.x = item_x; item.y = item_y;
					return false;
				}
			}
		}
		if(checkItemSpace(item)){ // the cause was item being out of inventory bounds
			items.push(item);
			return true;
		}
		item.x = item_x; item.y = item_y;
		items.push(item);
		return false;
	}
	bool placeItem(DD_InventoryWrapper item, int x, int y)
	{ // moves item to the right/bottom if there isn't enough space
		int item_x = item.x, item_y = item.y;
		for(item.y = y; item.y < inv_h - (item.h - 1); ++item.y){
			for(item.x = x; item.x < inv_w - (item.w - 1); ++item.x)
				if(checkItemSpace(item))
					return true;
			x = 0;
		}
		item.x = item_x; item.y = item_y;
		return false;
	}

	bool useItem(DD_InventoryWrapper item, DD_InventoryWrapper another = null)
	{
		bool used = false;
		if(item.item is "DDItem" && DDItem(item.item).do_use_func)
			used = item.item.Use(false);
		else{				
			if(!another){
				used = item.item.use(false);
				if(!used) { used = item.item.use(true); if(used) ++item.item.amount; }
				if(!used && item.item is "Health") used = owner.GiveBody(item.item.amount, item.item.maxamount);
				if(!used && !(item.item is "Health")){
					let i = Inventory(Inventory.Spawn(item.item.getClass()));
					used = i.tryPickup(item.item.owner);
					if(!used) i.destroy();
				}
			}
			else if(item.item is "DDItem"){
				DDItem(item.item).applyTo(another.item);
				used = true;
			}
		}
		bool got_destroyed = false;
		if(used){
			--item.amount;
			if(!item.amount){
				items.delete(items.find(item));
				got_destroyed = true;
			}
		}
		return used && !got_destroyed;
	}

	void removeItem(DD_InventoryWrapper item, int amt = -1)
	{
		items.delete(items.find(item));
		item.item.owner.takeInventory(item.item.getClassName(), amt == -1 ? item.amount : amt);
		int prevslot = findHotbarSlot(item);
		if(prevslot != -1)
			hotbar[prevslot] = null;
	}

	void dropItem(DD_InventoryWrapper item, uint amt = 1)
	{
		Actor _owner = item.item.owner;
		if(amt > item.amount)
			amt = item.amount;
		for(uint i = 0; i < amt; ++i){
			++item.item.amount;
			let drop = item.item.createTossable(1);
			if(drop){
				drop.warp(_owner, 50 + frandom(-5, 10), frandom(-10, 10), _owner.player ? _owner.player.viewHeight : _owner.height / 1.5);
				--item.amount;
				if(!item.amount){
					int prevslot = findHotbarSlot(item);
					if(prevslot != -1)
						hotbar[prevslot] = null;
					_owner.takeInventory(item.item.getClass(), 999999);
					uint ind = items.find(item);
					items.delete(ind);
					break;
				}
			}
			else{
				--item.item.amount ;
				drop = Inventory(Inventory.Spawn(item.item.getClass()));
				drop.warp(_owner, 50 + frandom(-5, 10), frandom(-10, 10), _owner.player ? _owner.player.viewHeight : _owner.height / 1.5);
				--item.amount;
				if(item.amount < 0) item.amount = 0;
				if(!item.amount){
					int prevslot = findHotbarSlot(item);
					if(prevslot != -1)
						hotbar[prevslot] = null;
					_owner.takeInventory(item.item.getClass(), 999999);
					uint ind = items.find(item);
					items.delete(ind);
					break;
				}
			}
		}
	}

	void equipItem(DD_InventoryWrapper item)
	{ // either switches to the weapon or brings up a fake weapon that uses the item on primary fire
		if(item.item is "Weapon"){
			item.item.owner.UseInventory(item.item);
		}
		else{
			item.item.owner.giveInventory("DD_InventoryUseWeapon", 1);
			let usewep = DD_InventoryUseWeapon(item.item.owner.findInventory("DD_InventoryUseWeapon"));
			usewep.item = item;
			item.item.owner.player.pendingWeapon = usewep;
			PlayerPawn(item.item.owner).BringUpWeapon();
		}
	}

	/* Inventory descriptors */

	static void addItemDescriptor(name item_cls, int item_w = 1, int item_h = 1, int max_stack = 8, double icon_x = 0, double icon_y = 0, double icon_mulh = 1, string description = " ")
	{
		let ddeh = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler"));
		let desc = DD_InventoryWrapper(new("DD_InventoryWrapper"));
		desc.item_cls = item_cls;
		desc.w = item_w; desc.h = item_h;
		desc.max_stack = max_stack;
		desc.icon_x = icon_x; desc.icon_y = icon_y;
		desc.icon_mulh = icon_mulh;
		desc.base_desc = desc.desc = description;
		ddeh.inv_descs.push(desc);
	}
	static DD_InventoryWrapper makeWrapperFromDescriptor(Inventory item)
	{
		let ddeh = DD_EventHandler(StaticEventHandler.Find("DD_EventHandler"));
		let desc = DD_InventoryWrapper(new("DD_InventoryWrapper"));
		desc.item = item;
		desc.x = 0; desc.y = 0;
		desc.amount = 1;
		for(uint i = 0; i < ddeh.inv_descs.size(); ++i)
			if(item is ddeh.inv_descs[i].item_cls){
				desc.icon_x = ddeh.inv_descs[i].icon_x;
				desc.icon_y = ddeh.inv_descs[i].icon_y;
				desc.icon_mulh = ddeh.inv_descs[i].icon_mulh;
				desc.w = ddeh.inv_descs[i].w;
				desc.h = ddeh.inv_descs[i].h;
				desc.max_stack = ddeh.inv_descs[i].max_stack;
				desc.base_desc = desc.desc = ddeh.inv_descs[i].desc;
				return desc;
			}
		desc.icon_x = desc.icon_y = 0;
		desc.icon_mulh = 1;
		desc.max_stack = 1;
		desc.w = desc.h = 1;
		desc.base_desc = desc.desc = " ";
		return desc;
	}

	/* Hotbar (belt) */
	const hotbar_size = 10;
	DD_InventoryWrapper hotbar[hotbar_size];

	void setHotbarSlot(uint slot, DD_InventoryWrapper wrap)
	{
		if(!(wrap.item is "Weapon"))
			return;
		int prevslot = findHotbarSlot(wrap);
		if(prevslot != -1)
			hotbar[prevslot] = null;
		hotbar[slot] = wrap;
	}
	clearscope int findHotbarSlot(DD_InventoryWrapper wrap)
	{
		for(uint i = 0; i < hotbar_size; ++i)
			if(hotbar[i] == wrap)
				return i;
		return -1;
	}

	/* Hotbar slide up/down animations and visibility */
	int hotbar_timer;
	int hotbar_show_time;
	int hotbar_stay_time;
	int hotbar_hide_time;
	int hotbar_total_time;
	bool hotbar_always_stay;
	bool hotbar_init;

	override void BeginPlay()
	{
		hotbar_timer = hotbar_total_time;
	}
	override void Tick()
	{
		if(!hotbar_init && owner)
			updateHotbarCVars();

		if(level.MapName == "TITLEMAP")
			hotbar_timer = 0;
		else if(hotbar_always_stay)
			hotbar_timer = hotbar_show_time;
		else if(hotbar_timer < hotbar_total_time)
			++hotbar_timer;
		// dirty, but I haven't found the cause yet
		for(int i = 0; i < items.size(); ++i)
			if(!items[i].item){
				items.delete(i);
				--i;
			}
	}

	protected void updateHotbarCVars()
	{
		int prev_total_time = hotbar_total_time;
		hotbar_show_time = CVar.GetCVar("dd_hotbar_show_time", owner.player).GetInt();
		hotbar_stay_time = CVar.GetCVar("dd_hotbar_stay_time", owner.player).GetInt();
		hotbar_hide_time = CVar.GetCVar("dd_hotbar_hide_time", owner.player).GetInt();
		hotbar_total_time = hotbar_show_time + hotbar_stay_time + hotbar_hide_time;
		if(prev_total_time != hotbar_total_time)
			hotbar_timer = hotbar_total_time;
		hotbar_always_stay = CVar.getCVar("dd_hotbar_always_stay", owner.player).GetBool();
	}

	void showHotbar()
	{
		updateHotbarCVars();
		if(hotbar_timer >= hotbar_total_time)
			hotbar_timer = 0;
		else
			hotbar_timer = hotbar_show_time;
	}
}
