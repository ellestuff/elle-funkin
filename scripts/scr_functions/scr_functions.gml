/// Functions for my FNF port

// Draws text with an outline
function draw_text_outline(_x, _y, _string, _c1 = #202e37, _c2 = #ebede9) {
	draw_set_color(_c2)
	for (var _i = 0; _i < 9; _i++) {
		draw_text(_x + (_i % 3) - 1, _y + (_i div 3) - 1, _string)
	}
	
	draw_set_color(_c1)
	draw_text(_x, _y, _string)
}

// Return file extension, returns an empty string if none found
function get_extension(_filename) {
	var _ext = ""
	
	var _split = string_split(_filename, ".")
	if (array_length(_split) > 1) {
		return array_last(_split)
	}
	
	return ""
}

// Make array of files from a directory, listing directories first
function get_files_in_dir(_path, _prefix = "funkin/") {
	var _files = []
	
	// Find directories first
	var _folder_name = file_find_first($"{_prefix}{_path}/*", fa_directory);
	
	while (_folder_name != "")
	{
		if (get_extension(_folder_name) == "") { array_push(_files, _folder_name) }
	    _folder_name = file_find_next()
	}
	file_find_close();
	
	// Find regular files
	var _file_name = file_find_first($"{_prefix}{_path}/*", fa_none);
	while (_file_name != "")
	{
	    array_push(_files, _file_name)
	    _file_name = file_find_next()
	}
	file_find_close();
	
	return _files
}

// Extract spritesheet data from Sparrow XML file
function funkin_open_xml(path) {
	var _data = {
		animations: {}
	}
	
	var _file = file_text_open_read(path)
	
	// Track whether the Texture Atlas has been recieved
	var _has_atlas = false
	
	while (!file_text_eof(_file)) {
		var _line = file_text_readln(_file)
		_line = string_trim_start(_line, ["<", "	"])
		_line = string_trim_end(_line, ["\n"])
		
		// Ignore comment lines
		if (string_starts_with(_line, "!--") and string_ends_with(_line, "-->")) { continue }
		
		// Get Texture Atlas
		if (string_starts_with(_line, "TextureAtlas") and !_has_atlas) {
			_has_atlas = true
			
			_line = string_trim_start(_line, ["TextureAtlas "])
			_line = string_trim_end(_line, [">"])
			
			var _test = string_split(_line, "=")
			_test[1] = string_trim(_test[1], ["\""])
			
			_data.image_path = $"{path}{_test[1]}"
		}
		
		// Get Animation stuff
		if (string_starts_with(_line, "SubTexture")) {
			_has_atlas = true
			
			_line = string_trim_start(_line, ["SubTexture "])
			_line = string_trim_end(_line, ["/>"])
			
			// Get values
			var _values = []
			var _sep_a = string_split(_line, "=")
			
			// Put all values in array
			for (var _i = 1; _i < array_length(_sep_a); _i++) {
				var _sep_b = string_split(_sep_a[_i], "\"", 1)
				
				if (_i == 1) {
					var _val = string_trim(_sep_b[0], [" "])
					_val = string_delete(_val, string_length(_val) - 3, 4)
					_val = string_replace_all(_val, " ", "_")
					
					array_push(_values, _val)
				}
				else { array_push(_values, _sep_b[0]) }
			}
			
			//	- Values -
			// name - the name of the animation + 4 digits saying with frame it is
			// x/y - position of the top-left of the sprite
			// width/height - dimensions of the sprite
			// frameX/Y - frame's position offset from starting frame
			// frameWidth/Height - i have no idea
			
			// Create Animation
			if (!variable_struct_exists(_data.animations, _values[0])) {
				variable_struct_set(_data.animations, _values[0], [])
			}
			
			// Fix missing extra data
			if (array_length(_values) == 5) {
				array_push(_values, 0) // frameX
				array_push(_values, 0) // frameY
			}
			
			// Frame Data
			var _frame = {
				x: _values[1],
				y: _values[2],
				
				width: _values[3],
				height: _values[4],
				
				frame_x: _values[5],
				frame_y: _values[6]
			}
			
			array_push(variable_struct_get(_data.animations, _values[0]), _frame)
		}
	}
	
	return _data
}

