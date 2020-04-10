extends Spatial


# Declare member variables here. Examples:
enum queueBroken {
	NODE,
	PASSED_TIME,
	RESPAWN_TIME,
	STATE
}

var scene = null
var mineral = null
var listBroken = [] # [[mineral, 0, 30, false]] in it 
var startTime = OS.get_ticks_msec()
var thread

# Called when the node enters the scene tree for the first time.
func _ready():
	scene = get_tree().get_root()
	thread = Thread.new()
	thread.start(self, "respawnMinerals", listBroken)

func respawnMinerals(listBroken):
	while (true):
		for i in range(0, listBroken.size()):
			if (listBroken[i][queueBroken.STATE] == true
				and OS.get_ticks_msec() - listBroken[i][queueBroken.PASSED_TIME] >= listBroken[i][queueBroken.RESPAWN_TIME]
				and is_instance_valid(listBroken[i][queueBroken.NODE])):
					listBroken[i][queueBroken.NODE].visible = true
					listBroken[i][queueBroken.STATE] = false
					listBroken.remove(i)
					i -= 1

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		elif event.pressed and event.scancode == KEY_ENTER:
			mineral = scene.get_node("Minerals/Mineral1")
			if mineral != null and mineral.visible == true:
				listBroken.push_back([mineral, OS.get_ticks_msec(), 30000, true])
				mineral.visible = false
