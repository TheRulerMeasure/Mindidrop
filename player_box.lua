-- player_box.lua

local gameConst = require "game_const"

local newSprite = require "sprite"

local newPlBox = function (patchImg, mindiImg, pgbarBg, pgbarOver, x, y, plIndex)
    local box = {}
    box.x = x or 0
    box.y = y or 0
    box.mapWidth = 3
    box.mapHeight = 6
    
    box.playerIndex = plIndex or 1
    
    box.maxProgress = 12
    box.progress = 0
    
    box.mindiSprite = newSprite(mindiImg, x + 57, y + 104, {
        sliceX = 10,
        sliceY = 1,
    })
    box.pgbarBg = newSprite(pgbarBg, x + 57, y + 104, {
        sliceX = 1, sliceY = 1,
    })
    box.pgbarOver = newSprite(pgbarOver, x + 57, y + 104, {
        sliceX = 1, sliceY = 1,
    })
    
    box.mindiSprite.frame = 1
    
    box.patchSprites = {}
    
    for row = 1, 6 do
        local spRow = {}
        for column = 1, 3 do
            local spX, spY
            spX = (column-1) * 32
            spX = spX + x
            spY = (row-1) * 32
            spY = spY + y
            local patchSprite = newSprite(patchImg, spX, spY, {
                sliceX = 3,
                sliceY = 3,
            })
            if column == 1 and row == 1 then
                patchSprite.frame = 1
            elseif column == 3 and row == 1 then
                patchSprite.frame = 3
            elseif column == 1 and row == 6 then
                patchSprite.frame = 7
            elseif column == 3 and row == 6 then
                patchSprite.frame = 9
            elseif column == 1 then
                patchSprite.frame = 4
            elseif row == 1 then
                patchSprite.frame = 2
            elseif column == 3 then
                patchSprite.frame = 6
            elseif row == 6 then
                patchSprite.frame = 8
            else
                patchSprite.frame = 5
            end
            table.insert(spRow, patchSprite)
        end
        table.insert(box.patchSprites, spRow)
    end
    
    box.draw = function (this)
        love.graphics.setColor(1, 1, 1)
        for row = 1, this.mapHeight do
            for column = 1, this.mapWidth do
                this.patchSprites[row][column]:draw()
            end
        end
        love.graphics.setColor(0.12, 0.12, 0.12)
        love.graphics.print("Player " .. this.playerIndex, this.x - 10, this.y - 6)
        love.graphics.setColor(1, 1, 1)
        this.pgbarBg:draw()
        this.mindiSprite:draw()
        this.pgbarOver:draw()
    end
    
    box.setProgress = function (this, progress)
        this.progress = progress
        local prog = (this.maxProgress - this.progress) / this.maxProgress
        prog = 1 - prog
        local frame = math.floor(prog * 10)
        frame = math.min(math.max(frame, 1), 10)
        this.mindiSprite.frame = frame
    end
    
    return box
end

return newPlBox
