-- game.lua
local gameAssets = require("game_assetloader")()
local gameConst = require("game_const")
local gameStates = require("game_states")

local gameStateProcs = require("game_state_processors")

local newAnimSprite = require("anim_sprite")

local newPlayerBox = require("player_box")
local newExpldNum = require("exploding_num")
local centerLabelClass = require("center_label")

local newBlockerSprite = function (img, cellX, cellY)
    local x = cellX * gameConst.cellWidth
    x = x + gameConst.boardOffsetX
    local y = cellY * gameConst.cellHeight
    y = y + gameConst.boardOffsetY
    return {
        sprite = newAnimSprite(img, x, y, {
            sliceX = 5,
            sliceY = 1,
            anims = {
                ["block_left"] = {
                    minFrame = 1,
                    maxFrame = 5,
                    forward = false,
                    speed = 16,
                },
                ["block_right"] = {
                    minFrame = 1,
                    maxFrame = 5,
                    forward = true,
                    speed = 16,
                },
            },
        }),
        x = cellX,
        y = cellY,
    }
end

local newCoinSprite = function (img, cellX, cellY)
    local x = cellX * gameConst.cellWidth
    x = x + gameConst.boardOffsetX
    local y = cellY * gameConst.cellHeight
    y = y + gameConst.boardOffsetY
    local coin = {}
    coin.sprite = newAnimSprite(img, x, y, { sliceX = 1, sliceY = 1 })
    coin.x = cellX
    coin.y = cellY
    return coin
end

local newArrowSprite = function (img, slot)
    local x = slot + 4
    x = x * gameConst.cellWidth
    x = x + gameConst.boardOffsetX
    x = x - 12
    local y = gameConst.boardOffsetY
    local sprite = newAnimSprite(img, x, y, {
        sliceX = 2,
        sliceY = 1,
        anims = {
            ["dance"] = {
                minFrame = 1,
                maxFrame = 2,
                forward = true,
                speed = 15,
            },
        },
    })
    sprite:play("dance")
    return sprite
end

local newMoveResult = function (result, cellToInsertCoin)
    return {
        result = result,
        cellToInsertCoin = cellToInsertCoin,
    }
end

local debugPrintCoinMap = function (game)
    print("----coin map-----")
    for y = 1, #game.coinMap do
        local row = ""
        for x = 1, #game.coinMap[y] do
            row = row .. game.coinMap[y][x]
        end
        print(row)
    end
    print("----coin map-----")
end

local changeToNextPlayer = function (game)
    game.curPlayerIndex = game.curPlayerIndex + 1
    if game.curPlayerIndex > gameConst.maxPlayersCount then
        game.curPlayerIndex = 1
    end
end

local blockerBlockLeft = function (game, x, y)
    game.blockerMap[y][x]         = gameConst.blockerLeft
    game.blockerMap[y][x + 1]     = 0
    game.blockerMap[y + 1][x]     = 0
    game.blockerMap[y + 1][x + 1] = gameConst.leverRight
    game:setBlockerSpBlockLeft(x, y)
    love.audio.play(game.leverSound)
end

local blockerBlockRight = function (game, x, y)
    game.blockerMap[y][x]         = 0
    game.blockerMap[y][x + 1]     = gameConst.blockerRight
    game.blockerMap[y + 1][x]     = gameConst.leverLeft
    game.blockerMap[y + 1][x + 1] = 0
    game:setBlockerSpBlockRight(x, y)
    love.audio.play(game.leverSound)
end

local leverLeftSwitch = function (game, x, y)
    game:blockerBlockLeft(x, y - 1)
    
    if game.blockerMap[y - 2][x + 1] == gameConst.blockerCoinRight then
        game.blockerMap[y - 2][x + 1] = 0
        local cellToInsertCoin = { x = x + 1, y = y - 3 }
        return cellToInsertCoin
    end
    return nil
end

