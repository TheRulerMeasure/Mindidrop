-- game.lua

local gameConst = require "game_const"

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
end

local leverRightSwitch = function (game, x, y)
    game.blockerMap[y - 1][x - 1] = 0
    game.blockerMap[y - 1][x]     = gameConst.blockerRight
    game.blockerMap[y][x - 1]     = gameConst.leverLeft
    game.blockerMap[y][x]         = 0
end

local addCoinAtCell = function (game, cellX, cellY, amount)
    local a = math.floor(amount or 1)
    game.coinMap[cellY][cellX] = game.coinMap[cellY][cellX] + a
end

local coinMoveAndSetCellDown = function (game, coin, dirX)
    local dx = math.min(math.max(dirX or 0, -1), 1)
    dx = math.floor(dx)
    game:addCoinAtCell(coin.x, coin.y, -1)
    coin.x = coin.x + dx
    coin.y = coin.y + 1
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
        game:addCoinAtCell(coin.x, coin.y, -1) -- coinMap
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

local handleBlockerCoinCell = function (game, coin)
    local bCell = game.blockerMap[coin.y + 1][coin.x]
    if bCell == gameConst.blockerCoinLeft then
        game:coinMoveAndSetCellDown(coin, 1)
        return true
    end
    if bCell == gameConst.blockerCoinRight then
        game:coinMoveAndSetCellDown(coin, -1)
        return true
    end
    return false
end

local coinMoveDown = function (game, coin)
    local hasScored = game:handleScoreCell(coin)
    if hasScored then
        return "scored"
    end
    local hasBlocker = game:handleBlockerCell(coin)
    if hasBlocker then
        return "blocked"
    end
    local hasBlockerCoin = game:handleBlockerCoinCell(coin)
    if hasBlockerCoin then
        return "moved"
    end
    game:coinMoveAndSetCellDown(coin)
    return "moved"
end

local coinAllMoveDown = function (game)
    local indexesTBR = {}
    for i, v in ipairs(game.movingCoins) do
        local moveResult = game:coinMoveDown(v)
        if moveResult == "blocked" or moveResult == "scored" then
            table.insert(indexesTBR, i)
        end
    end
    if #indexesTBR > 0 then
        for i = #indexesTBR, 1, -1 do
            table.remove(game.movingCoins, indexesTBR[i])
        end
    end
    -- debug
    game:debugPrintCoinMap()
end

local insertCoin = function (game, slot)
    local clampedSlot = math.min(math.max(slot or 1, 1), 8)
    clampedSlot = math.floor(clampedSlot)
    local x = clampedSlot + 4
    local y = 1
    table.insert(game.movingCoins, { x = x, y = y })
    game:addCoinAtCell(x, y, 1)
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

return function ()
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
        
        update = update,
        draw = draw,
        keypressed = keypressed,
        
        addCoinAtCell = addCoinAtCell,
        insertCoin = insertCoin,
        coinAllMoveDown = coinAllMoveDown,
        coinMoveDown = coinMoveDown,
        coinMoveAndSetCellDown = coinMoveAndSetCellDown,
        handleScoreCell = handleScoreCell,
        handleBlockerCell = handleBlockerCell,
        handleBlockerCoinCell = handleBlockerCoinCell,
        leverLeftSwitch = leverLeftSwitch,
        leverRightSwitch = leverRightSwitch,
        
        debugPrintCoinMap = debugPrintCoinMap,
    }
end
