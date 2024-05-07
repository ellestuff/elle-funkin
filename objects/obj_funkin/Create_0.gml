/*		- Friday Night Funkin' Recreation To-Do list -
 -	gf
 -	stage support
 -	hold notes attempt #3
 -	note splashes
 -	properly implement async loading
 -	score
*/

global.framerate = game_get_speed(gamespeed_fps)

win_w = 480
win_h = 270

song = undefined

ui = surface_create(win_w, win_h)

anti_aliased = true

selected_song = 0
playing_song = false

game_paused = false

input_binds = ["D", "F", "K", "L"]
note_anims = ["singLEFT","singDOWN","singUP","singRIGHT"]

funkin_get_data()
funkin_song_defaults()

ac_channel = animcurve_get_channel(ac_curves, 0)

//		- Window Functions -
// Remove audio streams on window delete to prevent memory leak (and music continuing to play)
function on_delete() {
	end_song()
}

function on_unfocus() {
	if (playing_song) { pause_game(true) }
}

function draw_window() {
	draw_set_color(c_black)
	draw_set_font(fnt_default)
	
	if (playing_song) {
		draw_stage()
		draw_chars()
		
		draw_ui()
		
		if (game_paused) {
			draw_pause_menu()
		}
	}
	else {
		draw_menu()
	}
	
	
}


//		- Game Draw Functions -
// Draw the UI surface
function draw_ui() {
	if (!surface_exists(ui)) { ui = surface_create(win_w, win_h) }

	if (surface_exists(ui)) {
		surface_set_target(ui)
		draw_clear_alpha(c_white, 0)

		draw_set_alpha(1)
		
		gpu_set_texfilter(false)
		
		draw_strums()
		draw_arrow_lanes()
		
		draw_ratings()
		
		draw_health()
		draw_song_progress()
		
		draw_judgements()
		
		draw_set_color(c_black)
		draw_set_halign(fa_left)
		draw_text(1,0, $"FPS: {floor(fps_real)}")
		
		surface_reset_target()
	}
	
	
	draw_surface_ext(ui, 0, 0, 1, 1, 0, c_white, 1)
}

// Draw the arrow strums
function draw_strums() {
	for (var _i = 0; _i < array_length(strums); _i++) {
		var _strum = strums[_i]
		
		var _is_opp = _i < (array_length(strums)/2)
		var _player_press = 0
		
		if (!_is_opp) { _player_press = (inputs[_i - 4] == 1 or inputs[_i - 4] == 2) }
		
		var _spr = spr_strums
		
		if (_player_press or (_is_opp and opp_strum_timers[_i % 4] > 0)) { _spr = spr_strums_pressed }
		
		draw_sprite(_spr, _i % 4, _strum.x, _strum.y)
	}
}

// Draw the incoming arrows
function draw_arrow_lanes() {
	// Don't draw arrows after song ends
	if (!audio_is_playing(inst)) { exit }
	
	var _old_tex = gpu_get_tex_filter() // Store anti-aliasing status to restore afterwards
	
	for (_i = 0; _i < array_length(notes); _i++) {
		// see fnf_note() constructor for more info
		
		var _note = notes[_i]
		
		var _note_dist = (_note.pos - song_pos) * song.chart.speed / 8 + strums[_note.lane].y
		
		var _lane = _note.lane + (4 * !_note.opp_side)
		
		var _lane_x = strums[_lane].x
		
		if (_note.hold_length > 0) {
			var _hold_len_real = _note.hold_length * song.chart.speed / 8
			
			// Normal
			if (!_note.pressed) {
				var _spr = spr_hold
				if (song_pos - _note.pos > 180) { _spr = spr_hold_bad }
				
				draw_sprite_ext(_spr, _note.lane, _lane_x, _note_dist, 1, _hold_len_real / 8, 0, c_white, 1 - (_spr == spr_hold_bad) * 0.2)
			}
			//draw_sprite_ext(spr_hold, _note.lane, _lane_x, _note_dist, 1, _hold_len_real / 8, 0, c_white, 1)
			
		}
		
		if (_note.pressed == 0) { draw_sprite_ext( spr_arrows, _note.lane, _lane_x, _note_dist, 1, 1, 0, c_white, 1) }
		if (_note.pressed == 2) { draw_sprite_ext(spr_arrows_bad, _note.lane, _lane_x, _note_dist, 1, 1, 0, c_white, 0.8) }
		
		if (_note.pressed != 1) { draw_text_outline(_lane_x - 16, _note_dist - 16, _note.hold_pressed) }
		
	}
	gpu_set_tex_filter(_old_tex)
}