local leverRightSwitch = function (game, x, y)
    game:blockerBlockRight(x - 1, y - 1)
    
    if game.blockerMap[y - 2][x - 1] == gameConst.blockerCoinLeft then
        game.blockerMap[y - 2][x - 1] = 0
        local cellToInsertCoin = { x = x - 1, y = y - 3 }
        return cellToInsertCoin
    end
    return nil
end

local moveInsertSlot = function (game, dx)
    local dx2 = math.min(math.max(dx or 1, -1), 1)
    dx2 = math.floor(dx2)
    local slot = game.curInsertSlot
    slot = slot + dx2
    slot = math.min(math.max(slot, 1), 8)
    game.curInsertSlot = slot
    local x = (game.curInsertSlot + 4) * gameConst.cellWidth
    x = x + gameConst.boardOffsetX
    game.arrowSprite.x = x - 12
    game.arrowSprite:play("dance")
end

local scoredAtSlot = function (game, slot)
    local amount = game.scoreMulSlots[slot].number
    game.players[game.curPlayerIndex].scores = game.players[game.curPlayerIndex].scores + amount
    game.players[game.curPlayerIndex].totalScores = game.players[game.curPlayerIndex].totalScores + amount
    game.playerBoxes[game.curPlayerIndex]:setProgress(game.players[game.curPlayerIndex].scores)
    game.playerBoxes[game.curPlayerIndex]:setNumProgress(game.curRoundIndex, game.players[game.curPlayerIndex].scores)
    love.audio.play(game.coinScoreSound)
end

local addCoinAtCell = function (game, cellX, cellY, amount)
    local a = math.floor(amount or 1)
    game.coinMap[cellY][cellX] = game.coinMap[cellY][cellX] + a
end

local coinMoveAndSetCell = function (game, coin, dx, dy)
    local dx2 = math.floor(dx or 0)
    local dy2 = math.floor(dy or 0)
    game:addCoinAtCell(coin.x, coin.y, -1)
    coin.x = coin.x + dx2
    coin.y = coin.y + dy2
    game:addCoinAtCell(coin.x, coin.y, 1)
end

local handleScoreCell = function (game, coin)
    if coin.y + 1 > gameConst.mapHeight then
        game:addCoinAtCell(coin.x, coin.y, -1)
        return true
    end
    return false
end

local handleBlockerCell = function (game, coin)
    local bCell = game.blockerMap[coin.y + 1][coin.x]
    if bCell == gameConst.blockerLeft then
        game:addCoinAtCell(coin.x, coin.y, -1)
        game.blockerMap[coin.y][coin.x] = gameConst.blockerCoinLeft
        love.audio.play(game.coinHitSound)
        return true
    end
    if bCell == gameConst.blockerRight then
        game:addCoinAtCell(coin.x, coin.y, -1)
        game.blockerMap[coin.y][coin.x] = gameConst.blockerCoinRight
        love.audio.play(game.coinHitSound)
        return true
    end
    return false
end

local handleLeverCell = function (game, coin)
    local bCell = game.blockerMap[coin.y + 1][coin.x]
    if bCell == gameConst.leverLeft then
        local cellToInsertCoin = game:leverLeftSwitch(coin.x, coin.y + 1)
        return cellToInsertCoin
    end
    if bCell == gameConst.leverRight then
        local cellToInsertCoin = game:leverRightSwitch(coin.x, coin.y + 1)
        return cellToInsertCoin
    end
    return nil
end

local handleBlockerCoinCell = function (game, coin)
    local curCell = game.blockerMap[coin.y][coin.x]
    if curCell == gameConst.blockerCoinLeft then
        game:coinMoveAndSetCell(coin, 1, 0)
        love.audio.play(game.coinHitSound)
        return true
    end
    if curCell == gameConst.blockerCoinRight then
        game:coinMoveAndSetCell(coin, -1, 0)
        love.audio.play(game.coinHitSound)
        return true
    end
    local bCell = game.blockerMap[coin.y + 1][coin.x]
    if bCell == gameConst.blockerCoinLeft then
        game:coinMoveAndSetCell(coin, 1, 1)
        love.audio.play(game.coinHitSound)
        return true
    end
    if bCell == gameConst.blockerCoinRight then
        game:coinMoveAndSetCell(coin, -1, 1)
        love.audio.play(game.coinHitSound)
        return true
    end
    return false
