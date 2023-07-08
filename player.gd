extends CharacterBody2D

const SPEED = 100.0
const ACCELERATION = 800.0
const FRICTION = 1000.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta: float):
    apply_gravity(delta)

    handle_jump()

    var direction = Input.get_axis("ui_left", "ui_right")

    apply_friction(direction, delta)
    handle_acceleration(direction, delta)
    handle_animation(direction)

    move_and_slide()

func apply_gravity(delta: float):
    if not is_on_floor():
        velocity.y += gravity * delta

func handle_jump():
    if is_on_floor():
        if Input.is_action_just_pressed("ui_accept"):
            velocity.y = JUMP_VELOCITY
    else:
        if Input.is_action_just_released("ui_accept") and velocity.y < JUMP_VELOCITY / 3:
            velocity.y = JUMP_VELOCITY / 3

func handle_acceleration(input_axis: float, delta: float):
    if input_axis:
        velocity.x = move_toward(velocity.x, input_axis * SPEED, ACCELERATION * delta)

func apply_friction(input_axis: float, delta: float):
    if input_axis == 0:
        velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_animation(inpus_axis: float):
    if velocity.x != 0:
        animated_sprite_2d.play("run")
        animated_sprite_2d.flip_h = inpus_axis < 0
    else:
        animated_sprite_2d.play("idle")
