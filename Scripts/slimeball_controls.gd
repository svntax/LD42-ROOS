extends KinematicBody2D

var splat
var hitbox
var moveVel

var arena

func _ready():
    arena = get_tree().get_nodes_in_group("arenas")[0]
    splat = false
    hitbox = find_node("SlimeHitbox")
    moveVel = Vector2(0, 0)

func _physics_process(delta):
    self.move_and_slide(moveVel)
    if(splat):
        for body in hitbox.get_overlapping_bodies():
            if(body.is_in_group("enemies")):
                body.killSlime()
        self.queue_free()

func hitGround():
    moveVel = Vector2(0, 0)
    var cx = floor(self.global_position.x / Globals.TILE_SIZE)
    var cy = floor(self.global_position.y / Globals.TILE_SIZE)
    for i in range(-1, 2):
        for j in range(-1, 2):
            if(i * j != 0):
                if(randf() > 0.5):
                    arena.placeSlimeAt(Vector2(cx + i, cy + j) * Globals.TILE_SIZE, Globals.PLAYER_SLIME)
            else:
                arena.placeSlimeAt(Vector2(cx + i, cy + j) * Globals.TILE_SIZE, Globals.PLAYER_SLIME)
    splat = true

func throwSlimeball(vel):
    find_node("AnimationPlayer").play("throwAnim")
    moveVel = vel

func _on_AnimationPlayer_animation_finished(anim_name):
    self.hitGround()
