# InventoryManager.gd
extends Node

signal item_cleaned(item: InvItem)
signal inventory_full()  # Add this signal

var player_inv: Inv = null
var is_initialized: bool = false

func set_player_inv(inv: Inv):
	player_inv = inv
	is_initialized = true
	print("InventoryManager: Player inventory set to ", inv)

func get_player_inv() -> Inv:
	return player_inv

func notify_item_cleaned(item: InvItem):
	item_cleaned.emit(item)

func notify_inventory_full():
	inventory_full.emit()
