-- player_box.lua
local gameConst = require("game_const")
local newSprite = require("sprite")

local boxWidth = 4
local boxHeight = 6


local newPlBox = function (patchImg, mindiImg, pgbarBg, pgbarOver, x, y, plIndex)
    local box = {}
    box.x = x or 0
    box.y = y or 0
    box.mapWidth = boxWidth
    box.mapHeight = boxHeight
    
    box.playerIndex = plIndex or 1
    
    box.maxProgress = 12
    box.progress = 0
    
    box.progresses = {
        { progress = 0, maxProgress = 0 },
        { progress = 0, maxProgress = 0 },
        { progress = 0, maxProgress = 0 },
        { progress = 0, maxProgress = 0 },
    }
    
    local progbarX = x + 80
    box.mindiSprite = newSprite(mindiImg, progbarX, y + 104, {
        sliceX = 10,
        sliceY = 1,
    })
    box.pgbarBg = newSprite(pgbarBg, progbarX, y + 104, {
        sliceX = 1, sliceY = 1,
    })
    box.pgbarOver = newSprite(pgbarOver, progbarX, y + 104, {
        sliceX = 1, sliceY = 1,
    })
    
    box.mindiSprite.frame = 1
    
    box.patchSprites = {}
    
    for row = 1, boxHeight do
        local spRow = {}
        for column = 1, boxWidth do
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
            elseif column == boxWidth and row == 1 then
                patchSprite.frame = 3
            elseif column == 1 and row == boxHeight then
                patchSprite.frame = 7
            elseif column == boxWidth and row == boxHeight then
                patchSprite.frame = 9
            elseif column == 1 then
                patchSprite.frame = 4
            elseif row == 1 then
                patchSprite.frame = 2
            elseif column == boxWidth then
                patchSprite.frame = 6
            elseif row == boxHeight then
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
        for i, v in ipairs(this.progresses) do
            if v.maxProgress > 0 then
                local coordX, coordY
                coordX = this.x - 10
                coordY = this.y + 32 * i
                love.graphics.print(v.progress .. "/" .. v.maxProgress, coordX, coordY)
            end
        end
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
    
    box.setMaxNumProgress = function (this, n, maxProg)
        this.progresses[n].maxProgress = maxProg 
    end
    
    box.setNumProgress = function (this, n, progress)
        this.progresses[n].progress = progress
    end
    
    return box
end

return newPlBox
