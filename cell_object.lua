-- cell_object.lua

-- local newEventHandler = require "event_handler"

return function (mapData, cellX, cellY)
    return {
        mapData = mapData,
        cellX = cellX,
        cellY = cellY,
        -- eventHandler = newEventHandler(),
    }
end
