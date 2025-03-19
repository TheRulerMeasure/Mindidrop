-- core.lua

local blockerClass = require "blocker"
local leverClass = require "lever"
local newMindi = require "mindi"

return function ()
    local core = {}
    core.mapData = {
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },

        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },

        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },

        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },

        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },

        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },

        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
        { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
    }
    
    core.blockers = {}
    core.mindies = {}
    
    core.update = function (this, dt)
        
    end
    
    core.draw = function (this)
        for i, v in ipairs(this.blockers) do
            v:draw()
        end
        for i, v in ipairs(this.mindies) do
            v:draw()
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
        table.insert(this.mindies, mindi)
        this.mapData[cellY][cellX] = mindi
    end
    
    core.insertLeftBlockedBlocker = function (this, cellX, cellY)
        local blockerL = blockerClass.newBlockerLeft(this.mapData, cellX, cellY, true)
        table.insert(this.blockers, blockerL)
        this.mapData[cellY][cellX] = blockerL
        
        local blockerR = blockerClass.newBlockerRight(this.mapData, cellX + 1, cellY, false)
        table.insert(this.blockers, blockerR)
        this.mapData[cellY][cellX+1] = blockerR
        
        local leverL = leverClass.newLeverLeft(this.mapData, cellX, cellY + 1, false)
        table.insert(this.blockers, leverL)
        this.mapData[cellY+1][cellX] = leverL
        
        local leverR = leverClass.newLeverRight(this.mapData, cellX + 1, cellY + 1, true)
        table.insert(this.blockers, leverR)
        this.mapData[cellY+1][cellX+1] = leverR
    end
    
    core.insertRightBlockedBlocker = function (this, cellX, cellY)
        local blockerL = blockerClass.newBlockerLeft(this.mapData, cellX, cellY, false)
        table.insert(this.blockers, blockerL)
        this.mapData[cellY][cellX] = blockerL
        
        local blockerR = blockerClass.newBlockerRight(this.mapData, cellX + 1, cellY, true)
        table.insert(this.blockers, blockerR)
        this.mapData[cellY][cellX+1] = blockerR
        
        local leverL = leverClass.newLeverLeft(this.mapData, cellX, cellY + 1, true)
        table.insert(this.blockers, leverL)
        this.mapData[cellY+1][cellX] = leverL
        
        local leverR = leverClass.newLeverRight(this.mapData, cellX + 1, cellY + 1, false)
        table.insert(this.blockers, leverR)
        this.mapData[cellY+1][cellX+1] = leverR
    end
    
    return core
end
