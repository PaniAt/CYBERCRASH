extends CanvasLayer

func _ready() -> void:
	for weapon: Weapon in Player.weapon_inventory:
		$Main/Inventory.add_icon_item(weapon.texture, true)

func _on_inventory_item_selected(index: int) -> void:
	Player.queue_weapon(index)
	exit()

func exit() -> void:
	CameraController.free_mouse = false
	call_deferred("queue_free")