end

local coinMoveDown = function (game, coin)
    local hasScored = game:handleScoreCell(coin)
    if hasScored then
        return newMoveResult("scored", nil)
    end
    local hasBlockerCoin = game:handleBlockerCoinCell(coin)
    if hasBlockerCoin then
        return newMoveResult("moved", nil)
    end
    local hasBlocker = game:handleBlockerCell(coin)
    if hasBlocker then
        return newMoveResult("blocked", nil)
    end
    local cellToInsertCoin = game:handleLeverCell(coin)
    game:coinMoveAndSetCell(coin, 0, 1)
    return newMoveResult("moved", cellToInsertCoin)
end

local coinAllMoveDown = function (game)
    local indexesTBR = {}
    local coinsToBeInserted = {}
    for i, v in ipairs(game.movingCoins) do
        local moveResult = game:coinMoveDown(v)
        if moveResult.result == "blocked" then
            table.insert(indexesTBR, i)
        elseif moveResult.result == "scored" then
            table.insert(indexesTBR, i)
            game:scoredAtSlot(v.x)
        else
            if moveResult.cellToInsertCoin then
                table.insert(coinsToBeInserted, moveResult.cellToInsertCoin)
            end
        end
    end
    if #indexesTBR > 0 then
        for i = #indexesTBR, 1, -1 do
            table.remove(game.movingCoins, indexesTBR[i])
        end
    end
    for i, v in ipairs(coinsToBeInserted) do
        game:insertCoin(v.x, v.y)
    end
    -- debug
    -- game:debugPrintCoinMap()
    return #game.movingCoins > 0
end

local insertCoin = function (game, cellX, cellY)
    local x = math.floor(cellX)
    local y = math.floor(cellY)
    local coin = newCoinSprite(game.coinAsset, x, y)
    table.insert(game.movingCoins, coin)
    game:addCoinAtCell(x, y, 1)
end

local insertCoinFromSlot = function (game, slot)
    local clampedSlot = math.min(math.max(slot or 1, 1), 8)
    clampedSlot = math.floor(clampedSlot)
    local x = clampedSlot + 4
    local y = 1
    game:insertCoin(x, y)
end

local getBlockerSpriteAtCell = function (game, cellX, cellY)
    local row
    if cellY == 4 then
        row = game.blockerSprites[1]
    elseif cellY == 8 then
        row = game.blockerSprites[2]
    elseif cellY == 12 then
        row = game.blockerSprites[3]
    elseif cellY == 16 then
        row = game.blockerSprites[4]
    elseif cellY == 20 then
        row = game.blockerSprites[5]
    end
    
    for i, v in ipairs(row) do
        if v.x == cellX then
            return v.sprite
        end
    end
    return nil
end

local setBlockerSpBlockLeft = function (game, cellX, cellY)
    local sprite = game:getBlockerSpriteAtCell(cellX, cellY)
    if not sprite then
        print("Error: blocker sprite does not exist at " .. cellX .. ", " .. cellY)
        return
    end
    sprite:play("block_left")
end

local setBlockerSpBlockRight = function (game, cellX, cellY)
    local sprite = game:getBlockerSpriteAtCell(cellX, cellY)
    if not sprite then
        print("Error: blocker sprite does not exist at " .. cellX .. ", " .. cellY)
        return
    end
    sprite:play("block_right")
end

local drawBlocker = function (blockerType, cellX, cellY, coinAsset)
    if blockerType ~= gameConst.blockerCoinLeft and blockerType ~= gameConst.blockerCoinRight then
        return
    end
    local x, y
    x = gameConst.boardOffsetX
    x = x + (cellX-1) * gameConst.cellWidth
    y = gameConst.boardOffsetY
    y = y + (cellY-1) * gameConst.cellHeight

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(coinAsset, x, y)
end

