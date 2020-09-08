extends Node

static func sort_ascending(a, b):
	return a[0] < b[0]

static func sort_vectors(a, b):
	return abs(a[1].x) + abs(a[1].y) < abs(b[1].x) + abs(b[1].y)

static func sort(a, b):
	return a.name < b.name

static func sort_btns(a, b):
	return a.action.name < b.action.name