// Draw an FNF sprite using extracted Sparrow data
function funkin_draw_sprite(char, _x, _y, zoom = 0.25, flipped = false) {
	var _anim_json = undefined
	var _anim_name = undefined
	// Iterate through each json animation to find the matching one
	for (var _i = 0; _i < array_length(char.json.animations); _i++) {
		if (char.json.animations[_i].anim == char.anim) {
			_anim_json = char.json.animations[_i]
			_anim_name = string_replace_all(_anim_json.name, " ", "_")
			
			break
		}
	}
	if (is_undefined(_anim_json)) {
		show_debug_message($"Animation \"{char.anim}\" JSON not found.")
		draw_sprite(spr_ico_error, 0, _x, _y)
		exit
	}
	
	//show_debug_message(char.xml)
	var _anim_xml = undefined
	if (!is_undefined(_anim_name)) { _anim_xml = variable_struct_get(char.xml.animations, _anim_name) }
	
	
	
	
	
	
	//var _fps = game_get_speed(gamespeed_fps)/
	
	//zoom *= char.json.scale
	
	flipped = -(flipped xor char.json.flip_x) * 2 + 1
	
	var _frame = floor(clamp(char.anim_frame, 0, (array_length(_anim_xml)-1) * 2)/2)
	
	if (array_length(_anim_json.indices) > 0) {
		_frame = clamp(_anim_json.indices[clamp(char.anim_frame, 0, array_length(_anim_json.indices) - 1)], 0, (array_length(_anim_xml)-1))
	}
	
	_x -= (real(_anim_xml[_frame].frame_x) + real(_anim_json.offsets[0]) - real(char.json.position[0])) / real(1/zoom) * flipped
	_y -= (real(_anim_xml[_frame].frame_y) + real(_anim_json.offsets[1]) - real(char.json.position[1])) / real(1/zoom)
	
	gpu_set_tex_filter(!char.json.no_antialiasing)
	draw_sprite_part_ext(char.img, 0, _anim_xml[_frame].x, _anim_xml[_frame].y, _anim_xml[_frame].width, _anim_xml[_frame].height, _x, _y, zoom * flipped * char.json.scale, zoom * char.json.scale, c_white, 1)
	gpu_set_tex_filter(anti_aliased)
}

// Return Strum positions in an array of x y positions
function funkin_create_strums(spacing = 36, gap = 48, _y = 36, keys = 4) {
	var _strums = []
	
	for (var _i = -keys; _i < keys; _i++) {
		var _strum = {
			x: win_w / 2 + (_i + 0.5) * spacing + (sign(_i + 0.5) * gap),
			y: _y
		}
		
		array_push(_strums, _strum)
	}
	
	return _strums
}

// Get how many notes have been pressed or missed so far
function funkin_get_passed_notes(vals = judgements) {
	return vals.sick + vals.good + vals.bad + vals.shit + vals.miss
}

// Get raw accuracy percentage
function funkin_get_accuracy(vals = judgements) {
	var _passed_notes = funkin_get_passed_notes(vals)
	return (vals.sick + (vals.good * 0.67) + (vals.bad * 0.34) + (vals.shit * 0.34)) / _passed_notes
}

