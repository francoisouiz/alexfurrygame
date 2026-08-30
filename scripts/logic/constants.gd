extends Node

var current_level: String

var has_opened_journal: bool = false
var first_time_filled: bool = true
var first_filled_checker: bool = false
var in_dialogue: bool = false
var first_time_playing: bool = true
var body_inter: bool = false
var table_inter: bool = false
var photo_inter: bool = false
var calendar_inter: bool = false
var interacted_everything: bool = false
var first_office_end: bool = false
var arthur_end: bool = false
var has_found_birthdays: bool = false
var can_question_felicia: bool = false

signal open_map
signal journal_prompt
signal first_time_signal
signal file_case
signal go_lucius_room
signal go_benjamin_office
signal go_benjamin_house
signal go_remi

const SCENE_PATHS: Dictionary = {
	"loading_screen": "uid://dks2u6hsx0uwt",
	"bahay": "uid://b4rcaktogxosx",
	"lucius_room": "uid://u4127d6kfxpi",
	"dialogue_testing": "uid://bajvpq71v7u04",
	"office": "uid://dco63yvk80o1f"
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
		"solved": preload("uid://2scoswsi4hmb")
	},
	{
		"default": preload("uid://6po6dqwddc4a"),
		"solved": preload("uid://007pke7yh81t")
	},
	{
		"default": preload("uid://b46mnc3246bew"),
		"solved": preload("uid://blsn1es3tp7kf")
	},
	{
		"default": preload("uid://b8wjxi7c4lb14"),
		"solved": preload("uid://cacfbnn5ynpfx")
	},
	{
		"default": preload("uid://cxfoo7fj3dflv"),
		"solved": preload("uid://caooyi17bj55y")
	},
	{
		"default": preload("uid://p2avyshl0jal"),
		"solved": preload("uid://75csbte781yx")
	},
	{
		"default": preload("uid://cdftv20nri8vs"),
		"solved": preload("uid://bovsvg3nfdxhe")
	},
]

const SECTION_PAGES: Dictionary = {
	"tab_1": 0,
	"tab_2": 2
}
