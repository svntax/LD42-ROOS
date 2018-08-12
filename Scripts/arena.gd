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
            if(x <= 1 or x >= gridWidth - 2 or y <= 2 or y >= gridHeight - 3):
                tileObjectGrid[x][y] = null
                grid[x][y] = Globals.VOID_CELL
            else:
                var tempTile = groundTile.instance()
                tempTile.translate(Vector2(x, y) * Globals.TILE_SIZE + Vector2(16, 16))
                tempTile.set_scale(Vector2(2, 2))
                add_child(tempTile)
                tileObjectGrid[x][y] = tempTile
            #tileObjectGrid[x][y] = null
            

func checkValidSlimeType(type):
    return type == Globals.PLAYER_SLIME or type == Globals.RED_SLIME

func placeSlimeAt(pos, type):
    if(not checkValidSlimeType(type)):
        print("ERROR: Invalid slime type")
        return

    #Update the grid array
    var cellX = floor(pos.x / Globals.TILE_SIZE)
    var cellY = floor(pos.y / Globals.TILE_SIZE)
    if(grid[cellX][cellY] == type): #Do nothing if same slime already exists
        return
    if(grid[cellX][cellY] == Globals.VOID_CELL):
        return
    grid[cellX][cellY] = type

    #If the actual tile object already exists, just change its sprite
    #Else instantiate a new tile object
    var tileObject = tileObjectGrid[cellX][cellY]
    if(tileObject != null):
        if(type == Globals.PLAYER_SLIME):
            tileObject.showPlayerSlime()
        elif(type == Globals.RED_SLIME):
            tileObject.showRedSlime()
    else:
        var tempTile = groundTile.instance()
        tempTile.translate(pos + Vector2(16, 16))
        tempTile.set_scale(Vector2(2, 2))
        if(type == Globals.PLAYER_SLIME):
            tempTile.showPlayerSlime()
        elif(type == Globals.RED_SLIME):
            tempTile.showRedSlime()
        add_child(tempTile)
        tileObjectGrid[cellX][cellY] = tileObject

func meltPlayerTiles(cellPos, delay):
    if(cellPos.x <= 0 or cellPos.x >= gridWidth - 1 or cellPos.y <= 0 or cellPos.y >= gridHeight - 1):
        return
    var tileStatus = grid[cellPos.x][cellPos.y]
    var tileIndex = tileMap.get_cell(cellPos.x, cellPos.y)
    if(tileStatus == Globals.EMPTY_CELL and tileIndex == 0):
        var tileObject = tileObjectGrid[cellPos.x][cellPos.y]
        if(tileObject == null):
            tileObject = groundTile.instance()
            tileObject.translate((cellPos * Globals.TILE_SIZE) + Vector2(16, 16))
            tileObject.set_scale(Vector2(2, 2))
            add_child(tileObject)
            tileObjectGrid[cellPos.x][cellPos.y] = tileObject
            if(tileMap.get_cell(cellPos.x, cellPos.y) == 0):
                tileMap.set_cell(cellPos.x, cellPos.y, -1)
        if(not tileObject.isMelting()):
            tileObject.startMelting(delay, cellPos)
            delay += 1

func meltTileAt(cellPos):
    if(cellPos.x <= 0 or cellPos.x >= gridWidth - 1 or cellPos.y <= 0 or cellPos.y >= gridHeight - 1):
        return
    if(tileMap.get_cell(cellPos.x, cellPos.y) <= 0):
        tileMap.set_cell(cellPos.x, cellPos.y, 3)

func addTileObjectAt(cellPos):
    var tileObject = groundTile.instance()
    tileObject.translate((cellPos * Globals.TILE_SIZE) + Vector2(16, 16))
    tileObject.set_scale(Vector2(2, 2))
    add_child(tileObject)
    tileObjectGrid[cellPos.x][cellPos.y] = tileObject
    return tileObject