// Get the accuracy for the song as a string
function funkin_get_rating_str(vals = judgements) {
	var _passed_notes = funkin_get_passed_notes(vals)
	
	// Return "?" if no notes have been played
	if (_passed_notes == 0) { return "?" }
	
	// Calculate accuracy percentage
	var _acc = funkin_get_accuracy(vals)
	var _acc_formatted = string_trim(string_format(_acc * 100, 3, 1), [" "])
	
	// Get Rating Text
	var _rating = "You Suck!"
	if (_acc == 1) { _rating = "Perfect!!" }
	else if (_acc >= 0.9) { _rating = "Sick!" }
	else if (_acc >= 0.8) { _rating = "Great" }
	else if (_acc >= 0.7) { _rating = "Good" }
	else if (trunc(_acc, 2) == 0.69) { _rating = "Nice" }
	else if (_acc >= 0.6) { _rating = "Meh" }
	else if (_acc >= 0.5) { _rating = "Bruh" }
	else if (_acc >= 0.4) { _rating = "Bad" }
	else if (_acc >= 0.2) { _rating = "Shit" }
	
	// Get FC status
	var _fc = ""
	if (vals.miss == 0) {
		if (_acc == 1) { _fc = "PFC" }
		else if (vals.bad == 0 and vals.shit == 0) { _fc = "GFC" }
		else { _fc = "FC" }
	}
	else if (vals.miss < 10) { _fc = "SDCB" }
	
	// Create string
	var _str = $"{_rating} ({_acc_formatted}%)"
	if (_fc != "") { _str = $"{_str} - {_fc}" }
	
	return _str
}

// Add notes from a section to notes array
function funkin_create_section_notes(_song, _section) {
	if (_section > array_length(_song.chart.notes) - 1) { exit }
	var _sect = _song.chart.notes[_section]
	var _sect_notes = _sect.sectionNotes
	
	array_sort(_sect_notes, function(a, b) {
		return a[0] - b[0]
	})
	
	for (var _i = 0; _i < array_length(_sect_notes); _i++) {
		if (array_length(_sect_notes[_i]) != 3) { continue }
		var _note = new fnf_note(_sect_notes[_i], _sect.mustHitSection, 0)
		
		array_push(notes, _note)
	}
}

// Start playing an FNF' song
function play_song(_song) {
	playing_song = true
	
	song = variable_clone(struct_get(songs, _song))
	
	show_debug_message(struct_get(chars, song.gf))
	
	gf = variable_clone(struct_get(chars, song.gf))
	
	bf = variable_clone(struct_get(chars, song.bf))
	dad = variable_clone(struct_get(chars, song.opponent))
	
	funkin_song_defaults()
	
	// Setup audio streams
	inst_stream = audio_create_stream(song.inst)
	inst = audio_play_sound(inst_stream, 0, 0)
	
	if (song.chart.needsVoices) {
		voices_stream = audio_create_stream(song.voices)
		voices = audio_play_sound(voices_stream, 0, 0)
	}
	
	// Add notes from first few sections
	funkin_create_section_notes(song, section)
	funkin_create_section_notes(song, section + 1)
	funkin_create_section_notes(song, section + 2)
	
	win_name = $"Friday Night Funkin' - {song.chart.song}"
	win_name_short = song.chart.song
	
	song_len = audio_sound_length(inst)
	show_debug_message(song_len)
}

// End the current FNF' song
function end_song() {
	if (!playing_song) { exit }
	
	playing_song = false
	delete song
	
	
	if (!is_undefined(inst_stream)) { audio_destroy_stream(inst_stream) }
	if (!is_undefined(voices_stream)) { audio_destroy_stream(voices_stream) }
	
	pause_game(false)
	
	win_name = "Friday Night Funkin'"
	win_name_short = "FNF"
}

// Set default instance variables
function funkin_song_defaults() {
	notes = []
	
	note_last = 0
	
	rating_popups = []
	
	song_pos = 0
	
	inputs = [0, 0, 0, 0]
	opp_strum_timers = [0, 0, 0, 0]
	
	judgements = {
		sick: 0,
		good: 0,
		bad: 0,
		shit: 0,
		miss: 0
	}
	
	hp = 50
	scr = 0
	acc = funkin_get_rating_str()
	
	inst_stream = undefined
	inst = undefined
	
	voices_stream = undefined
	voices = undefined
	
	strums = funkin_create_strums()
	
	section = 0
	bop_section = 0
	icon_bop = 0
	
	step_real = 0
	
	song_len = 0
}

