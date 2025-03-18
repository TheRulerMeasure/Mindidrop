-- game.lua

local gameConst = require "game_const"

local newAnimSprite = require "anim_sprite"

local newBlockerSprite = function (img, cellX, cellY)
    local x = cellX * gameConst.cellWidth
    x = x + 26
    local y = cellY * gameConst.cellHeight
    y = y + 26
    return newAnimSprite(img, x, y, {
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
                speed = 16,
            },
        },
    })
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
    
    game:BlockerCellLeftBlocked(y - 1, x)
    
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
    
    game:BlockerCellLeftUnblocked(y - 1, x - 1)
    
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

local update = function (game, dt)
    
end

local draw = function (game)
    for y = 1, gameConst.mapHeight do
        for x = 1, gameConst.mapWidth do
            drawBlocker(game.blockerMap[y][x], x, y)
        end
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
    local blockers = {}
    for i = 1, 4 do
        local cellX = 5
        cellX = cellX + (i-1)
        local cellY = 4
        table.insert(blockers, {
            sprite = newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY),
        })
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
        
        steps = -1,
        
        update = update,
        draw = draw,
        keypressed = keypressed,
        
        addCoinAtCell = addCoinAtCell,
        insertCoinFromSlot = insertCoinFromSlot,
        insertCoin = insertCoin,
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
