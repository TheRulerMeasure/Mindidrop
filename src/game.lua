-- self.lua
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

local debugPrintCoinMap = function (self)
    print("----coin map-----")
    for y = 1, #self.coinMap do
        local row = ""
        for x = 1, #self.coinMap[y] do
            row = row .. self.coinMap[y][x]
        end
        print(row)
    end
    print("----coin map-----")
end

local changeToNextPlayer = function (self)
    self.curPlayerIndex = self.curPlayerIndex + 1
    if self.curPlayerIndex > gameConst.maxPlayersCount then
        self.curPlayerIndex = 1
    end
end

local blockerBlockLeft = function (self, x, y)
    self.blockerMap[y][x]         = gameConst.blockerLeft
    self.blockerMap[y][x + 1]     = 0
    self.blockerMap[y + 1][x]     = 0
    self.blockerMap[y + 1][x + 1] = gameConst.leverRight
    self:setBlockerSpBlockLeft(x, y)
    love.audio.play(self.leverSound)
end

local blockerBlockRight = function (self, x, y)
    self.blockerMap[y][x]         = 0
    self.blockerMap[y][x + 1]     = gameConst.blockerRight
    self.blockerMap[y + 1][x]     = gameConst.leverLeft
    self.blockerMap[y + 1][x + 1] = 0
    self:setBlockerSpBlockRight(x, y)
    love.audio.play(self.leverSound)
end

local leverLeftSwitch = function (self, x, y)
    self:blockerBlockLeft(x, y - 1)
    
    if self.blockerMap[y - 2][x + 1] == gameConst.blockerCoinRight then
        self.blockerMap[y - 2][x + 1] = 0
        local cellToInsertCoin = { x = x + 1, y = y - 3 }
        return cellToInsertCoin
    end
    return nil
end

local leverRightSwitch = function (self, x, y)
    self:blockerBlockRight(x - 1, y - 1)
    
    if self.blockerMap[y - 2][x - 1] == gameConst.blockerCoinLeft then
        self.blockerMap[y - 2][x - 1] = 0
        local cellToInsertCoin = { x = x - 1, y = y - 3 }
        return cellToInsertCoin
    end
    return nil
end

local moveInsertSlot = function (self, dx)
    local dx2 = math.min(math.max(dx or 1, -1), 1)
    dx2 = math.floor(dx2)
    local slot = self.curInsertSlot
    slot = slot + dx2
    slot = math.min(math.max(slot, 1), 8)
    self.curInsertSlot = slot
    local x = (self.curInsertSlot + 4) * gameConst.cellWidth
    x = x + gameConst.boardOffsetX
    self.arrowSprite.x = x - 12
    self.arrowSprite:play("dance")
end

local scoredAtSlot = function (self, slot)
    local amount = self.scoreMulSlots[slot].number
    self.players[self.curPlayerIndex].scores = self.players[self.curPlayerIndex].scores + amount
    self.players[self.curPlayerIndex].totalScores = self.players[self.curPlayerIndex].totalScores + amount
    self.playerBoxes[self.curPlayerIndex]:setProgress(self.players[self.curPlayerIndex].scores)
    self.playerBoxes[self.curPlayerIndex]:setNumProgress(self.curRoundIndex, self.players[self.curPlayerIndex].scores)
    love.audio.play(self.coinScoreSound)
end

local addCoinAtCell = function (self, cellX, cellY, amount)
    local a = math.floor(amount or 1)
    self.coinMap[cellY][cellX] = self.coinMap[cellY][cellX] + a
end

local coinMoveAndSetCell = function (self, coin, dx, dy)
    local dx2 = math.floor(dx or 0)
    local dy2 = math.floor(dy or 0)
    self:addCoinAtCell(coin.x, coin.y, -1)
    coin.x = coin.x + dx2
    coin.y = coin.y + dy2
    self:addCoinAtCell(coin.x, coin.y, 1)
end

local handleScoreCell = function (self, coin)
    if coin.y + 1 > gameConst.mapHeight then
        self:addCoinAtCell(coin.x, coin.y, -1)
        return true
    end
    return false
end

