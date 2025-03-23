-- game_const.lua

local windowWidth = 600

local mapWidth = 16
local cellWidth = 24

return {
    windowWidth = windowWidth,
    windowHeight = 800,
    
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
    
    blockersAmount = 30,
    blockerCoords = {
        { x = 5, y = 4 }, { x = 7, y = 4 }, { x = 9, y = 4 }, { x = 11, y = 4 },
        
        { x = 4, y = 8 }, { x = 6, y = 8 }, { x = 8, y = 8 }, { x = 10, y = 8 },
        { x = 12, y = 8 },
        
        { x = 3, y = 12 }, { x = 5, y = 12 }, { x = 7, y = 12 }, { x = 9, y = 12 },
        { x = 11, y = 12 }, { x = 13, y = 12 },
        
        { x = 2, y = 16 }, { x = 4, y = 16 }, { x = 6, y = 16 }, { x = 8, y = 16 },
        { x = 10, y = 16 }, { x = 12, y = 16 }, { x = 14, y = 16 },
        
        { x = 1, y = 20 }, { x = 3, y = 20 }, { x = 5, y = 20 }, { x = 7, y = 20 },
        { x = 9, y = 20 }, { x = 11, y = 20 }, { x = 13, y = 20 }, { x = 15, y = 20 },
    },
    
    maxPlayersCount = 2,
    
    maxRounds = 4,
    maxRoundScores = { 12, 44, 24, 82 },
    roundScoreMulSlots = {
        { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, },
        { 34, 24, 13, 8, 5, 3, 2, 1, 1, 2, 3, 5, 8, 13, 24, 34, },
        { 9, 8, 7, 6, 5, 4, 3, 2, 2, 3, 4, 5, 6, 7, 8, 9, },
        { 64, 49, 24, 16, 8, 4, 2, 1, 1, 2, 4, 8, 16, 24, 49, 64, },
    },
}
