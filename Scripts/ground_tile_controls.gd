extends Node2D

var melting
var bfsSource
var initialDelay

var arena

func _ready():
    arena = get_tree().get_nodes_in_group("arenas")[0]
    melting = false
    bfsSource = null
    initialDelay = -1

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
