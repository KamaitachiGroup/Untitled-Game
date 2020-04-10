extends Spatial


# Declare member variables here. Examples:
enum {
	NODE,
	PASSED_TIME,
	RESPAWN_TIME,
	STATE
}

var scene = null
var mineral = null
var listBroken = [] # [[mineral, 0, 30, false]] in it 
var thread

# Called when the node enters the scene tree for the first time.
func _ready():
	scene = get_tree().get_root()
	loadStateMinerals()
	thread = Thread.new()
	thread.start(self, "respawnMinerals", listBroken)

func respawnMinerals(listBroken):
	while (true):
		for i in range(0, listBroken.size()):
			if (listBroken[i][STATE] == true
				and OS.get_ticks_msec() - listBroken[i][PASSED_TIME] >= listBroken[i][RESPAWN_TIME]
				and is_instance_valid(listBroken[i][NODE])):
					listBroken[i][NODE].visible = true
					listBroken[i][STATE] = false
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

func saveStateMinerals():
	var save = File.new()
	save.open("user://stateMinerals.save", File.WRITE)
	for i in range(0, listBroken.size()):
		if listBroken[i][STATE] == true:
			listBroken[i][RESPAWN_TIME] -= OS.get_ticks_msec() - listBroken[i][PASSED_TIME]
			listBroken[i][NODE] = listBroken[i][NODE].name
	save.store_line(to_json(listBroken))
	save.close()
	
func loadStateMinerals():
	var loadF = File.new()
	if not loadF.file_exists("user://stateMinerals.save"):
		return
	loadF.open("user://stateMinerals.save", File.READ)
	while loadF.get_position() < loadF.get_len():
		listBroken = parse_json(loadF.get_line())
	for i in range(0, listBroken.size()):
		if listBroken[i][STATE] == true:
			listBroken[i][NODE] = scene.get_node("Minerals/" + listBroken[i][NODE])
			listBroken[i][NODE].visible = false
	loadF.close()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		saveStateMinerals()
		get_tree().quit()
