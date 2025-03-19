-- blocker.lua

local gameConst = require "game_const"

local newCellObject = require "cell_object"

local newBlockerRight = function (mapData, cellX, cellY, active)
    local blocker = newCellObject(mapData, cellX, cellY)
    blocker.active = active
    
    blocker.draw = function (this)
        if not this.active then return end
        love.graphics.setColor(0.6, 0, 0)
        love.graphics.rectangle("fill", this:getX(), this:getY(), gameConst.cellWidth, gameConst.cellHeight)
    end
    return blocker
end

local newBlockerLeft = function (mapData, cellX, cellY, active)
    local blocker = newCellObject(mapData, cellX, cellY)
    blocker.active = active
    
    blocker.draw = function (this)
        if not this.active then return end
        love.graphics.setColor(0, 0.6, 0)
        love.graphics.rectangle("fill", this:getX(), this:getY(), gameConst.cellWidth, gameConst.cellHeight)
    end
    return blocker
end

return {
    newBlockerLeft = newBlockerLeft,
    newBlockerRight = newBlockerRight,
}
