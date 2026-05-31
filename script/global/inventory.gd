class_name Inventory
extends Node

##key = item type, value = number of item
var items = {}

## Item key is added if needed, and count for item is incremented by one.
func add_item(item):
	if !items.has(item):
		items[item] = 0
	items[item] += 1

## Removes one instance of item from inventory. If item count becomes 0, item key is removed.
func remove_item(item):
	if !items.has(item):
		return
	items[item] -= 1
	if items[item] == 0:
		items.erase(item)
