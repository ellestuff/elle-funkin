// Scripts used to draw the strums and arrows used for actually playing the game

// Draw the grey strumline arrows
function draw_strumline(strums, x, y, gap = 170){
	var _arrow_anims = [
		["arrowLEFT",  "left_press", "left_confirm"],
		["arrowDOWN",  "down_press", "down_confirm"],
		["arrowUP",      "up_press",   "up_confirm"],
		["arrowRIGHT","right_press","right_confirm"]
	]
	
	draw_sprite_sparrow(_arrow_anims[0][strums.states[0]], strums.frames[0], strums.skin, x - (gap * 1.5), y,,,,0.5,0.5)
	draw_sprite_sparrow(_arrow_anims[1][strums.states[1]], strums.frames[1], strums.skin, x - (gap * 0.5), y,,,,0.5,0.5)
	draw_sprite_sparrow(_arrow_anims[2][strums.states[2]], strums.frames[2], strums.skin, x + (gap * 0.5), y,,,,0.5,0.5)
	draw_sprite_sparrow(_arrow_anims[3][strums.states[3]], strums.frames[3], strums.skin, x + (gap * 1.5), y,,,,0.5,0.5)
}