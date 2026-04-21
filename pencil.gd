extends Area2D

# -------------------
# STATE
# -------------------
var is_completed = false
var is_broken = false
var is_sharpened = false

# -------------------
# REFERENCES
# -------------------
@onready var action_menu = get_node("/root/Classroom/UI/ActionMenu")
@onready var sprite = $Sprite2D
@onready var tip = $Tip

@onready var sharpener = get_node("/root/Classroom/Sharpener")
@onready var paper = get_node("/root/Classroom/Paper")
@onready var paper_sprite = paper.get_node("Sprite2D")

# store original (clean) paper automatically
var clean_paper_texture
var scribbled_paper_texture = preload("res://All-Images-for-Classroom/All-Images-for-Classroom/Written-Paper.png")

# READY
func _ready():
	input_pickable = true
	# store original paper texture
	clean_paper_texture = paper_sprite.texture

# CLICK
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if is_completed:
			print("Task already done 😤")
			return
		action_menu.open(global_position)
		action_menu.action_selected.connect(_on_action_selected, CONNECT_ONE_SHOT)

# ACTION SELECTED
func _on_action_selected(action):
	if is_completed:
		return
	match action:
		"break":
			break_pencil()
		"write":
			write_pencil()
		"sharpen":
			sharpen_pencil()
	complete_task()

# ACTIONS

#BREAK
func break_pencil():
	print("BREAK")
	is_broken = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 8, 0.15)
	tween.tween_property(self, "rotation_degrees", -4, 0.15)
	tween.tween_property(self, "rotation_degrees", 0, 0.2)
	tween.parallel().tween_property(self, "position:y", position.y + 3, 0.25)
	sprite.texture = preload("res://All-Images-for-Classroom/All-Images-for-Classroom/Broken-Pencil.png")
	GameManager.add_points(20)

#WRITE
func write_pencil():
	print("WRITE")
	var target_position = paper.global_position
	# align tip to paper
	var offset = tip.global_position - global_position
	var final_position = target_position - offset
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", final_position, 0.4)
	# small writing motion
	tween.tween_property(self, "position:x", position.x + 2, 0.2)
	tween.tween_property(self, "position:x", position.x - 2, 0.2)
	tween.tween_property(self, "position:x", position.x, 0.2)
	await tween.finished
	# change to scribbled
	paper_sprite.texture = scribbled_paper_texture
	remove_scribble_after_delay()
	GameManager.add_points(-5)
	GameManager.change_strictness(10)

#SHARPEN
func sharpen_pencil():
	print("SHARPEN")
	is_sharpened = true
	var target_position = sharpener.global_position
	# align tip to sharpener
	var offset = tip.global_position - global_position
	var final_position = target_position - offset
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", final_position, 0.4)
	tween.tween_property(self, "rotation_degrees", 15, 0.2)
	tween.tween_property(self, "rotation_degrees", -10, 0.2)
	tween.tween_property(self, "rotation_degrees", 0, 0.2)
	GameManager.add_points(-5)
	GameManager.change_strictness(15)

# SCRIBBLE RESET
func remove_scribble_after_delay():
	await get_tree().create_timer(10.0).timeout
	if paper_sprite.texture == scribbled_paper_texture:
		paper_sprite.texture = clean_paper_texture

# COMPLETE TASK
func complete_task():
	is_completed = true
	print("TASK COMPLETE")
	input_pickable = false
	modulate = Color(0.6, 0.6, 0.6)
