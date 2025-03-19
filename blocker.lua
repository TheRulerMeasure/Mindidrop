-- blocker.lua

local newCellObject = require "cell_object"

local newBlockerRight = function (mapData, cellX, cellY)
    local blocker = newCellObject(mapData, cellX, cellY)
    
    return blocker
end

return {
    newBlockerLeft = newBlockerLeft,
    newBlockerRight = newBlockerRight,
}
