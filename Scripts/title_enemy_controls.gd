extends KinematicBody2D

var moveSpeed = 32
var animationSpeed = 1

var animationPlayer
var movingSprite
var spawningTransition
var nextTargetPos

var titleArena

func _ready():
    titleArena = get_parent().get_parent().find_node("TitleArena")
    animationPlayer = find_node("AnimationPlayer")
    movingSprite = find_node("AnimatedSprite")
    spawningTransition = false
    #animationPlayer.play("spawnAnim", 1, 0.75, false)
    findNextTargetPos()
    find_node("MoveTimer").start()

func _process(delta):
    pass

func _physics_process(delta):
    if(not spawningTransition):
        var myPos = self.global_position
        var dist = nextTargetPos - myPos
        if dist.length() > 16:
            self.move_and_slide(dist.normalized() * 32)
            if(not animationPlayer.is_playing()):
                animationPlayer.play("movingAnim", 1, animationSpeed, false)
            var cx = floor(self.global_position.x / 48) * (48)
            var cy = floor(self.global_position.y / 48) * (48)
            titleArena.placeRedSlimeAt(Vector2(cx, cy), self.global_position)
        else:
            animationPlayer.stop(true)
            movingSprite.set_frame(0)

func _on_AnimationPlayer_animation_finished(anim_name):
    if(anim_name == "spawnAnim"):
        spawningTransition = false
        SoundHandler.splashSound02.play()

func findNextTargetPos():
    nextTargetPos = self.global_position + Vector2(randi() % 128 - 64, randi() % 128 - 64)

func _on_MoveTimer_timeout():
    findNextTargetPos()