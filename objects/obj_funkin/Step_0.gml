if (!playing_song) {
	if (keyboard_check_pressed(vk_space)) { play_song(song_list[selected_song])	}
	
	if (keyboard_check_pressed(vk_up)) { selected_song-- }
	if (keyboard_check_pressed(vk_down)) { selected_song++ }
	selected_song = clamp(selected_song, 0, array_length(song_list)-1)
	
	exit
}





if (keyboard_check_pressed(vk_enter)) { pause_game(!game_paused) }
if (game_paused) {
	if (keyboard_check_pressed(vk_backspace)) { end_song() }
	
	if (keyboard_check_pressed(ord("R"))) { end_song(); play_song(selected_song); }
	
	exit
}

if (!is_undefined(funkin_get_anim_data(bf))) { bf.anim_frame += funkin_get_anim_data(bf).fps / global.framerate * 2 }
if (!is_undefined(funkin_get_anim_data(dad))) { dad.anim_frame += funkin_get_anim_data(dad).fps / global.framerate * 2 }
if (!is_undefined(funkin_get_anim_data(gf))) { gf.anim_frame += funkin_get_anim_data(gf).fps / global.framerate * 2 }

if (icon_bop > 0) { icon_bop-- }

song_pos = audio_sound_get_track_position(inst) * 1000

step_real = song_pos / 15000 * song.chart.bpm
//show_debug_message(_step_real)

// Calculate section and check if section just changed
var _section_change = section
section = floor(step_real div 16)
_section_change = (_section_change != section)

// Calculate bop section and check if bop section just changed
// The bop section is used for the idle bopping
var _idle_bop = bop_section
bop_section = floor(step_real)
_idle_bop = (_idle_bop != bop_section)

// Detect song end
if (_section_change > section and section == 0) { end_song(); exit }


// Input detection
for (var _i = 0; _i < array_length(inputs); _i++) {
	inputs[_i] = 0
	
	if (keyboard_check_pressed(ord(input_binds[_i]))) { inputs[_i] = 2; note_last = _i }
	else if (keyboard_check_released(ord(input_binds[_i]))) { inputs[_i] = 3 }
	else if (keyboard_check(ord(input_binds[_i]))) { inputs[_i] = 1 }
	
	funkin_press_note(_i, inputs[_i])
}

//if (bf.anim_frame > array_length(struct bf.xml.animations) - 1) { funkin_play_anim(bf, "idle") }
//if (dad.anim_frame > array_length(dad.xml.animations) - 1) { funkin_play_anim(dad, "idle") }


if (bf.anim_frame >= bf.json.sing_duration * 4 and bf.anim != "idle" and (inputs[note_last] == 0 or inputs[note_last] == 3)) { funkin_play_anim(bf, "idle") }
if (dad.anim_frame >= dad.json.sing_duration * 4 and dad.anim != "idle") { funkin_play_anim(dad, "idle") }

if (_idle_bop) {
	if (floor(step_real) % 8 == 0) {
		if (bf.anim == "idle") { bf.anim_frame = 0 }
		if (dad.anim == "idle") { dad.anim_frame = 0 }
		if (is_undefined(funkin_get_anim_data(gf, "danceLeft", 1))) { funkin_play_anim(gf, "idle") }
	}
	
	// Side-to-side bop (eg: gf)
	if (floor(step_real) % 4 == 0) {
		if (!is_undefined(funkin_get_anim_data(gf, "danceLeft", 1))) {
			if (floor(step_real/4) % 2) {
				funkin_play_anim(gf, "danceLeft")
			} else {
				funkin_play_anim(gf, "danceRight")
			}
		}
	}

	// Icon animation
	if (floor(step_real * 2) % 8 == 0) {
		if (bf.anim == "idle" and bf.name = "playguy") { bf.anim_frame = 0 }
		
		icon_bop = 20
	}
}

if (_section_change) {
	funkin_create_section_notes(song, section+2)
}

for (var _i = 0; _i < array_length(opp_strum_timers); _i++) {
	if (opp_strum_timers[_i] > 0) {
		opp_strum_timers[_i]--
	}
}

for (var _i = 0; _i < array_length(notes); _i++) {
	var _note = notes[_i]
	
	if (_note.pos < song_pos - 180 - _note.hold_length) {
		if (!_note.opp_side and !_note.pressed) {
			judgements.miss++
			acc = funkin_get_rating_str()
			hp -= 5
			
			array_push(rating_popups, new fnf_rating("miss", judgements))
			audio_sound_gain(voices_stream, 0, 0)
			funkin_play_anim(bf, $"{note_anims[_note.lane]}miss")
		}
		
		array_delete(notes, _i, 1)
		_i--
		continue
	}
	
	
	if (_note.opp_side and _note.pos <= song_pos and !_note.pressed) {
		audio_sound_gain(voices_stream, 1, 0)
		
		_note.pressed = 1
		opp_strum_timers[_note.lane] = 5
		
		funkin_play_anim(dad, note_anims[_note.lane])
		
		opp_anim = _note.lane
		opp_frame = 0
	}
}

for (var _i = 0; _i < array_length(rating_popups); _i++) {
	rating_popups[_i].anim_prog++
	
	if (rating_popups[_i].anim_prog >= 60) {
		array_delete(rating_popups, _i, 1)
		_i--
	}
}

hp = clamp(hp, 0, 100)

if (keyboard_check_pressed(vk_tab)) { show_debug_message(json_stringify(notes, true)) }