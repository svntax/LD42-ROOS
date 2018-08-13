extends Node2D

var oozePositions
var newOozePositions
var oozeColor
var backgroundColor = Color(69.0 / 255, 40.0 / 255, 60.0 / 255, 1)

func _ready():
    oozePositions = []
    newOozePositions = []
    oozeColor = Color(1, 1, 1, 1)
    for n in self.get_children():
        oozePositions.append(n.global_position)
        newOozePositions.append(n.global_position)

func _process(delta):
    moveOoze()
    update()

func moveOoze():
    for i in range(oozePositions.size()):
        if(newOozePositions[i].y < 800):
            newOozePositions[i] += Vector2(0, (randi() % 4) / 10.0)

func _draw():
    #draw_rect(Rect2(Vector2(0, 0), Vector2(800, 600)), backgroundColor)
    for i in range(oozePositions.size()):
        draw_line(oozePositions[i], newOozePositions[i], oozeColor, 4)