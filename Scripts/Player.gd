
extends KinematicBody2D

const MOTION_SPEED = 140;
const DASH_SPEED = 10;

var isRunning = false;
var isDashing = false;
var isHacking = false;
var isZoomedOut = false;

onready var Store = get_node("/root/Store");
onready var MyTimer = get_node("/root/MyTimer");

func _ready():
	# Set up animation
	var sprite = get_node("AnimatedSprite");
	sprite.get_sprite_frames().set_animation_speed("run", 10.0);
	sprite.get_sprite_frames().set_animation_speed("hack", 10.0);
	get_node("MoveCollision").set("trigger", false);
	set_process(true);
	set_process_input(true);
	set_fixed_process(true);
	
func _input(event):
	if (event.is_action_pressed("ui_terminal")):
		isHacking = !isHacking;
		if (isHacking):
			get_node("Camera2D/CanvasLayer/Terminal").initialize();
		else:
			get_node("Camera2D/CanvasLayer/Terminal").close();
	elif (event.type == InputEvent.KEY):
		if (isHacking and !get_node("Camera2D/CanvasLayer/Terminal").has_focus()):
			get_node("Camera2D/CanvasLayer/Terminal").grab_focus();

func _process(delta):
	var sprite = get_node("AnimatedSprite");
	
	if (Input.is_action_pressed("ui_up")):
		isRunning = true;
	elif (Input.is_action_pressed("ui_down")):
		isRunning = true;
	elif (Input.is_action_pressed("ui_left")):
		isRunning = true;
		sprite.set_flip_h(true);
	elif (Input.is_action_pressed("ui_right")):
		isRunning = true;
		sprite.set_flip_h(false);
	else:
		isRunning = false;
		
	isRunning = isRunning && !isHacking;
		
	if (isRunning):
		sprite.play("run");
	elif (isHacking):	
		sprite.play("hack");
	else:
		sprite.play("idle");

func _fixed_process(delta):
	var motion = Vector2();
	if (Input.is_action_pressed("ui_up")):
		motion += Vector2(0, -1);
	if (Input.is_action_pressed("ui_down")):
		motion += Vector2(0, 1);
	if (Input.is_action_pressed("ui_left")):
		motion += Vector2(-1, 0);
	if (Input.is_action_pressed("ui_right")):
		motion += Vector2(1, 0);
	if (Input.is_action_pressed("ui_dash")):
		isDashing = true;
	
	if (isHacking):
		return;
	
	motion = motion.normalized()*MOTION_SPEED*delta;
	if (isDashing):
		motion = motion*DASH_SPEED;
		isDashing = false;
	motion = move(motion);

func affect_player():
	var label = get_node("Label");
	label.set_text("I'M AFFECTED");
	MyTimer._wait(4);
	yield(MyTimer, "timer_end");
	label.set_text("");

func zoomOut():
	if (!isZoomedOut):
		get_node("AnimationPlayer").play("Dash_Zoom_Out");
		isZoomedOut = true;
		
func zoomIn():
	if (isZoomedOut):
		get_node("AnimationPlayer").play("Dash_Zoom_In");
		isZoomedOut = false;
	# TODO:
		# Set limits to dash
		# Add dash "after - image"