extends Node

var has_learned_about: Dictionary = {
	"Coughing_Fits": false,
	"Cafe_Date": false,
	"Felicia_Morning": false,
	"Homecooking": false,
	"Drew_Relationship": false,
	"Drew_Date": false,
	"Night_Call": false,
	"Gary_Interview": false,
	"Parent_Colleague": false,
	"Child_Colleague": false,
	"Sindikato_Ties": false,
	"No_Sindikato_Ties": false,
	"Mafia_Colleague": false,
	"Fake_Documents": false,
	"Not_Roped_In": false,
}

var has_found: Dictionary = {
	"Vault_Documents": true,
	"Planted_Documents": false,
	"Journal": false,
}

var has_met: Dictionary = {
	"Felicia": false,
	"Arthur": false,
	"Gary": false,
	"Francesca": false,
	"Remi": false,
}

var culprit: String = ""
