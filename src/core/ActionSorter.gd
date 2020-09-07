extends Node

static func sort(a, b):
	return a.name < b.name

static func sort_btns(a, b):
	print(a.action.name)
	return a.action.name < b.action.name
