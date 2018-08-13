extends VBoxContainer

func _ready():
    self.hide()

func showGameOverUI():
    self.show()
    Globals.gameOver = true
    get_tree().paused = true

func showGameWinUI():
    self.show()
    find_node("Label").hide()
    find_node("WinMessage").show()
    find_node("Score").show()
    find_node("Score").set_text("Tiles slimed: " + str(Globals.score) + "%")
    if(Globals.score > Globals.highScore):
        Globals.highScore = Globals.score
        find_node("HighScore").show()
    Globals.gameOver = true
    get_tree().paused = true

func _on_BackButton_pressed():
    get_tree().paused = false
    Globals.gameOver = false
    get_tree().change_scene("res://Scenes/main_menu.tscn")
