extends KinematicBody2D

var playerRootNode

var AGGRO_RANGE = 256
var moveSpeed = 32
var animationSpeed = 1

var animationPlayer
var movingSprite

var arena

func _ready():
    arena = get_tree().get_nodes_in_group("arenas")[0]
    playerRootNode = get_tree().get_nodes_in_group("players")[0]
    animationPlayer = find_node("AnimationPlayer")
    movingSprite = find_node("AnimatedSprite")

func _process(delta):
    pass

func _physics_process(delta):
    var playerPos = playerRootNode.find_node("PlayerKinematicBody").global_position
    var myPos = self.global_position;
    var dist = playerPos - myPos
    if dist.length() < AGGRO_RANGE:
        self.move_and_slide(dist.normalized() * 32)
        if(not animationPlayer.is_playing()):
            animationPlayer.play("movingAnim", 1, animationSpeed, false)
        
        var cx = floor(self.global_position.x / Globals.TILE_SIZE) * Globals.TILE_SIZE
        var cy = floor(self.global_position.y / Globals.TILE_SIZE) * Globals.TILE_SIZE
        arena.placeSlimeAt(Vector2(cx, cy), Globals.RED_SLIME)
    else:
        animationPlayer.stop(true)
        movingSprite.set_frame(0)

func killSlime():
    self.queue_free()
