extends VBoxContainer

func _ready():
    self.hide()

func showGameOverUI():
    self.show()
    Globals.gameOver = true
    get_tree().paused = true

func _on_BackButton_pressed():
    get_tree().paused = false
    Globals.gameOver = false
    get_tree().change_scene("res://Scenes/main_menu.tscn")
