# Hintergrund für das erste Level
_level1 =["    #####          "
         ,"    #   #          "
         ,"    #   #          "
         ,"  ###   ##         "
         ,"  #      #         "
         ,"### # ## #   ######"
         ,"#   # ## #####    #"
         ,"#                 #"
         ,"##### ### # ##    #"
         ,"    #     #########"
         ,"    #######        "]


# Positionierung der Elemente
_player_l1   = {x: 8, y: 6}
_player_winning_l1   = {x: 14, y: 6}
_bombs_l1    = [[5,2],[5,4],[7,3],[7,4],[2,7],[5,7]]
_bombs_el1    = [[16,6],[16,7],[16,8],[17,6],[2,7],[5,7]]
_bombs_winning_l1 =  [[15,6],[16,7],[16,8],[17,6],[17,7],[17,8]]
_defusors_l1 = [[16,6],[16,7],[16,8],[17,6],[17,7],[17,8]]

tileSheet = null
gameState = START

# Initialisierung, Key Mapping

START = 1
PLAYING = 2
WON = 3

UP                 = 38
DOWN               = 40
LEFT               = 37
RIGHT              = 39
SPACE_BAR          = 32

FLOOR   = ' '
WALL    = '#'
PLAYER  = 5

_player = {x: 2, y: 1}
_bombs   =  [[2,1]]
_easyMap =  [[3,3,3,3,3,3]
           ,[3,1,1,1,1,3]
           ,[3,1,1,1,1,3]
           ,[3,1,1,1,1,3]
           ,[3,3,3,3,3,3]]

# Objekte werden definiert

testBoard = {background: _easyMap, bombs: _bombs, player: _player}
level1 = {background: _level1, defusors: _defusors_l1, bombs: _bombs_l1, player: _player_l1}
winner = {background: _level1, defusors: _defusors_l1, bombs: _bombs_winning_l1, player: _player_winning_l1}
easy_level1 = {background: _level1, defusors: _defusors_l1, bombs: _bombs_el1, player: _player_l1}
board = level1
board = easy_level1

# Ressources werden geladen

canvas = document.querySelector("canvas")
ctx = canvas.getContext("2d")

loadImages = ->
    tileSheet = new Image()
    tileSheet.src = "ressources/timeBombPanic.png"
    tileSheet.onload = (event) ->
        gameState = PLAYING
        canvas.backgroundColor = "blue"
        drawGame board

loadImages()

# Funktionen & Listener

window.onkeydown = (e) ->
    newBoard = calculateMove board, e.keyCode
    drawGame newBoard
    if compare newBoard.bombs, newBoard.defusors
        drawGameOver()
    else
        board = newBoard

clone = (obj) ->
  return obj  if obj is null or typeof (obj) isnt "object"
  temp = new obj.constructor()
  for key of obj
    temp[key] = clone(obj[key])
  temp

compare = (arr1, arr2) ->
    arr1.sort()
    arr2.sort()
    return "#{arr1}" is "#{arr2}"

getNewPos =  (map, key) ->
    newPos       = clone map.player
    nextToNewPos = clone map.player

    if key is LEFT
        newPos.x -= 1
        nextToNewPos.x -= 2
    else if key is RIGHT
        newPos.x += 1
        nextToNewPos.x += 2
    else if key is DOWN
        newPos.y += 1
        nextToNewPos.y += 2
    else if key is UP
        newPos.y -= 1
        nextToNewPos.y -= 2
    else
        # skip
    return [newPos, nextToNewPos]

calculateMove = (board, key) ->
    [newPos, nextToNewPos] = getNewPos board, key

    if isWall board.background, newPos 
        # don't move
    else if (isBomb board.bombs, newPos)
        if isMovableBomb board, newPos, nextToNewPos
            newBombs  = moveBomb board.bombs, newPos, nextToNewPos
            newPlayer = movePlayer board.player, newPos
            board.player = clone newPlayer
            board.bombs  = clone newBombs
            console.log "isMovableBomb"
        else if isUnMovableBomb board, newPos, nextToNewPos
            # don't move
        else 
            # don't move
    else 
        newPlayer = movePlayer board, newPos
        board.player = clone newPlayer
        console.log "else"
    return board

movePlayer = (player, pos) ->
    player.x = pos.x
    player.y = pos.y
    return player

moveBomb = (bombs, oldPos, newPos) ->
    _bombIndex = bombIndex bombs, oldPos
    bombs[_bombIndex][0] = newPos.x
    bombs[_bombIndex][1] = newPos.y
    return bombs

isMovableBomb = (board, newPos, nextToNewPos) -> 
    _newPosIsBomb = isBomb board.bombs, newPos
    _nextPosIsFree = isFree board, nextToNewPos
    return _newPosIsBomb and _nextPosIsFree

isUnMovableBomb = (board, newPos, nextToNewPos) -> 
    _newPosIsBomb  = isBomb board.bombs, newPos
    _nextPosIsBomb = isBomb board.bombs, nextToNewPos
    _nextPosIsWall = isWall board.background, nextToNewPos
    return _newPosIsBomb and (_nextPosIsBomb or _nextPosIsWall)

isFree =  (board, pos) ->
    _isNoWall = not (isWall board.background, pos)
    _isNoBomb = not (isBomb board.bombs, pos)
    return _isNoWall and _isNoBomb

isBomb = (bombs, pos) ->
    _bombIndex = bombIndex bombs, pos
    console.log _bombIndex
    return _bombIndex > -1

isWall = (background, pos) ->
    return background[pos.y][pos.x] is WALL

bombIndex = (bombs, pos) ->
    for bomb, i in bombs
        if bomb[0] is pos.x and bomb[1] is pos.y
            return i
    return -1

# Zeichnet das Spiel

drawGame = (board) ->
    drawBackground board.background
    drawDefusors board.defusors
    drawBombs board.bombs
    drawPlayer board.player

drawBackground = (background) ->
    ctx.clearRect 0, 0, canvas.width, canvas.height
    for line, i in background
        for element, j in line
            if element is WALL
                drawWall j*64, i*64
            else if element is FLOOR
                drawFloor j*64, i*64

drawBombs = (bombs) ->
    for bomb in bombs
        drawBomb bomb[0] * 64, bomb[1] * 64

drawDefusors = (defusors) ->
    for defusor in defusors
        drawDefusor defusor[0] * 64, defusor[1] * 64

drawPlayer = (player) ->
   x = player.x * 64
   y = player.y * 64
   ctx.drawImage tileSheet, 192, 0, 64, 64, x, y, 64, 64 

drawFloor = (x,y) ->
  ctx.drawImage tileSheet, 0, 0, 64, 64, x, y, 64, 64
drawWall = (x,y) ->
  ctx.drawImage tileSheet, 128, 0, 64, 64, x, y, 64, 64
drawBomb = (x,y) ->
  ctx.drawImage tileSheet, 256, 0, 64, 64, x + 15, y + 15, 64, 64
drawDefusor = (x,y) ->
  ctx.drawImage tileSheet, 64, 0, 64, 64, x, y, 64, 64
drawGameOver = ->
    posx = 1280 / 2 - 316 / 2
    posy = 768  / 2 - 290 / 2 
    ctx.drawImage tileSheet, 0, 129, 316, 290, posx, posy, 316, 290
    ctx.fillStyle = "black";
    ctx.font = "bold 30px Helvetica";
    ctx.fillText("You won!", 555, 425)
