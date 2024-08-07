/// @description Insert description here
// You can write your code in this editor
frametest = 0
frame = 0

frametest2 = 0
frame2 = 0

anims = ["idle", "singLEFT", "singDOWN", "singUP", "singRIGHT"]
anim = 0

arrowtest = [0,0,0,0]

bf = new character("assets", "bf")
opponent = new character("assets", "dad")

arrows = new strumline("assets/images/noteskins/NOTE_assets.xml")
opparrows = new strumline("assets/images/noteskins/NOTE_assets.xml")
show_debug_message(arrows)