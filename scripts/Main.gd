extends Node2D

onready var lines :Line2D = $Canvas_img/Line2D

var _pressed : bool = false
var _current_line : Line2D = null
var _prev_line : Line2D = null
var pure_canvas : Texture
var brush = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pure_canvas = $Canvas_img.texture
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			_pressed = event.pressed
			if _pressed and _current_line==null:
				_current_line = Line2D.new()
				if brush==1:
					_current_line.begin_cap_mode=1
					_current_line.joint_mode=1
					_current_line.end_cap_mode=1
				else :
					_current_line.begin_cap_mode=2
					_current_line.joint_mode=2
					_current_line.end_cap_mode=2
				_current_line.antialiased=true
				if brush==2:
					_current_line.default_color = Color.white
				else:
					_current_line.default_color = $ToolsBG/ColorPickerButton.color
				_current_line.width = $ToolsBG/HScrollBar.value
				lines.add_child(_current_line)
				_current_line.add_point(event.position)
			
			elif !_pressed and _current_line!=null:
				_prev_line = _current_line
				_current_line=null
				yield(VisualServer, "frame_post_draw")
				var img = get_viewport().get_texture().get_data()
				var cropped_image = img.get_rect(Rect2($DrPos.global_position, Vector2(960,720)))
				var tex = ImageTexture.new()
				cropped_image.flip_y()
				tex.create_from_image(cropped_image)
				$Canvas_img.texture = tex
				$Canvas_img/Line2D.remove_child(_prev_line)
				img.is_queued_for_deletion()
				cropped_image.is_queued_for_deletion()
				tex.is_queued_for_deletion()
				
				
	elif event is InputEventMouseMotion and _pressed:
		_current_line.add_point(event.position)
		
func reset_canvas() :
	$Canvas_img.texture = pure_canvas
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_up():
	reset_canvas()
	pass # Replace with function body.


func _on_HScrollBar_value_changed(value):
	$ToolsBG/fontsize.bbcode_text="[center]"+str($ToolsBG/HScrollBar.value)
	pass # Replace with function body.


func _on_brush1_button_up():
	brush=0
	$ToolsBG/Sel.position.x=-80
	pass # Replace with function body.


func _on_brush2_button_up():
	brush=1
	$ToolsBG/Sel.position.x=-0
	pass # Replace with function body.


func _on_brush3_button_up():
	brush=2
	$ToolsBG/Sel.position.x=80
	pass # Replace with function body.
