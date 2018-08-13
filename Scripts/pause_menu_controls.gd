extends VBoxContainer

func _ready():
    self.hide()

func _process(delta):
    if(Input.is_action_just_pressed("PAUSE") and not Globals.gameOver):
        if(self.is_visible_in_tree()):
            self.hide()
            get_tree().paused = false
        else:
            self.show()
            get_tree().paused = true

func _on_StartButton_pressed():
    get_tree().paused = false
    get_tree().change_scene("res://Scenes/main_menu.tscn")

func _on_ReturnButton_pressed():
    self.hide()
    get_tree().paused = false
