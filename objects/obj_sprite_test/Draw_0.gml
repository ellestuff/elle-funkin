/// @description Insert description here
// You can write your code in this editor
draw_sprite_character(anims[anim], frametest, bf, room_width - 600, room_height - 800, -1)
draw_sprite_character(anims[anim], frametest, opponent, 100, room_height - 800)

draw_set_color(bf.health_colour)
draw_rectangle(room_width/2 - 75, room_height - 100, room_width/2 + 75, room_height - 50,0)

draw_sprite_ext(opponent.health_icon, 1, room_width/2 - 75, room_height - 75, 1, 1, 0, c_white, 1)
draw_sprite_ext(bf.health_icon, 0, room_width/2 + 75, room_height - 75, -1, 1, 0, c_white, 1)

draw_strumline(opparrows, room_width/4, 150)
draw_strumline(arrows, room_width/4 * 3, 150)