// Draw health bar
function draw_health() {
	bar_y = win_h - 32
	var _hp_pos = win_w/2 + 100 - (hp*2)
	
	// Get bar colours
	var _bf_c_vals = bf.json.healthbar_colors
	var _opp_c_vals = dad.json.healthbar_colors
	var _c_bf = make_color_rgb(_bf_c_vals[0], _bf_c_vals[1], _bf_c_vals[2])
	var _c_opp = make_color_rgb(_opp_c_vals[0], _opp_c_vals[1], _opp_c_vals[2])
	
	// Draw BF bar
	draw_set_color(_c_bf)
	draw_rectangle(_hp_pos, bar_y - 4, win_w/2 + 100, bar_y + 4, 0)
	
	// Draw Opponent bar
	draw_set_color(_c_opp)
	draw_rectangle(win_w/2 - 100, bar_y - 4, _hp_pos, bar_y + 4, 0)
	
	// Draw HP outline
	draw_sprite_ext(spr_bar, 0, win_w/2 - 103, bar_y - 7, 206/7, 15/11, 0, c_white, 1)
	
	// Draw Icons
	var _scale_add = animcurve_channel_evaluate(ac_channel, icon_bop/20) * 0.1
	
	var _ourple_flip = (floor(step_real/4) % 2) * (bf.name == "playguy")
	
	gpu_set_tex_filter(!dad.json.no_antialiasing)
	draw_sprite_ext(dad.icon, hp >= 80, _hp_pos - 20, bar_y, 0.4 + _scale_add, 0.4 + _scale_add, 0, c_white, 1)
	gpu_set_tex_filter(!bf.json.no_antialiasing)
	draw_sprite_ext(bf.icon, hp <= 20, _hp_pos + 20, bar_y, (-0.4 - _scale_add) * -(_ourple_flip * 2 - 1), 0.4 + _scale_add, 0, c_white, 1)
	gpu_set_tex_filter(false)
	
	// Draw stats
	draw_set_halign(fa_center)
	draw_text_outline(win_w/2, bar_y + 12, $"Score: {scr} | Misses: {judgements.miss} | Rating: {acc}", #ebede9, #10141f)
	draw_set_halign(fa_left)
}

// Draw health bar
function draw_song_progress() {
	bar_y = 12
	var _song_pos = (song_pos/1000) / song_len
	
	var _bar_pos = win_w/2 - 76 + (_song_pos*152)
	
	var _remaining = floor(song_len - (song_pos/1000))
	var _time = $"{_remaining div 60}:{string_replace(string_format(_remaining%60, 2, 0)," ", "0")}"
	
	// Draw bar
	draw_set_color(#090a14)
	draw_rectangle(win_w/2 - 75, bar_y - 4, win_w/2 + 75, bar_y, 0)
	draw_set_color(#ebede9)
	draw_rectangle(win_w/2 - 76, bar_y - 4, _bar_pos, bar_y, 0)
	
	// Draw outline
	draw_sprite_ext(spr_bar, 0, win_w/2 - 78, bar_y - 7, 156/7, 1, 0, c_white, 1)
	draw_set_halign(fa_center)
	draw_text_outline(win_w/2, bar_y - 10, _time, #ebede9, #10141f)
}

// Draw pause menu
function draw_pause_menu() {
	draw_set_color(#a8b5b2)
	draw_set_font(fnt_big)
	draw_set_halign(fa_center)
	
	gpu_set_blendmode_ext(bm_dest_color, bm_zero)
	draw_set_alpha(1)
	draw_rectangle(0,0,win_w,win_h,0)
	gpu_set_blendmode(bm_normal)
	
	draw_set_alpha(1)
	draw_text_outline(win_w/2, 24, "Game Paused")
	draw_text_outline(win_w/2, 72, "Press [Enter] to resume")
	draw_text_outline(win_w/2, 96, "Press [Backspace] to exit")
	draw_text_outline(win_w/2, 120, "Press [R] to restart")
}

// Draw actual menu
function draw_menu() {
	draw_text_outline(6, 2, $"Press [SPACE] to play {struct_get(songs, song_list[selected_song]).chart.song}")
	draw_text_outline(6, 14, $"Use arrow keys [^/v] to switch songs")
	
	for (_i = 0; _i < array_length(song_list); _i++) {
		var _str = struct_get(songs, song_list[_i]).chart.song
		if (_i == selected_song) { _str = $" >{_str}" }
		
		draw_text_outline(6, 32 + (12 * _i), _str)
	}
}

// Draw stage
function draw_stage() {
	
}

// Draw characters
function draw_chars() {
	// Flip specifically for ourple guy in lore, may replace with external scripting support down the road.
	var _ourple_flip = (floor(step_real/4) % 2) * (bf.name == "playguy") * (bf.anim == "idle")
	
	// Draw Characters
	funkin_draw_sprite(gf, 180, 60)
	funkin_draw_sprite(dad, 100, 60)
	funkin_draw_sprite(bf, 270 - (_ourple_flip * 246),60,, !_ourple_flip)
	
}

// Draw Ratings
function draw_ratings() {
	for (var _i = 0; _i < array_length(rating_popups); _i++) {
		var _rating = rating_popups[_i]
		var _y = animcurve_channel_evaluate(ac_channel, _rating.anim_prog/60) * 120
		
		var _a = 1
		if (_rating.anim_prog >= 50) {
			_a = 1 - (_rating.anim_prog - 50) / 10
		}
		
		draw_sprite_ext(spr_ratings, _rating.subimg, win_w/2 + _rating.x_spd * _rating.anim_prog / 4, _y + win_h/4, 2, 2, 0, c_white, _a)
	}
}

// Draw Judgements on side of screen
function draw_judgements() {
	draw_set_halign(fa_right)
	draw_set_font(fnt_small)
	
	draw_set_color(#202e37)
	
	draw_text(win_w - 1, win_h/2 - 16, $"Sick: {judgements.sick}")
	draw_text(win_w - 1, win_h/2 - 8, $"Good: {judgements.good}")
	draw_text(win_w - 1, win_h/2, $"Bad: {judgements.bad}")
	draw_text(win_w - 1, win_h/2 + 8, $"Shit: {judgements.shit}")
	draw_text(win_w - 1, win_h/2 + 16, $"Misses: {judgements.miss}")
}


//		- Other functions that don't quite belong in scr_fnf -
// Game pause
function pause_game(state) {
	game_paused = state
	
	
	
	if (audio_exists(inst_stream)) {
		if (game_paused) { audio_pause_sound(inst_stream) }
		else { audio_resume_sound(inst_stream) }
	}
	if (audio_exists(voices_stream)) {
		if (game_paused) { audio_pause_sound(voices_stream) }
		else { audio_resume_sound(voices_stream) }
	}
}

