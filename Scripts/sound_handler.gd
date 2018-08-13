extends Node

var hurtSound
var shootSound
var splashSound
var splashSound02
var slimeSound
var slimeSound02
var fallingSound
var fallingSound02

func _ready():
    hurtSound = find_node("HurtSound")
    shootSound = find_node("ShootSound")
    splashSound = find_node("SplashSound")
    splashSound02 = find_node("SplashSound02")
    slimeSound = find_node("SlimeSound")
    slimeSound02 = find_node("SlimeSound02")
    fallingSound = find_node("FallingSound")
    fallingSound02 = find_node("FallingSound02")