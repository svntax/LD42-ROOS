extends Node

var TILE_SIZE = 32

var EMPTY_CELL = 0
var PLAYER_SLIME = 1
var RED_SLIME = 2
var VOID_CELL = 3

var score = 0
var highScore = 0

var gameOver

func _ready():
    gameOver = false
