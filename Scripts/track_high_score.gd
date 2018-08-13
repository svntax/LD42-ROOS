extends Label

func _ready():
    self.set_text("High Score: " + str(Globals.highScore) + "%")
    centerToScreenHorizontally()

func centerToScreenHorizontally():
    var w = self.rect_size.x
    var centerX = get_viewport().get_visible_rect().size.x / 2
    self.set_position(Vector2(centerX - (w / 2), self.rect_position.y))