local handleBlockerCell = function (self, coin)
    local nextCell = self.blockerMap[coin.y + 1][coin.x]
    if nextCell == gameConst.blockerLeft then
        self:addCoinAtCell(coin.x, coin.y, -1)
        self.blockerMap[coin.y][coin.x] = gameConst.blockerCoinLeft
        love.audio.play(self.coinHitSound)
        return true
    end
    if nextCell == gameConst.blockerRight then
        self:addCoinAtCell(coin.x, coin.y, -1)
        self.blockerMap[coin.y][coin.x] = gameConst.blockerCoinRight
        love.audio.play(self.coinHitSound)
        return true
    end
    return false
end

local handleLeverCell = function (self, coin)
    local nextCell = self.blockerMap[coin.y + 1][coin.x]
    if nextCell == gameConst.leverLeft then
        local cellToInsertCoin = self:leverLeftSwitch(coin.x, coin.y + 1)
        return cellToInsertCoin
    end
    if nextCell == gameConst.leverRight then
        local cellToInsertCoin = self:leverRightSwitch(coin.x, coin.y + 1)
        return cellToInsertCoin
    end
    return nil
end

-- this function checks if we are hitting a blocker in the current cell or the next cel, if so- it plays a sound & exits.
local handleBlockerCoinCell = function (self, coin)
    local curCell = self.blockerMap[coin.y][coin.x]
    local nextCell = self.blockerMap[coin.y + 1][coin.x]
    local newPos = nil
    
    if curCell == gameConst.blockerCoinLeft then
        newPos = {1,0};
    elseif curCell == gameConst.blockerCoinRight then
        newPos = {-1,0};
    elseif nextCell == gameConst.blockerCoinLeft then
        newPos = {1,1};
    elseif nextCell == gameConst.blockerCoinRight then
        newPos = {-1,1};
    end

    if newPos ~= nil then
        -- the coin collided with a blocker, stop it and play a sound.
        self:coinMoveAndSetCell(coin, newPos[1], newPos[2])
        love.audio.play(self.coinHitSound)
        return true
    end

    -- the coin passed through without getting blocked
    return false
end

local coinMoveDown = function (self, coin)
    local hasScored = self:handleScoreCell(coin)
    if hasScored then
        return newMoveResult("scored", nil)
    end
    local hasBlockerCoin = self:handleBlockerCoinCell(coin)
    if hasBlockerCoin then
        return newMoveResult("moved", nil)
    end
    local hasBlocker = self:handleBlockerCell(coin)
    if hasBlocker then
        return newMoveResult("blocked", nil)
    end
    local cellToInsertCoin = self:handleLeverCell(coin)
    self:coinMoveAndSetCell(coin, 0, 1)
    return newMoveResult("moved", cellToInsertCoin)
end

local coinAllMoveDown = function (self)
    local indexesTBR = {}
    local coinsToBeInserted = {}
    for i, v in ipairs(self.movingCoins) do
        local moveResult = self:coinMoveDown(v)
        if moveResult.result == "blocked" then
            table.insert(indexesTBR, i)
        elseif moveResult.result == "scored" then
            table.insert(indexesTBR, i)
            self:scoredAtSlot(v.x)
        else
            if moveResult.cellToInsertCoin then
                table.insert(coinsToBeInserted, moveResult.cellToInsertCoin)
            end
        end
    end
    if #indexesTBR > 0 then
        for i = #indexesTBR, 1, -1 do
            table.remove(self.movingCoins, indexesTBR[i])
        end
    end
    for i, v in ipairs(coinsToBeInserted) do
        self:insertCoin(v.x, v.y)
    end
    -- debug
    -- self:debugPrintCoinMap()
    return #self.movingCoins > 0
end

local insertCoin = function (self, cellX, cellY)
    local x = math.floor(cellX)
    local y = math.floor(cellY)
    local coin = newCoinSprite(self.coinAsset, x, y)
    table.insert(self.movingCoins, coin)
    self:addCoinAtCell(x, y, 1)
end

local insertCoinFromSlot = function (self, slot)
    local clampedSlot = math.min(math.max(slot or 1, 1), 8)
    clampedSlot = math.floor(clampedSlot)
    local x = clampedSlot + 4
    local y = 1
    self:insertCoin(x, y)
end

