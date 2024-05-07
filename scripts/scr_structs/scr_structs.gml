/// Constructors for my FNF port

// Character file structure
function fnf_char(_name, path = "funkin/characters/") constructor {
	// Read JSON file
	var _file = buffer_load($"{path}{_name}.json")
	var _json = buffer_read(_file, buffer_text)
	buffer_delete(_file)
	//show_debug_message($"{current_time/1000} - Loaded .json data for {_name}")
	name = _name
	
	json = json_parse(_json)
	
	xml = funkin_open_xml($"funkin/images/{json.image}.xml")
	//show_debug_message($"{current_time/1000} - Loaded .xml data for {_name}")
	
	img = sprite_add($"funkin/images/{json.image}.png", 1, 0, !json.no_antialiasing, 0, 0)
	//show_debug_message($"{current_time/1000} - Loaded {json.image}.png spritesheet")
	
	icon = sprite_add($"funkin/images/icons/icon-{json.healthicon}.png", 2, 0, !json.no_antialiasing, 75, 75)
	//show_debug_message($"{current_time/1000} - Loaded icon-{json.healthicon}.png icon")
	
	anim = "idle"
	anim_frame = 0
	
	if (!is_undefined(funkin_get_anim_data(self, "danceRight", 1))) { anim = "danceRight" }
	
	show_debug_message($"{current_time/1000} - Loaded character \"{_name}\"")
}

// Song and chart data
function fnf_song(song_name) constructor {
	// Read JSON chart
	var _file = buffer_load($"funkin/songs/{song_name}/{song_name}.json")
	var _json = buffer_read(_file, buffer_text)
	buffer_delete(_file)
	
	show_debug_message($"{current_time/1000} - Loaded .json chart data for {song_name}")
	
	chart = json_parse(_json).song
	
	
	// Track Paths
	inst = $"funkin/songs/{song_name}/Inst.ogg"
	
	voices = undefined
	if (chart.needsVoices) {
		voices = $"funkin/songs/{song_name}/Voices.ogg"
	}
	
	bf = chart.player1
	opponent = chart.player2
	
	gf = "gf"
	
	if (struct_exists(chart, "gfVersion")) {
		show_debug_message(chart.gfVersion)
		gf = chart.gfVersion
	}
}

// Pressable note
function fnf_note(vals, must_hit, _hold_type = 0, _key_count = 4) constructor {
	// Calculate if note is on opponent side
	opp_side = !(floor(vals[1] / _key_count) xor must_hit)
	
	// Inherited values
	pos = vals[0]
	lane = vals[1] % _key_count
	hold_length = vals[2]
	
	pressed = 0
	hold_pressed = 0
}

// Rating popup thingy
function fnf_rating(_rating, _judgements) constructor {
	anim_prog = 0
	
	subimg = 0
	
	x_spd = random_range(-1,1)
	
	var _pfc = (_judgements.sick == funkin_get_passed_notes(_judgements))
	
	if (_rating == "sick" and !_pfc) { subimg = 1 }
	else if (_rating == "good") { subimg = 2 }
	else if (_rating == "bad") { subimg = 3 }
	else if (_rating == "shit") { subimg = 4 }
	else if (_rating == "miss") { subimg = 5 }
}

// Stage data
function fnf_stage(stage_name) constructor {

}