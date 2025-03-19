-- cell_object.lua

local gameConst = require "game_const"

return function (mapData, cellX, cellY)
    return {
        mapData = mapData,
        cellX = cellX,
        cellY = cellY,
        
        getX = function (this)
            return gameConst.boardOffsetX + ( (this.cellX-1) * gameConst.cellWidth )
        end,
        
        getY = function (this)
            return gameConst.boardOffsetY + ( (this.cellY-1) * gameConst.cellHeight )
        end,
    }
end
