-- core.lua

local gameConst = require "game_const"

local blockerClass = require "blocker"
local leverClass = require "lever"
local newMindi = require "mindi"

return function ()
    local core = {}
    core.mapData = {
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },

        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },

        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },

        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },

        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },

        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },

        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
        { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, },
    }
    
    core.update = function (this, dt)
        
    end
    
    core.draw = function (this)
        for cellY = 1, gameConst.mapHeight do
            for cellX = 1, gameConst.mapWidth do
                for i, v in ipairs(this:getObjectsAtCell(cellX, cellY)) do
                    v:draw()
                end
            end
        end
    end
    
    core.init = function (this)
        for i = 1, 4 do
            this:insertLeftBlockedBlocker(5 + (i-1) * 2, 4)
        end
        for i = 1, 5 do
            this:insertRightBlockedBlocker(4 + (i-1) * 2, 8)
        end
        for i = 1, 6 do
            this:insertLeftBlockedBlocker(3 + (i-1) * 2, 12)
        end
        for i = 1, 7 do
            this:insertRightBlockedBlocker(2 + (i-1) * 2, 16)
        end
        for i = 1, 8 do
            this:insertLeftBlockedBlocker(1 + (i-1) * 2, 20)
        end
        this:insertCoin(5, 3)
    end
    
    core.insertCoin = function (this, cellX, cellY)
        local mindi = newMindi(this.mapData, cellX, cellY)
        table.insert(this.mapData[cellY][cellX], mindi)
    end
    
    core.insertLeftBlockedBlocker = function (this, cellX, cellY)
        local blockerL = blockerClass.newBlockerLeft(this.mapData, cellX, cellY, true)
        table.insert(this.mapData[cellY][cellX], blockerL)
        
        local blockerR = blockerClass.newBlockerRight(this.mapData, cellX + 1, cellY, false)
        table.insert(this.mapData[cellY][cellX], blockerR)
        
        local leverL = leverClass.newLeverLeft(this.mapData, cellX, cellY + 1, false)
        table.insert(this.mapData[cellY][cellX], leverL)
        
        local leverR = leverClass.newLeverRight(this.mapData, cellX + 1, cellY + 1, true)
        table.insert(this.mapData[cellY][cellX], leverR)
    end
    
    core.insertRightBlockedBlocker = function (this, cellX, cellY)
        local blockerL = blockerClass.newBlockerLeft(this.mapData, cellX, cellY, false)
        table.insert(this.mapData[cellY][cellX], blockerL)
        
        local blockerR = blockerClass.newBlockerRight(this.mapData, cellX + 1, cellY, true)
        table.insert(this.mapData[cellY][cellX], blockerR)
        
        local leverL = leverClass.newLeverLeft(this.mapData, cellX, cellY + 1, true)
        table.insert(this.mapData[cellY][cellX], leverL)
        
        local leverR = leverClass.newLeverRight(this.mapData, cellX + 1, cellY + 1, false)
        table.insert(this.mapData[cellY][cellX], leverR)
    end
    
    core.getObjectAllAtCell = function (this, cellX, cellY)
        return this.mapData[cellY][cellX]
    end
    
    core.getServices = function (this)
        return {
            getObjectAllAtCell = function (cellX, cellY) this:getObjectAllAtCell(cellX, cellY) end,
        }
    end
    
    core.updateAllCellStep = function (this)
        while true do
            local wantProcess = false
            for cellY = 1, gameConst.mapWidth do
                for cellX = 1, gameConst.mapHeight do
                    for i, v in ipairs(this:getObjectAllAtCell(cellX, cellY)) do
                        local queueProcess = v:updateStep(this:getServices())
                        if queueProcess and (not wantProcess) then
                            wantProcess = true
                        end
                    end
                end
            end
            if not wantProcess then
                break
            end
        end
    end
    
    return core
end
