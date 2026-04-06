# inventory.gd
extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	# First, try to find an empty slot
	for slot in slots:
		if slot.item == null:
			slot.item = item
			update.emit()
			return true
	
	# No empty slots found
	print("Inventory is full! Cannot add: ", item.name)
	return false

func remove(item: InvItem):
	for slot in slots:
		if slot.item == item:
			slot.item = null
			update.emit()
			return true
	return false

func is_full() -> bool:
	for slot in slots:
		if slot.item == null:
			return false
	return true

func get_empty_slot_count() -> int:
	var count = 0
	for slot in slots:
		if slot.item == null:
			count += 1
	return count