local drawCoin = function (coin)
    love.graphics.setColor(1, 1, 1)
    coin.sprite.x = gameConst.boardOffsetX + coin.x * gameConst.cellWidth - 12
    coin.sprite.y = gameConst.boardOffsetY + coin.y * gameConst.cellHeight - 12
    coin.sprite:draw()
end

local drawBlockerSpritesRow = function (row)
    for i, v in ipairs(row) do
        love.graphics.setColor(1, 1, 1)
        v.sprite:draw()
    end
end

local update = function (game, dt)
    local newState = gameStateProcs(game, dt)
    game.curState = newState

    game.arrowSprite:update(dt)
    game.centerLabel:update(dt)
    for i, row in ipairs(game.blockerSprites) do
        for j, v in ipairs(row) do
            v.sprite:update(dt)
        end
    end
    for i, v in ipairs(game.scoreMulSlots) do
        v:update(dt)
    end
    return game.gameOver
end

local draw = function (game)
    local boardX, boardY
    boardX = gameConst.boardOffsetX - 24
    boardY = gameConst.boardOffsetY - 24
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(game.boardSprite.back, boardX, boardY)
    for y = 1, gameConst.mapHeight do
        for x = 1, gameConst.mapWidth do
            drawBlocker(game.blockerMap[y][x], x, y, game.coinAsset)
        end
    end
    for i, v in ipairs(game.blockerSprites) do
        drawBlockerSpritesRow(v)
    end
    for i, v in ipairs(game.movingCoins) do
        drawCoin(v)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(game.boardSprite.front, boardX, boardY)
    game.arrowSprite:draw()
    game.centerLabel:draw()
    for i, v in ipairs(game.playerBoxes) do
        v:draw()
    end
    for i, v in ipairs(game.scoreMulSlots) do
        v:draw()
    end
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.print("press [P] to go back to main menu.", 137, 763)
    if #game.stateLabel > 0 then
        -- love.graphics.setColor(0.1, 0.1, 0.1)
        local labelX = gameConst.windowWidth * 0.5
        labelX = labelX - #game.stateLabel * 4
        love.graphics.print(game.stateLabel, labelX, 10)
    end
end

local keypressed = function (game, key, scancode)
    if scancode == 'a' or scancode == "left" then
        game:moveInsertSlot(-1)
        return
    end
    if scancode == 'd' or scancode == "right" then
        game:moveInsertSlot(1)
        return
    end
    if scancode == "down" or key == "space" or scancode == "return" or scancode == 's' then
        if #game.movingCoins <= 0 and (game.curState == gameStates.playerWaiting or game.curState == gameStates.playerWaitingRoundEnding) then
            if not game.players[game.curPlayerIndex].isCPU then
                game:insertCoinFromSlot(game.curInsertSlot)
            end
        end
        return
    end
    if scancode == 'p' and not game.gameOver then
        game.gameOver = true
    end
end

