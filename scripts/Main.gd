extends Node2D

onready var lines :Line2D = $Canvas_img/Line2D

var _pressed : bool = false
var _current_line : Line2D = null
var _prev_line : Line2D = null
var pure_canvas : Texture
var brush = 0
signal activeReceiver(ChannelID)
var state = 0
#state is title/select/draw/
var answer = ""
var panel3 = 0.0
var panel4 = 0.0
var leaderboard:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pure_canvas = $Canvas_img.texture
	pass # Replace with function body.

func _input(event):
	
	if state == 2:
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
func _process(delta):
	if state == 3 && panel3<1:
		panel3 = clamp(panel3+(delta*2.0),0,1)
		$Closed.position.y = 1080-(panel3*720)
	elif state !=3 && panel3>0:
		panel3 = clamp(panel3-(delta*2.0),0,1)
		$Closed.position.y = 1080-(panel3*720)
	if state == 4 && panel4<1:
		panel4 = clamp(panel4+(delta*2.0),0,1)
		$LeaderboardBg.position.y = -360+(panel4*720)
	pass


func _on_Button_button_up():
	var CID = $Title/ChannelIDInput.text
	$Receiver._connection(CID)
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


func _on_Receiver_chatReceived(Nickname, Msg):
	print_debug(str(Nickname)+" : "+str(Msg))
	if state==2 and Msg==answer:
		$Closed/Answer.bbcode_text="[center]정답 : "+str(answer)
		$Closed/member.bbcode_text="[center]맞힌 사람 : "+str(Nickname)
		if leaderboard.has(str(Nickname)):
			leaderboard[str(Nickname)] = leaderboard[str(Nickname)]+1
			print(str(Nickname)+" : 현재" + str(leaderboard[str(Nickname)])+"점")
		else:
			leaderboard[str(Nickname)] = 1
			print(str(Nickname)+" : 현재" + str(leaderboard[str(Nickname)])+"점")
		state=3
		leaderboardRefresh()
		
	pass # Replace with function body.


func _on_Receiver_connected():
	leaderboard.clear()
	$Loading.visible=true
	$Title.visible=false
	$Closed/ClosedBg2.visible=false
	state=1
	pass # Replace with function body.


func _on_Setter_button_up():
	if $Loading/Answer.text!="":
		answer=$Loading/Answer.text
		$Loading.visible=false
		state=2
	pass # Replace with function body.


func _on_NextButton_button_up():
	reset_canvas()
	$Loading.visible=true
	state=1
	pass # Replace with function body.


func _on_ENDButton_button_up():
	state=4
	pass # Replace with function body.


func _on_License_button_up():
	$Title/LicenseBG.visible=true
	pass # Replace with function body.


func _on_CloseButton_button_up():
	$Title/LicenseBG.visible=false
	pass # Replace with function body.


func _on_Restart_pressed():
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_FillButton_button_up():
	if state==2 && panel3 <= 0:
		var fills = Line2D.new()
		fills.default_color = $ToolsBG/ColorPickerButton.color
		fills.width = 2000
		fills.begin_cap_mode=2
		fills.joint_mode=2
		fills.end_cap_mode=2
		fills.add_point(Vector2(640,360))
		fills.add_point(Vector2(640,361))
		lines.add_child(fills)
		yield(VisualServer, "frame_post_draw")
		var img = get_viewport().get_texture().get_data()
		var cropped_image = img.get_rect(Rect2($DrPos.global_position, Vector2(960,720)))
		var tex = ImageTexture.new()
		cropped_image.flip_y()
		tex.create_from_image(cropped_image)
		$Canvas_img.texture = tex
		$Canvas_img/Line2D.remove_child(fills)
		img.is_queued_for_deletion()
		cropped_image.is_queued_for_deletion()
		tex.is_queued_for_deletion()
	pass # Replace with function body.


func _on_Button2_button_up():
	if state==2:
		$Closed/ClosedBg2.visible=true
		$Closed/Answer.bbcode_text="[center]중단되었습니다."
		$Closed/member.bbcode_text="[center]정답은 "+ answer+" 였습니다."
		state=3
	pass # Replace with function body.

func leaderboardRefresh():
	var scores = [0,0,0]
	var names = ["","",""]
	for name in leaderboard:
		if leaderboard[name]>scores[0]:
			names[2] = names[1]
			names[1] = names[0]
			names[0] = name
			scores[2] = scores[1]
			scores[1] = scores[0]
			scores[0] = leaderboard[name]
		elif leaderboard[name]>scores[1]:
			names[2] = names[1]
			names[1] = name
			scores[2] = scores[1]
			scores[1] = leaderboard[name]
		elif leaderboard[name]>scores[2]:
			names[2] = name
			scores[2] = leaderboard[name]
	$LeaderboardBg/User1.bbcode_text = "[center]"+names[0]
	$LeaderboardBg/User2.bbcode_text = "[center]"+names[1]
	$LeaderboardBg/User3.bbcode_text = "[center]"+names[2]
	$LeaderboardBg/Score1.bbcode_text = "[center]"+str(scores[0])
	$LeaderboardBg/Score2.bbcode_text = "[center]"+str(scores[1])
	$LeaderboardBg/Score3.bbcode_text = "[center]"+str(scores[2])
	pass
