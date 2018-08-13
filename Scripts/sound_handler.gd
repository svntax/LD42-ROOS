extends Node

var hurtSound
var shootSound
var splashSound
var slimeSound
var fallingSound
var fallingSound02

func _ready():
    hurtSound = find_node("HurtSound")
    shootSound = find_node("ShootSound")
    splashSound = find_node("SplashSound")
    slimeSound = find_node("SlimeSound")
    fallingSound = find_node("FallingSound")
    fallingSound02 = find_node("FallingSound02")