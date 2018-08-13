extends KinematicBody2D

export (int) var WALK_SPEED = 96

var slimeball = load("res://Scenes/slimeball.tscn")

var animationSpeed = 1.4
var fallingAnimationSpeed = 0.3
var meltSpeed = 0.4
var slimeLineLength = 5
var dashSpeed = 300

var walkVel = Vector2()

var movingSprite
var playerCamera
var animationPlayer

var health
var numEnemies
var falling
var dashing
var canShoot
var canDash
var directionFacing

var arena

func _ready():
    arena = get_tree().get_nodes_in_group("arenas")[0]
    movingSprite = find_node("AnimatedSprite")
    playerCamera = find_node("PlayerCamera")
    animationPlayer = find_node("AnimationPlayer")
    health = 6
    numEnemies = 0
    falling = false
    dashing = false
    canShoot = true
    canDash = true
    directionFacing = Vector2(1, 0)

func _process(delta):
    if(not falling and Input.is_action_pressed("PLACE_SLIME")):
        if(arena != null):
            var cx = floor(self.global_position.x / Globals.TILE_SIZE) * Globals.TILE_SIZE
            var cy = floor(self.global_position.y / Globals.TILE_SIZE) * Globals.TILE_SIZE
            arena.placeSlimeAt(Vector2(cx, cy), Globals.PLAYER_SLIME, true)
    """if(not falling and Input.is_action_just_pressed("MELT_TILE")):
        if(arena != null):
            var cellX = floor(self.global_position.x / Globals.TILE_SIZE)
            var cellY = floor(self.global_position.y / Globals.TILE_SIZE)
            arena.meltPlayerTiles(Vector2(cellX, cellY), meltSpeed)"""
    """if(not falling and Input.is_action_just_pressed("SHOOT_SLIME")):
        if(arena != null):
            var cellX = floor(self.global_position.x / Globals.TILE_SIZE)
            var cellY = floor(self.global_position.y / Globals.TILE_SIZE)
            var tileObject = arena.tileObjectGrid[cellX][cellY]
            if(tileObject == null):
                tileObject = arena.addTileObjectAt(Vector2(cellX, cellY))
            tileObject.shootPlayerSlime(Vector2(cellX, cellY), self.directionFacing, slimeLineLength)"""
    if(not falling and Input.is_action_just_pressed("THROW_SLIMEBALL") and canShoot):
        if(arena != null):
            canShoot = false
            SoundHandler.shootSound.play()
            find_node("ShootCooldown").start()
            var targetPos = get_global_mouse_position()
            var targetDir = targetPos - self.global_position
            var sb = slimeball.instance()
            get_parent().add_child(sb)
            sb.translate(self.position)
            sb.set_scale(Vector2(1.5, 1.5))
            sb.throwSlimeball(targetDir)
    if(not falling and not dashing and Input.is_action_just_pressed("DASH") and canDash):
        dashing = true
        canDash = false
        find_node("DashCooldown").start()
        self.set_collision_layer_bit(0, false)
        find_node("PlayerFallHitbox").set_collision_layer_bit(0, false)
        get_parent().find_node("DashTimer").start()
        animationPlayer.stop()
        movingSprite.set_frame(1)
        find_node("Trail").set_emitting(true)

func _physics_process(delta):
    walkVel.x = 0
    walkVel.y = 0
    if(not falling):
        if(dashing):
            self.move_and_slide(directionFacing.normalized() * dashSpeed)
            var cx = floor(self.global_position.x / Globals.TILE_SIZE) * Globals.TILE_SIZE
            var cy = floor(self.global_position.y / Globals.TILE_SIZE) * Globals.TILE_SIZE
            arena.placeSlimeAt(Vector2(cx, cy), Globals.PLAYER_SLIME, true)
        else:
            if(Input.is_action_pressed("MOVE_LEFT")):
                walkVel.x = -WALK_SPEED
            if(Input.is_action_pressed("MOVE_RIGHT")):
                walkVel.x = WALK_SPEED
            if(Input.is_action_pressed("MOVE_UP")):
                walkVel.y = -WALK_SPEED
            if(Input.is_action_pressed("MOVE_DOWN")):
                walkVel.y = WALK_SPEED
            if(walkVel.x != 0 or walkVel.y != 0):
                self.directionFacing = Vector2(sign(walkVel.x), sign(walkVel.y))
                if(not animationPlayer.is_playing()):
                    animationPlayer.play("movingAnim", 1, animationSpeed, false)
            else:
                animationPlayer.stop()
                movingSprite.set_frame(0)
            self.move_and_slide(walkVel)

func fallIntoTheVoid():
    self.falling = true
    find_node("Shadow").hide()
    SoundHandler.fallingSound.play()
    self.animationPlayer.play("fallingAnim", 1, fallingAnimationSpeed, false)

func _on_PlayerHitbox_body_entered(body):
    if(body.is_in_group("enemies")):
        if(numEnemies == 0):
            find_node("DamageTimer").start()
        numEnemies += 1
        damagePlayer()

func _on_PlayerFallHitbox_body_entered(body):
   if(body.get_name() == "TileMap" and not self.falling):
        self.fallIntoTheVoid()

func _on_PlayerHitbox_body_exited(body):
    if(body.is_in_group("enemies")):
        numEnemies -= 1
        if(numEnemies == 0):
            find_node("DamageTimer").stop()

func _on_DamageTimer_timeout():
    damagePlayer()
    
func damagePlayer():
    if(falling):
        return
    SoundHandler.hurtSound.play()
    health -= 1
    if(health <= 0):
        find_node("DamageTimer").stop()
        find_node("DamageFlashTimer").stop()
        self.killPlayer()
    else:
        self.set_modulate(Color(1, 0, 0, 1))
        find_node("DamageFlashTimer").start()

func killPlayer():
    self.hide()
    get_parent().get_parent().find_node("GameOverUI").showGameOverUI()

func _on_AnimationPlayer_animation_finished(anim_name):
    if(anim_name == "fallingAnim"):
        self.killPlayer()

func _on_DashTimer_timeout():
    dashing = false
    find_node("Trail").set_emitting(false)
    self.set_collision_layer_bit(0, true)
    find_node("PlayerFallHitbox").set_collision_layer_bit(0, true)

func _on_DamageFlashTimer_timeout():
    self.set_modulate(Color(1, 1, 1, 1))

func _on_ShootCooldown_timeout():
    canShoot = true

func _on_DashCooldown_timeout():
    canDash = true