-- mindi.lua

local gameConst = require "game_const"

local newCellObject = require "cell_object"

local newMindi = function (mapData, cellX, cellY)
    local mindi = newCellObject(mapData, cellX, cellY)
    
    mindi.draw = function (this)
        love.graphics.setColor(1.0, 1.0, 0)
        local x, y
        x = this:getX() + gameConst.cellWidth * 0.5
        y = this:getY() + gameConst.cellHeight * 0.5
        love.graphics.circle("fill", x, y, gameConst.cellWidth * 0.5)
    end
    return mindi
end

return newMindi
