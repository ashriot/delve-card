extends Node

static func sort_ascending(a, b):
	return a[0] < b[0]

static func sort(a, b):
	return a.name < b.name

static func sort_btns(a, b):
	return a.action.name < b.action.name
