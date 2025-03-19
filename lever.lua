-- lever.lua

local newCellObject = require "cell_object"

local newLeverRight = function (mapData, cellX, cellY, fn)
    local lever = newCellObject(mapData, cellX, cellY)
    lever.fn = fn
    
    lever.contact = function (this)
        this.fn("right")
    end
    return lever
end

local newLeverLeft = function (mapData, cellX, cellY, fn)
    local lever = newCellObject(mapData, cellX, cellY)
    lever.fn = fn
    
    lever.contact = function (this)
        this.fn("left")
    end
    return lever
end

return {
    newLeverLeft = newLeverLeft,
    newLeverRight = newLeverRight,
}
