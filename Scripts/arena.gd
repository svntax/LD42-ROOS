extends Node2D

var groundTile = load("res://Scenes/ground_tile.tscn")
var redSlime = load("res://Scenes/enemy.tscn")

var tileMap
var grid #The 2D array representing the arena
var tileObjectGrid
var gridWidth
var gridHeight
var nextTilePos
var nextRedSlimePos
var numFreeTilesLeft
var totalFreeTiles

func _ready():
    tileMap = find_node("TileMap")
    nextTilePos = null
    nextRedSlimePos = null
    numFreeTilesLeft = 0
    totalFreeTiles = 0
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
                numFreeTilesLeft += 1
                totalFreeTiles += 1
            #tileObjectGrid[x][y] = null
    getNextTileToDrop()
    find_node("DropTileTimer").start()
    find_node("RedSlimeTimer").start()

func _process(delta):
    #print(str(numFreeTilesLeft) + " / " + str(totalFreeTiles))
    if(numFreeTilesLeft <= 0):
        var playerSlimeCount = 0
        for i in range(gridWidth):
            for j in range(gridHeight):
                if(grid[i][j] == Globals.PLAYER_SLIME):
                    playerSlimeCount += 1.0
        """print("Player slime count: " + str(playerSlimeCount))
        print("Total free tiles: " + str(totalFreeTiles))
        print("Ratio: " + str(playerSlimeCount / totalFreeTiles))
        print("Percent: " + str((playerSlimeCount / totalFreeTiles) * 100))
        print("Adjusted percent: " + str(stepify((playerSlimeCount / totalFreeTiles), 0.01) * 100))"""
        Globals.score = stepify((playerSlimeCount / totalFreeTiles), 0.01) * 100
        get_parent().find_node("GameOverUI").showGameWinUI()

func checkValidSlimeType(type):
    return type == Globals.EMPTY_CELL or type == Globals.PLAYER_SLIME or type == Globals.RED_SLIME

func placeSlimeAt(pos, type, playSound = false):
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
        if(tileObject.is_visible()):
            if(type == Globals.PLAYER_SLIME):
                tileObject.showPlayerSlime()
                if(playSound):
                    SoundHandler.slimeSound.play()
            elif(type == Globals.RED_SLIME):
                tileObject.showRedSlime()
                SoundHandler.slimeSound02.play()
            elif(type == Globals.EMPTY_CELL):
                tileObject.hideSlime()
    else:
        var tempTile = groundTile.instance()
        tempTile.translate(pos + Vector2(16, 16))
        tempTile.set_scale(Vector2(2, 2))
        if(type == Globals.PLAYER_SLIME):
            tempTile.showPlayerSlime()
            if(playSound):
                SoundHandler.slimeSound.play()
        elif(type == Globals.RED_SLIME):
            tempTile.showRedSlime()
            SoundHandler.slimeSound02.play()
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
        var tileObject = tileObjectGrid[cellPos.x][cellPos.y]
        if(tileObject != null and not tileObject.isSlimed and grid[cellPos.x][cellPos.y] == Globals.EMPTY_CELL):
            numFreeTilesLeft -= 1

func addTileObjectAt(cellPos):
    var tileObject = groundTile.instance()
    tileObject.translate((cellPos * Globals.TILE_SIZE) + Vector2(16, 16))
    tileObject.set_scale(Vector2(2, 2))
    add_child(tileObject)
    tileObjectGrid[cellPos.x][cellPos.y] = tileObject
    return tileObject

func getNextTileToDrop():
    var tilePositions = []
    for x in range(gridWidth):
        for y in range(gridHeight):
            if(grid[x][y] == Globals.EMPTY_CELL):
                tilePositions.append(Vector2(x, y))
    if(tilePositions.size() > 0):
        var posIndex = randi() % tilePositions.size()
        nextTilePos = tilePositions[posIndex]
        var tileObj = tileObjectGrid[nextTilePos.x][nextTilePos.y]
        tileObj.find_node("AnimationPlayer").play("shakeAnim")
    else:
        print("No more empty cells")

func spawnRedSlime():
    var tilePositions = []
    for x in range(gridWidth):
        for y in range(gridHeight):
            if(grid[x][y] == Globals.EMPTY_CELL or grid[x][y] == Globals.RED_SLIME):
                var tileObject = tileObjectGrid[x][y]
                if(tileObject != null and tileMap.get_cell(x, y) == 0):
                    tilePositions.append(Vector2(x, y))
    if(tilePositions.size() > 0):
        var posIndex = randi() % tilePositions.size()
        nextRedSlimePos = tilePositions[posIndex]
        var slime = redSlime.instance()
        get_parent().add_child(slime)
        slime.translate(nextRedSlimePos * Globals.TILE_SIZE)
    else:
        print("All tiles are blue slime")

func _on_DropTileTimer_timeout():
    #placeSlimeAt(Vector2(4, 4) * Globals.TILE_SIZE, Globals.EMPTY_CELL)
    placeSlimeAt(nextTilePos * Globals.TILE_SIZE, Globals.EMPTY_CELL)
    meltPlayerTiles(nextTilePos, 0.4)
    getNextTileToDrop()

func _on_RedSlimeTimer_timeout():
    spawnRedSlime()
