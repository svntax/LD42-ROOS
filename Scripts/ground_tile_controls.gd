extends Node2D

var melting
var bfsSource
var initialDelay

#Variables for slime line shoot attack
var lineSource
var lineDirection
var lineAmount

var arena

func _ready():
    arena = get_tree().get_nodes_in_group("arenas")[0]
    melting = false
    bfsSource = null
    initialDelay = -1
    lineSource = null
    lineDirection = null
    lineAmount = -1

func showPlayerSlime():
    get_node("PlayerSlime").show()
    get_node("RedSlime").hide()

func showRedSlime():
    get_node("PlayerSlime").hide()
    get_node("RedSlime").show()

func _on_MeltTimer_timeout():
    find_node("AnimationPlayer").play("destroyAnim")
    arena.meltTileAt(bfsSource)

func startMelting(delay, sourceCellPos):
    melting = true
    initialDelay = delay
    find_node("MeltTimer").set_wait_time(delay)
    find_node("MeltTimer").start()
    bfsSource = sourceCellPos

func isMelting():
    return melting

func _on_AnimationPlayer_animation_finished(anim_name):
    arena.meltPlayerTiles(bfsSource + Vector2(0, 1), initialDelay)
    arena.meltPlayerTiles(bfsSource + Vector2(0, -1), initialDelay)
    arena.meltPlayerTiles(bfsSource + Vector2(1, 0), initialDelay)
    arena.meltPlayerTiles(bfsSource + Vector2(-1, 0), initialDelay)
    self.hide()

func shootPlayerSlime(cellPos, direction, amount):
    if(amount <= 0):
        return
    lineSource = cellPos
    lineDirection = direction
    lineAmount = amount
    arena.placeSlimeAt(cellPos * Globals.TILE_SIZE, Globals.PLAYER_SLIME)
    showPlayerSlime()
    find_node("SlimeLineTimer").start()

func _on_SlimeLineTimer_timeout():
    var cellPos = lineSource + lineDirection
    if(cellPos.x <= 0 or cellPos.x >= arena.gridWidth - 1 or cellPos.y <= 0 or cellPos.y >= arena.gridHeight - 1):
        return
    var tileIndex = arena.tileMap.get_cell(cellPos.x, cellPos.y)
    if(tileIndex == 0):
        var tileObject = arena.tileObjectGrid[cellPos.x][cellPos.y]
        if(tileObject == null):
            tileObject = arena.addTileObjectAt(cellPos)
        tileObject.shootPlayerSlime(cellPos, lineDirection, lineAmount - 1)
