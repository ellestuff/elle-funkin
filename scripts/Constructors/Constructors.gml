// Contains the different constructors made for storing data

// Sparrow-v2 character spritesheet
function sprite_xml(path) constructor {
	var _time = current_time
	
	var _path_split = string_split(path, "/", 0)
	while (array_length(_path_split) > 2) { _path_split[0] = $"{_path_split[0]}/{_path_split[1]}"; array_delete(_path_split,1,1) }
	
	xml = xml_sparrowv2_parse(_path_split[0], _path_split[1])
	
	// [DEBUG] check if image_path is being collected correctly
	/*if (xml.image_path == "assets/images/characters/BOYFRIEND.png") { //replace path when testing
	  show_message("samesies")
	} else { show_message($"samesiesn't\n\n{xml.image_path}"); clipboard_set_text(xml.image_path) }*/
	
	spr = sprite_add(xml.image_path,1,0,1,0,0)
	
	show_debug_message($"[{current_time/1000}] Spritesheet {xml.image_path} created in {(current_time - _time) / 1000} seconds")
}

// Psych character .json data
function character(modname, name) constructor {
	var _time = current_time
	
	var _path = $"{modname}/characters/{name}.json"
	
	if (!file_exists(_path)) {
		show_message($"File \"{_path}\" not found. Exiting...")
		game_end()
		exit
	}
	
	var _file = file_text_open_read(_path)
	
	var _contents = ""
	while (!file_text_eoln(_file)) { _contents += file_text_readln(_file) }
	var _json = json_parse(_contents)
	
	sing_duration = _json.sing_duration
	scale = _json.scale
	anti_aliased = !_json.no_antialiasing
	flip_x = _json.flip_x
	
	offset = _json.position
	cam_offset = _json.camera_position
	
	health_icon = sprite_add($"{modname}/images/icons/icon-{_json.healthicon}.png",2,0,1,75,75)
	health_colour = make_color_rgb(_json.healthbar_colors[0],_json.healthbar_colors[1],_json.healthbar_colors[2])
	
	// Make Sprite
	sprite = new sprite_xml($"{modname}/images/{_json.image}.xml")
	
	// Register Animations
	animations = {}
	for (var _i = 0; _i < array_length(_json.animations); _i++) {
		var _anim = _json.animations[_i]
		var _animname = _anim.anim
		_anim.name = string_replace_all(_anim.name, " ", "_")
		_anim.length = get_anim_frames(sprite, _anim.name)
		
		struct_remove(_anim,"anim")
		struct_set(animations, _animname, _anim)
	}
	
	show_debug_message($"[{current_time/1000}] Character {name} created in {(current_time - _time) / 1000} seconds")
}

// Strumline data
function strumline(skin_path) constructor {
	states = [0,0,0,0]
	frames = [0,0,0,0]
	skin = new sprite_xml(skin_path) 
}
