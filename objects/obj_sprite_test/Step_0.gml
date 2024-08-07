/// @description Insert description here
// You can write your code in this editor
var playanim = function(key, animid) { if(keyboard_check_pressed(key)) {
	anim = animid
	frametest = 0
	if (animid > 0) { arrows.states[animid-1] = (arrows.states[animid-1]+1) % 3 }
}}

frametest += 24 / game_get_speed(gamespeed_fps)
frametest2 += 24 / game_get_speed(gamespeed_fps)

playanim(vk_space, 0)
playanim(ord("D"), 1)
playanim(ord("F"), 2)
playanim(ord("K"), 3)
playanim(ord("L"), 4)

frame = frametest / game_get_speed(gamespeed_fps) * 24
frame2 = frametest2


/*playarrows(ord("1"), arrow_anims[0])
playarrows(ord("2"), arrow_anims[1])
playarrows(ord("3"), arrow_anims[2])
playarrows(ord("4"), arrow_anims[3])*/