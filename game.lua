-- game.lua

local gameConst = require "game_const"

local newAnimSprite = require "anim_sprite"

local newBlockerSprite = function (img, cellX, cellY)
    local x = cellX * gameConst.cellWidth
    x = x + 26
    local y = cellY * gameConst.cellHeight
    y = y + 26
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
        cellX = cellX,
        cellY = cellY,
    }
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

local leverLeftSwitch = function (game, x, y)
    game.blockerMap[y - 1][x]     = gameConst.blockerLeft
    game.blockerMap[y - 1][x + 1] = 0
    game.blockerMap[y][x]         = 0
    game.blockerMap[y][x + 1]     = gameConst.leverRight
    
    game:setBlockerSpBlockLeft(x, y - 1)
    
    if game.blockerMap[y - 2][x + 1] == gameConst.blockerCoinRight then
        game.blockerMap[y - 2][x + 1] = 0
        local cellToInsertCoin = { x = x + 1, y = y - 3 }
        return cellToInsertCoin
    end
    return nil
end

local leverRightSwitch = function (game, x, y)
    game.blockerMap[y - 1][x - 1] = 0
    game.blockerMap[y - 1][x]     = gameConst.blockerRight
    game.blockerMap[y][x - 1]     = gameConst.leverLeft
    game.blockerMap[y][x]         = 0
    
    game:setBlockerSpBlockRight(x - 1, y - 1)
    
    if game.blockerMap[y - 2][x - 1] == gameConst.blockerCoinLeft then
        game.blockerMap[y - 2][x - 1] = 0
        local cellToInsertCoin = { x = x - 1, y = y - 3 }
        return cellToInsertCoin
    end
    return nil
end

local scoredAtSlot = function (game, slot)
    print("scored at slot " .. slot)
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
        return true
    end
    if bCell == gameConst.blockerRight then
        game:addCoinAtCell(coin.x, coin.y, -1)
        game.blockerMap[coin.y][coin.x] = gameConst.blockerCoinRight
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
        return true
    end
    if curCell == gameConst.blockerCoinRight then
        game:coinMoveAndSetCell(coin, -1, 0)
        return true
    end
    local bCell = game.blockerMap[coin.y + 1][coin.x]
    if bCell == gameConst.blockerCoinLeft then
        game:coinMoveAndSetCell(coin, 1, 1)
        return true
    end
    if bCell == gameConst.blockerCoinRight then
        game:coinMoveAndSetCell(coin, -1, 1)
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
end

local insertCoin = function (game, cellX, cellY)
    local x = math.floor(cellX)
    local y = math.floor(cellY)
    table.insert(game.movingCoins, { x = x, y = y })
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
        if v.cellX == cellX then
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

local drawBlocker = function (blockerType, cellX, cellY)
    local x, y
    x = gameConst.boardOffsetX
    x = x + (cellX-1) * gameConst.cellWidth
    y = gameConst.boardOffsetY
    y = y + (cellY-1) * gameConst.cellHeight

    if blockerType <= 0 then
        return
    end

    if blockerType == gameConst.blockerLeft then
        love.graphics.setColor(0.5, 0.1, 0.1)
    elseif blockerType == gameConst.blockerRight then
        love.graphics.setColor(0.1, 0.5, 0.1)
    elseif blockerType == gameConst.leverLeft then
        love.graphics.setColor(0.1, 0.1, 0.5)
    elseif blockerType == gameConst.leverRight then
        love.graphics.setColor(0.5, 0.1, 0.5)
    elseif blockerType == gameConst.blockerCoinLeft then
        love.graphics.setColor(0.4, 0.4, 0.4)
    elseif blockerType == gameConst.blockerCoinRight then
        love.graphics.setColor(0.8, 0.8, 0.8)
    end

    love.graphics.rectangle("fill", x, y, gameConst.cellWidth, gameConst.cellHeight)
end

local drawCoin = function (coin)
    local width, height = gameConst.cellWidth, gameConst.cellHeight
    local x, y
    x = gameConst.boardOffsetX
    x = x + (coin.x-1) * width
    y = gameConst.boardOffsetY
    y = y + (coin.y-1) * height
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", x, y, width, height)
end

local drawBlockerSpritesRow = function (row)
    for i, v in ipairs(row) do
        love.graphics.setColor(1, 1, 1)
        v.sprite:draw()
    end
end

local update = function (game, dt)
    for i, row in ipairs(game.blockerSprites) do
        for j, v in ipairs(row) do
            v.sprite:update(dt)
        end
    end
end

local draw = function (game)
    for y = 1, gameConst.mapHeight do
        for x = 1, gameConst.mapWidth do
            drawBlocker(game.blockerMap[y][x], x, y)
        end
    end
    for i, v in ipairs(game.blockerSprites) do
        drawBlockerSpritesRow(v)
    end
    for i, v in ipairs(game.movingCoins) do
        drawCoin(v)
    end
end

local keypressed = function (game, key, scancode)
    if scancode == 's' then
        game:coinAllMoveDown()
    end
end

return function (gameAssets)
    local blockersRow1 = {}
    for i = 1, 4 do
        local cellX = 5
        cellX = cellX + (i-1)
        local cellY = 4
        table.insert(blockersRow1, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow2 = {}
    for i = 1, 5 do
        local cellX = 4
        cellX = cellX + (i-1)
        local cellY = 8
        table.insert(blockersRow2, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow3 = {}
    for i = 1, 6 do
        local cellX = 3
        cellX = cellX + (i-1)
        local cellY = 12
        table.insert(blockersRow3, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow4 = {}
    for i = 1, 7 do
        local cellX = 2
        cellX = cellX + (i-1)
        local cellY = 16
        table.insert(blockersRow4, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    local blockersRow5 = {}
    for i = 1, 8 do
        local cellX = 1
        cellX = cellX + (i-1)
        local cellY = 20
        table.insert(blockersRow5, newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
    end
    
    return {
        blockerMap = {
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 1, 0, 0, 2, 1, 0, 0, 2, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, 0, 0, 0, },
            { 0, 0, 0, 3, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 1, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, 0, 0, },
            { 0, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, 0, },
            { 0, 3, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, },

            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, },
            { 1, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, },
            { 0, 4, 3, 0, 0, 4, 3, 0, 0, 4, 3, 0, 0, 4, 3, 0, },

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
        
        steps = -1,
        
        update = update,
        draw = draw,
        keypressed = keypressed,
        
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
        leverLeftSwitch = leverLeftSwitch,
        leverRightSwitch = leverRightSwitch,
        scoredAtSlot = scoredAtSlot,
        
        debugPrintCoinMap = debugPrintCoinMap,
    }
end
