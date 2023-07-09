extends CharacterBody2D

@export var movement_data: PlayerMovementData

var air_jump = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_timer = $CoyoteTimer

func _physics_process(delta: float):
    apply_gravity(delta)

    handle_jump()

    var input_axis = Input.get_axis("ui_left", "ui_right")

    apply_friction(input_axis, delta)
    apply_air_resistance(input_axis, delta)
    handle_acceleration(input_axis, delta)
    handle_air_acceleration(input_axis, delta)
    handle_animation(input_axis)

    var was_on_floor = is_on_floor()
    move_and_slide()
    if was_on_floor and not is_on_floor() and velocity.y >= 0:
        coyote_timer.start()
    if Input.is_action_just_pressed("ui_accept"):
        movement_data = load("res://FasterMovementData.tres")

func apply_gravity(delta: float):
    if not is_on_floor():
        velocity.y += gravity * movement_data.gravity_scale * delta

func handle_jump():
    if is_on_floor():
        air_jump = true

    if is_on_floor() or not coyote_timer.is_stopped():
        if Input.is_action_just_pressed("ui_up"):
            velocity.y = movement_data.jump_velocity
    if not is_on_floor():
        if Input.is_action_just_released("ui_up") and velocity.y < movement_data.jump_velocity / 3:
            velocity.y = movement_data.jump_velocity / 3

        if Input.is_action_just_pressed("ui_up") and air_jump:
            velocity.y = movement_data.jump_velocity / 2
            air_jump = false

func handle_acceleration(input_axis: float, delta: float):
    if not is_on_floor():
        return
    if input_axis:
        velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis: float, delta: float):
    if is_on_floor():
        return
    if input_axis:
        velocity.x = move_toward(velocity.x, input_axis * movement_data.speed, movement_data.air_acceleration * delta)

func apply_friction(input_axis: float, delta: float):
    if input_axis == 0 and is_on_floor():
        velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis: float, delta: float):
    if input_axis == 0 and not is_on_floor():
        velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)

func handle_animation(inpus_axis: float):
    if velocity.x != 0:
        animated_sprite_2d.play("run")
        animated_sprite_2d.flip_h = inpus_axis < 0
    else:
        animated_sprite_2d.play("idle")
