# inventory.gd
extends Resource

class_name Inv

signal update

@export var slots: Array[InvSlot]

# inventory.gd
func insert(item: InvItem):
	# Check if item already exists in inventory (to prevent duplicates)
	for slot in slots:
		if slot.item == item:
			print("Item already in inventory: ", item.name)
			return false
	
	# Find empty slot
	for slot in slots:
		if slot.item == null:
			slot.item = item
			update.emit()
			return true
	
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