local getBlockerSpriteAtCell = function (self, cellX, cellY)
    local row
    if cellY == 4 then
        row = self.blockerSprites[1]
    elseif cellY == 8 then
        row = self.blockerSprites[2]
    elseif cellY == 12 then
        row = self.blockerSprites[3]
    elseif cellY == 16 then
        row = self.blockerSprites[4]
    elseif cellY == 20 then
        row = self.blockerSprites[5]
    end
    
    for i, v in ipairs(row) do
        if v.x == cellX then
            return v.sprite
        end
    end
    return nil
end

local setBlockerSpBlockLeft = function (self, cellX, cellY)
    local sprite = self:getBlockerSpriteAtCell(cellX, cellY)
    if not sprite then
        print("Error: blocker sprite does not exist at " .. cellX .. ", " .. cellY)
        return
    end
    sprite:play("block_left")
end

local setBlockerSpBlockRight = function (self, cellX, cellY)
    local sprite = self:getBlockerSpriteAtCell(cellX, cellY)
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

local update = function (self, dt)
    local newState = gameStateProcs(self, dt)
    self.curState = newState

    self.arrowSprite:update(dt)
    self.centerLabel:update(dt)
    for i, row in ipairs(self.blockerSprites) do
        for j, v in ipairs(row) do
            v.sprite:update(dt)
        end
    end
    for i, v in ipairs(self.scoreMulSlots) do
        v:update(dt)
    end
    return self.gameOver
end

local draw = function (self)
    local boardX, boardY
    boardX = gameConst.boardOffsetX - 24
    boardY = gameConst.boardOffsetY - 24
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.boardSprite.back, boardX, boardY)
    for y = 1, gameConst.mapHeight do
        for x = 1, gameConst.mapWidth do
            drawBlocker(self.blockerMap[y][x], x, y, self.coinAsset)
        end
    end
    for i, v in ipairs(self.blockerSprites) do
        drawBlockerSpritesRow(v)
    end
    for i, v in ipairs(self.movingCoins) do
        drawCoin(v)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.boardSprite.front, boardX, boardY)
    self.arrowSprite:draw()
    self.centerLabel:draw()
    for i, v in ipairs(self.playerBoxes) do
        v:draw()
    end
    for i, v in ipairs(self.scoreMulSlots) do
        v:draw()
    end
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.print("press [P] to go back to main menu.", 137, 763)
    if #self.stateLabel > 0 then
        -- love.graphics.setColor(0.1, 0.1, 0.1)
        local labelX = gameConst.windowWidth * 0.5
        labelX = labelX - #self.stateLabel * 4
        love.graphics.print(self.stateLabel, labelX, 10)
    end
end

local keypressed = function (self, key, scancode)
    if scancode == 'a' or scancode == "left" then
        self:moveInsertSlot(-1)
        return
    end
    if scancode == 'd' or scancode == "right" then
        self:moveInsertSlot(1)
        return
    end
    if scancode == "down" or key == "space" or scancode == "return" or scancode == 's' then
        if #self.movingCoins <= 0 and (self.curState == gameStates.playerWaiting or self.curState == gameStates.playerWaitingRoundEnding) then
            if not self.players[self.curPlayerIndex].isCPU then
                self:insertCoinFromSlot(self.curInsertSlot)
            end
        end
        return
    end
    if scancode == 'p' and not self.gameOver then
        self.gameOver = true
    end
end

local blockerGenerator = function()
    -- these are the rows of blockers
    -- each blocker takes 4 cells (topleft, topright, bottomleft, bottomright)
    -- and the cellX, cellY is the topleft
   
    local baseCellX = 5
    local baseCellY = 4

    local blockerRows = {
        {},{},{},{},{}
    }

    for j = 1, #blockerRows do
        for i = 1, 3 + j do
            local cellX = baseCellX
            cellX = cellX + (i-1) * 2
            local cellY = baseCellY
            table.insert(blockerRows[j], newBlockerSprite(gameAssets["blocker_sheet"], cellX, cellY))
        end
        -- prepare for next row
        baseCellX = baseCellX - 1
        baseCellY = baseCellY + 4
    end

    return blockerRows
end

return function (withCPU)    
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
        
        blockerSprites = blockerGenerator(),
        
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
