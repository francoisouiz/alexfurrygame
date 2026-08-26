extends Node

const SCENE_PATHS: Dictionary = {
	"loading_screen": "uid://dks2u6hsx0uwt"
}

const PAGE_PATHS: Array[Dictionary] = [
	{
		"default": preload("uid://dr2xc5dfyan57"),
		"solved": preload("uid://bcxdi16pxrlme")
	},
	{
		"default": preload("uid://b6hian7r3poy7"),
		"solved": preload("uid://53o6mc8y0pby")
	},
	{
		"default": preload("uid://debf1s6jtimho"),
		"solved": preload("uid://debf1s6jtimho")
	}
]

const SECTION_PAGES: Dictionary = {
	"tab_1": 0,
	"tab_2": 2
}