// Press a note in a lane
function funkin_press_note(lane, press) {
	for (var _i = 0; _i < array_length(notes); _i++) {
		var _note = notes[_i]
		
		if (_note.lane != lane or _note.opp_side or (_note.pressed == 1 and !_note.hold_pressed)) { continue }
		
		var _distance = abs(_note.pos - song_pos)
		
		// Normal note stuff
		if (press == 2) {
			var _rating = ""
			if (_distance <= 45) { _rating = "sick" }
			else if (_distance <= 90) { _rating = "good" }
			else if (_distance <= 135) { _rating = "bad" }
			else if (_distance <= 180) { _rating = "shit" }
			
			if (_rating != "") {
				_note.pressed = 1
				_note.hold_pressed = 1
				
				if (_rating == "shit") { _note.pressed = 2 }
				
				audio_sound_gain(voices_stream, 1, 0)
				
				funkin_play_anim(bf, note_anims[lane])
				
				hp += 2
				
				array_push(rating_popups, new fnf_rating(_rating, judgements))
				
				struct_set(judgements, _rating, struct_get(judgements, _rating) + 1)
				
				acc = funkin_get_rating_str()
				
				break
			}
		}
		
		// Hold note stuff
		else if (press == 3 and _note.hold_pressed) {
			_note.hold_pressed = 0
			break
		}
	}
}

// Get array of song folder names and song structs (causes game freeze from loading data, need to make async later and add loading screen)
function funkin_get_data() {
	// Characters
	show_debug_message($"{current_time/1000} - Started Fetching Characters\n")
	char_list = get_files_in_dir("characters")
	for (var _i = 0; _i < array_length(char_list); _i++) {
		char_list[_i] = string_split(char_list[_i], ".")[0]
	}
	
	chars = {}
	
	for (var _i = 0; _i < array_length(char_list); _i++) {
		show_debug_message($"{current_time/1000} - Fetching Character #{_i+1}")
		struct_set(chars, char_list[_i], new fnf_char(char_list[_i]))
	}
	
	show_debug_message($"{current_time/1000} - Finished Fetching Characters\n")
	
	// Songs
	show_debug_message($"{current_time/1000} - Started Fetching Songs\n")
	song_list = get_files_in_dir("songs")
	songs = {}
	
	for (var _i = 0; _i < array_length(song_list); _i++) {
		show_debug_message($"{current_time/1000} - Fetching Song #{_i+1}")
		struct_set(songs, song_list[_i], new fnf_song(song_list[_i]))
	}
	
	show_debug_message($"{current_time/1000} - Finished Fetching Songs\n")
}

// Make a character play an animation
function funkin_play_anim(char, anim, frame = 0) {
	char.anim = anim
	char.anim_frame = frame
}

// Get the length of an animation in frames
function funkin_get_anim_length(char, anim = char.anim) {
	// 1. Take psych animation name and trace it back to the xml animation
	// 2. Format the xml animation name and search for it in there
	// 3. Return the array's length
	
	/*var _name_raw = ""
	for (var _i = 0; _i < array_length(char.json.animations); _i++) {
		if (char.json.animations[_i].anim == anim) {
			_name_raw = string_replace_all(char.json.animations[_i].name, " ", "_")
		}
	}*/
	var _name_raw = string_replace_all(funkin_get_anim_data(char, anim).name, " ", "_")
	
	if (_name_raw == "") {
		show_debug_message($"Could not recieve length of animation \"{anim}\", returning 0.")
		return 0
	} else {
		return array_length(variable_struct_get(char.xml.animations, _name_raw))
	}
}

// Get the array index of an animation
function funkin_get_anim_data(char, anim = char.anim, hide_debug = false) {
	for (var _i = 0; _i < array_length(char.json.animations); _i++) {
		if (char.json.animations[_i].anim == anim) {
			return char.json.animations[_i]
		}
	}
	if (!hide_debug) { show_debug_message($"Could not find animation \"{anim}\"") }
	return undefined
}