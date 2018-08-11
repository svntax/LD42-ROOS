extends Node2D

var groundTile = load("res://Scenes/ground_tile.tscn")

var tileMap
var grid #The 2D array representing the arena
var tileObjectGrid
var gridWidth
var gridHeight

func _ready():
    tileMap = find_node("TileMap")
    grid = []
    gridWidth = tileMap.get_used_rect().size.x
    gridHeight = tileMap.get_used_rect().size.y
    for x in range(gridWidth):
        grid.append([])
        grid[x] = []
        for y in range(gridHeight):
            grid[x].append([])
            grid[x][y] = Globals.EMPTY_CELL
    
    tileObjectGrid = []
    for x in range(gridWidth):
        tileObjectGrid.append([])
        tileObjectGrid[x] = []
        for y in range(gridHeight):
            tileObjectGrid[x].append([])
            tileObjectGrid[x][y] = null

func checkValidSlimeType(type):
    return type == Globals.EMPTY_CELL or type == Globals.PLAYER_SLIME or type == Globals.RED_SLIME

func placeSlimeAt(pos, type):
    if(not checkValidSlimeType(type)):
        print("ERROR: Invalid slime type")
        return

    #Update the grid array
    var cellX = floor(pos.x / Globals.TILE_SIZE)
    var cellY = floor(pos.y / Globals.TILE_SIZE)
    if(grid[cellX][cellY] == type): #Do nothing if same slime already exists
        return
    grid[cellX][cellY] = type

    #If the actual tile object already exists, just change its sprite
    #Else instantiate a new tile object
    if(tileObjectGrid[cellX][cellY] != null):
        if(type == Globals.PLAYER_SLIME):
            tileObjectGrid[cellX][cellY].find_node("PlayerSlime").show()
    else:
        var tempTile = groundTile.instance()
        tempTile.translate(pos + Vector2(16, 16))
        tempTile.set_scale(Vector2(2, 2))
        if(type == Globals.PLAYER_SLIME):
            tempTile.find_node("PlayerSlime").show()
        add_child(tempTile)
