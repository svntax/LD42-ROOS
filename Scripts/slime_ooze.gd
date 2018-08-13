extends Node2D

var oozePositions
var newOozePositions
var oozeColor

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
    for i in range(oozePositions.size()):
        draw_line(oozePositions[i], newOozePositions[i], oozeColor, 4)