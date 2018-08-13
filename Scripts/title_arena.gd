extends TileMap

var redSlimeTrail = load("res://Scenes/red_slime_trail.tscn")
var redSlime = load("res://Scenes/title_enemy.tscn")

var tileMap
var grid #The 2D array representing the arena
var tileObjectGrid
var gridWidth
var gridHeight

func _ready():
    tileMap = self
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

func _process(delta):
    if(Input.is_action_just_pressed("THROW_SLIMEBALL") ):
        var targetPos = get_global_mouse_position()
        var sb = redSlime.instance()
        get_parent().add_child(sb)
        sb.translate(targetPos)
        sb.set_scale(Vector2(1.5, 1.5))

func placeRedSlimeAt(pos, globalPos, playSound = false):
    #Update the grid array
    var cellX = floor(pos.x / 48)
    var cellY = floor(pos.y / 48)
    if(cellX <= 0 or cellX >= gridWidth - 1 or cellY <= 0 or cellY >= gridHeight - 1):
        return
    if(grid[cellX][cellY] == Globals.EMPTY_CELL): #Do nothing if slime already exists
        grid[cellX][cellY] = Globals.RED_SLIME

        var slimeTrail = redSlimeTrail.instance()
        var tileSize = 48
        var nx = floor(globalPos.x / tileSize) * tileSize
        var ny = floor(globalPos.y / tileSize) * tileSize
        slimeTrail.translate(Vector2(nx, ny) + Vector2(24, 24))
        slimeTrail.set_scale(Vector2(3, 3))
        get_parent().add_child(slimeTrail)
        if(playSound):
            SoundHandler.slimeSound02.play()