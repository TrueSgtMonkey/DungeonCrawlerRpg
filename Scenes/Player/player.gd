extends CharacterBody3D


const SPEED_DEFAULT : float = 5.0
const CAMERA_ROTATION_SPEED_DEFAULT : float = 3.0
const JUMP_VELOCITY_DEFAULT : float = 9.0
const MAX_ZOOM : float = 25.0
const MIN_ZOOM : float = 1.0

# Project Settings Variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Reference Variables
var cameraPivotRef : Node3D = null
var cameraRef : Camera3D = null

# State Variables
var isMouseRotateHeld := false

# Physics Variables
var delt := 0.0

func _ready():
	cameraPivotRef = $CameraPivot
	cameraRef = $CameraPivot/Camera3D
	
func _input(event):
	if !isMouseRotateHeld && event.is_action_pressed("MouseRotateEnable"):
		isMouseRotateHeld = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif isMouseRotateHeld && event.is_action_released("MouseRotateEnable"):
		isMouseRotateHeld = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("ScrollZoomIn"):
		setCameraZoom(-1.0)
	elif event.is_action_pressed("ScrollZoomOut"):
		setCameraZoom(1.0)

func _physics_process(delta):
	delt = delta
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	playerJump()

	# Moving the player horizontally
	changeMoveDirection()
	changeCameraRotation(delta)
	changeCameraZoom()

	move_and_slide()
	
func _unhandled_input(event):
	if isMouseRotateHeld && (event is InputEventMouseMotion):
		cameraPivotRef.rotate_y(event.relative.x * CAMERA_ROTATION_SPEED_DEFAULT * delt)
	
func changeMoveDirection():
	var inputDir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackward")
	var direction = (cameraPivotRef.transform.basis * cameraRef.transform.basis *
						Vector3(inputDir.x, 0, inputDir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED_DEFAULT
		velocity.z = direction.z * SPEED_DEFAULT
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_DEFAULT)
		velocity.z = move_toward(velocity.z, 0, SPEED_DEFAULT)
		
func changeCameraRotation(delta : float):
	if !isMouseRotateHeld:
		var inputLeft  : float = Input.get_action_strength("RotateCameraLeft")
		var inputRight : float = Input.get_action_strength("RotateCameraRight")
		inputLeft *= -1.0
		var completeInput : float = inputLeft + inputRight
		cameraPivotRef.rotate_y(delta * CAMERA_ROTATION_SPEED_DEFAULT * completeInput)
	
func changeCameraZoom():
	var inputZoomIn  : float = Input.get_action_strength("CameraZoomIn")
	var inputZoomOut : float = Input.get_action_strength("CameraZoomOut")
	inputZoomIn *= -1
	setCameraZoom(inputZoomIn + inputZoomOut)
	
func setCameraZoom(zoomInput : float):
	cameraRef.size = clamp((zoomInput + cameraRef.size), MIN_ZOOM, MAX_ZOOM)
	
func playerJump():
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY_DEFAULT
