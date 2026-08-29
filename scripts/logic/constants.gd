extends Node

var current_level: String

var talked_calim: bool = false
var talked_bryan: bool = false

signal open_map

const SCENE_PATHS: Dictionary = {
	"loading_screen": "uid://dks2u6hsx0uwt",
	"bahay": "uid://b4rcaktogxosx"
}

const PAGE_PATHS: Array[Dictionary] = [
	{
		"default": preload("uid://bv6a828qm82cr"),
		"solved": preload("uid://dr2xc5dfyan57")
	},
	{
		"default": preload("uid://b6hian7r3poy7"),
		"solved": preload("uid://bug2a31fkd7o5")
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
