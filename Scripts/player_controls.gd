extends KinematicBody2D

export (int) var WALK_SPEED = 96
var animationSpeed = 1.4

var walkVel = Vector2()

var movingSprite
var playerCamera
var animationPlayer

var health
var numEnemies

var arena

func _ready():
    arena = get_tree().get_nodes_in_group("arenas")[0]
    movingSprite = find_node("AnimatedSprite")
    playerCamera = find_node("PlayerCamera")
    animationPlayer = find_node("AnimationPlayer")
    health = 8
    numEnemies = 0

func _process(delta):
    if(Input.is_action_pressed("PLACE_SLIME")):
        if(arena != null):
            var cx = floor(self.global_position.x / Globals.TILE_SIZE) * Globals.TILE_SIZE
            var cy = floor(self.global_position.y / Globals.TILE_SIZE) * Globals.TILE_SIZE
            arena.placeSlimeAt(Vector2(cx, cy), Globals.PLAYER_SLIME)
        else:
            print("ERROR: arena node not found")

func _physics_process(delta):
    walkVel.x = 0
    walkVel.y = 0
    
    if(Input.is_action_pressed("MOVE_LEFT")):
        walkVel.x = -WALK_SPEED
    if(Input.is_action_pressed("MOVE_RIGHT")):
        walkVel.x = WALK_SPEED
    if(Input.is_action_pressed("MOVE_UP")):
        walkVel.y = -WALK_SPEED
    if(Input.is_action_pressed("MOVE_DOWN")):
        walkVel.y = WALK_SPEED

    if(walkVel.x != 0 or walkVel.y != 0):
        if(not animationPlayer.is_playing()):
            animationPlayer.play("movingAnim", 1, animationSpeed, false)
    else:
        animationPlayer.stop()
        movingSprite.set_frame(0)

    self.move_and_slide(walkVel)

func _on_PlayerHitbox_body_entered(body):
    if(body.is_in_group("enemies")):
        if(numEnemies == 0):
            find_node("DamageTimer").start()
        numEnemies += 1
        damagePlayer()

func _on_PlayerHitbox_body_exited(body):
    if(body.is_in_group("enemies")):
        numEnemies -= 1
        if(numEnemies == 0):
            find_node("DamageTimer").stop()

func _on_DamageTimer_timeout():
    damagePlayer()
    
func damagePlayer():
    health -= 1
    print("Player hurt")
    if(health <= 0):
        find_node("DamageTimer").stop()
        print("Game over")
