extends CSGBox


# Declare member variables here. Examples:
enum {
	BEGIN_TIME = 0,
	RESPAWN_TIME = 1
}

var breakable = [-1, 30000]



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible == false and breakable[BEGIN_TIME] == -1:
		breakable[BEGIN_TIME] = OS.get_ticks_msec()
	elif self.visible == false and OS.get_ticks_msec() - breakable[BEGIN_TIME] >= breakable[RESPAWN_TIME]:
		self.visible = true
		breakable[BEGIN_TIME] = -1



################################################
#
#	These two last functions are only for tests
#
################################################

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.scancode == KEY_ENTER and self.visible:
			self.visible = false

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()
