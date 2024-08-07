// This script contains the functions necessary to draw sprites using Sparrow-v2 spritesheets.

// Convert a Sparrow-v2 spritesheet into a readable data structure
function xml_sparrowv2_parse(xml_path, filename){
	// I'm not doing this again, I just copied it from the old version
	
	var _data = {
		frames: {}
	}
	
	if (!string_ends_with(xml_path, "/") and !string_starts_with(filename, "/")) { xml_path = $"{xml_path}/" }
	
	if (!file_exists($"{xml_path}{filename}")) {
		show_message($"File \"{xml_path}{filename}\" not found. Exiting...")
		game_end()
		exit
	}
	
	var _file = file_text_open_read($"{xml_path}{filename}")
	
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
			
			_test[1] = string_trim(_test[1], ["\n", " ", "\r", "\""])
			_test[1] = string_trim_end(_test[1], ["\">"])
			
			_data.image_path = $"{xml_path}{_test[1]}"
		}
		
		// Get Frame stuff
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
			
			// Create Frame
			
			// Fix missing extra data
			if (array_length(_values) == 5) {
				array_push(_values, 0) // frameX
				array_push(_values, 0) // frameY
			}
			if (array_length(_values) == 7) {
				array_push(_values,  _values[3]) // frameWidth
				array_push(_values, _values[4]) // frameHeight
			}
			
			// Frame Data
			var _frame = {
				x: _values[1],
				y: _values[2],
				
				width: _values[3],
				height: _values[4],
				
				frame_x: _values[5],
				frame_y: _values[6],
				
				frame_w: _values[7],
				frame_h: _values[8]
			}
			
			struct_set(_data.frames, _values[0], _frame)
		}
	}
	
	return _data
}

// Draw a sprite using a spritesheet
function draw_sprite_sparrow(anim, frame, xml_sprite, x, y, x_scale = 1, y_scale = 1, anti_aliasing = undefined, origin_x = 0, origin_y = 0) {
	var _old_aa = gpu_get_tex_filter()
	
	var _frame = clamp(frame, 0, get_anim_frames(xml_sprite, anim)-1)
	
	var _anim_name = $"{string_replace_all(anim, " ", "_")}{string_replace_all(string_format(_frame,4,0), " ", "0")}"
	var _spr = struct_get(xml_sprite.xml.frames, _anim_name)
	
	var _x = x - real(_spr.frame_w) * origin_x - _spr.frame_x
	var _y = y - real(_spr.frame_h) * origin_y - _spr.frame_y
	
	if (is_bool(anti_aliasing)) { gpu_set_tex_filter(anti_aliasing) }
	draw_sprite_part_ext(xml_sprite.spr, 0, _spr.x, _spr.y, _spr.width, _spr.height, _x, _y, x_scale, y_scale, c_white, 1)
	gpu_set_tex_filter(_old_aa)
}


// Draw a sprite using a character
function draw_sprite_character(anim, frame, char, x, y, x_scale = 1, y_scale = 1) {
	var _anim = struct_get(char.animations, anim)
	var _sheet_anim = string_replace_all(struct_get(char.animations, anim).name, " ", "_")
	draw_set_color(char.health_colour)
	
	if (array_length(_anim.indices) > 0) { frame = _anim.indices[frame] }
	
	x_scale *= char.flip_x * -2 + 1
	
	draw_sprite_sparrow(_sheet_anim, frame, char.sprite, x + char.offset[0] - (_anim.offsets[0] * x_scale),y + char.offset[1] - (_anim.offsets[1] * y_scale), char.scale * x_scale, char.scale * y_scale, char.anti_aliased)
}

// Count the amount of frames an animation has in a sprite_xml
function get_anim_frames(spr_xml, anim) { 
    var _data = {
        count: 0,
        _anim: anim
    }
    
    struct_foreach(spr_xml.xml.frames, method(_data, function(_name) {
        var _name2 = string_delete(_name, -4, 4)
        count += (_name2 == _anim)
    }))
    
    return _data.count
}