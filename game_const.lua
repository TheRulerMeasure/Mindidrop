-- game_const.lua

local windowWidth = 600

local mapWidth = 16
local cellWidth = 24

return {
    mapWidth  = mapWidth,
    mapHeight = 23,

    boardOffsetX = (windowWidth - mapWidth * cellWidth) * 0.5,
    boardOffsetY = 128,
    cellWidth    = cellWidth,
    cellHeight   = 24,

    blockerLeft      = 1,
    blockerRight     = 2,
    leverLeft        = 3,
    leverRight       = 4,
    blockerCoinLeft  = 5,
    blockerCoinRight = 6,
}