return function (withCPU)
    local blockersRow1 = {}
    for i = 1, 4 do
        local cellX = 5
        cellX = cellX + (i-1) * 2
        local cellY = 4
        table.insert(blockersRow1, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow2 = {}
    for i = 1, 5 do
        local cellX = 4
        cellX = cellX + (i-1) * 2
        local cellY = 8
        table.insert(blockersRow2, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow3 = {}
    for i = 1, 6 do
        local cellX = 3
        cellX = cellX + (i-1) * 2
        local cellY = 12
        table.insert(blockersRow3, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow4 = {}
    for i = 1, 7 do
        local cellX = 2
        cellX = cellX + (i-1) * 2
        local cellY = 16
        table.insert(blockersRow4, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow5 = {}
    for i = 1, 8 do
        local cellX = 1
        cellX = cellX + (i-1) * 2
        local cellY = 20
        table.insert(blockersRow5, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local scoreMulSlots = {}
    for i = 1, gameConst.mapWidth do
        local coordX, coordY
        coordX = (i-1) * gameConst.cellWidth
        coordX = coordX + gameConst.boardOffsetX + 14
        coordY = gameConst.boardOffsetY + gameConst.cellHeight * gameConst.mapHeight - 10
        table.insert(scoreMulSlots, newExpldNum(gameAssets["boom_sheet"], gameAssets["explosion"], coordX, coordY))
    end
    
    return {
        blockerMap = {
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 4, 0, 4, 0, 4, 0, 4, 0, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, },
            { 0, 0, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, },
            { 0, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, },
            { 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, 0, 4, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
        },
        
        coinMap = {
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
        },
        
        movingCoins = {},
        
        blockerSprites = {
            blockersRow1,
            blockersRow2,
            blockersRow3,
            blockersRow4,
            blockersRow5,
        },
        
        centerLabel = centerLabelClass.new(gameAssets["label_sheet"]),
        
        players = {
            {
                isCPU = false,
                scores = 0,
                totalScores = 0,
                victories = 0,
            },
            {
                isCPU = withCPU,
                scores = 0,
                totalScores = 0,
                victories = 0,
            },
        },
        
        playerBoxes = {
            newPlayerBox(gameAssets["bubv_sheet"],
                            gameAssets["mindi_tower_sheet"],
                            gameAssets["mindi_pgbar_bg"],
                            gameAssets["mindi_pgbar_over"],
                            gameConst.windowWidth * 0.12 - 48, 180,
                            1),
            newPlayerBox(gameAssets["bubv_sheet"],
                            gameAssets["mindi_tower_sheet"],
                            gameAssets["mindi_pgbar_bg"],
                            gameAssets["mindi_pgbar_over"],
                            gameConst.windowWidth * 0.88 - 48, 180,
                            2),
        },
        
        curPlayerIndex = 1,
        
        curInsertSlot = 1,
        
        scoreMulSlots = scoreMulSlots,
        
        curRoundIndex = 1,
        
        arrowSprite = newArrowSprite(gameAssets["insert_arrow_sheet"], 1),
        
        curState = gameStates.beginning,
        
        stateLabel = "",
        
        maxDelayBeforeNextStep = 0.06,
        maxDelayBeforeNextShuffle = 0.07,
        
        stepDelay = 0.0,
        
        shuffledBlockerAmount = 0,
        
        updatedScoreMulAmount = 0,
        
        gameOver = false,
        
        coinAsset = gameAssets["coin"],
        boardSprite = {
            back = gameAssets["board_back"],
            front = gameAssets["board_front"],
        },
        
        coinHitSound = gameAssets["coin_hit_coin"],
        coinScoreSound = gameAssets["coin_scored"],
        leverSound = gameAssets["lever_move"],
        roundBeginSound = gameAssets["round_begin"],
        gameEndSound = gameAssets["game_end"],
        
        update = update,
        draw = draw,
        keypressed = keypressed,
        
        moveInsertSlot = moveInsertSlot,
        
        addCoinAtCell = addCoinAtCell,
        insertCoinFromSlot = insertCoinFromSlot,
        insertCoin = insertCoin,
        
        getBlockerSpriteAtCell = getBlockerSpriteAtCell,
        setBlockerSpBlockLeft = setBlockerSpBlockLeft,
        setBlockerSpBlockRight = setBlockerSpBlockRight,
        
        coinAllMoveDown = coinAllMoveDown,
        coinMoveDown = coinMoveDown,
        coinMoveAndSetCell = coinMoveAndSetCell,
        handleScoreCell = handleScoreCell,
        handleBlockerCell = handleBlockerCell,
        handleBlockerCoinCell = handleBlockerCoinCell,
        handleLeverCell = handleLeverCell,
        
        blockerBlockLeft = blockerBlockLeft,
        blockerBlockRight = blockerBlockRight,
        leverLeftSwitch = leverLeftSwitch,
        leverRightSwitch = leverRightSwitch,
        
        scoredAtSlot = scoredAtSlot,
        
        changeToNextPlayer = changeToNextPlayer,
        
        debugPrintCoinMap = debugPrintCoinMap,
    }
end
