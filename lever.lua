-- lever.lua

local gameConst = require "game_const"

local newCellObject = require "cell_object"

local newLeverRight = function (mapData, cellX, cellY, active)
    local lever = newCellObject(mapData, cellX, cellY)
    lever.active = active
    
    lever.draw = function (this)
        if not this.active then return end
        love.graphics.setColor(0, 0, 0.6)
        love.graphics.rectangle("fill", this:getX(), this:getY(), gameConst.cellWidth, gameConst.cellHeight)
    end
    
    return lever
end

local newLeverLeft = function (mapData, cellX, cellY, active)
    local lever = newCellObject(mapData, cellX, cellY)
    lever.active = active
    
    lever.draw = function (this)
        if not this.active then return end
        love.graphics.setColor(0.6, 0.6, 0)
        love.graphics.rectangle("fill", this:getX(), this:getY(), gameConst.cellWidth, gameConst.cellHeight)
    end
    
    return lever
end

return {
    newLeverLeft = newLeverLeft,
    newLeverRight = newLeverRight,
}
