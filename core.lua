-- core.lua

local get4Cells = function (mapData, cellX, cellY)
    return mapData[cellY][cellX], mapData[cellY][cellX+1], mapData[cellY+1][cellX], mapData[cellY+1][cellX+1]
end

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
    
    core.blockers = {}
    
    core.update = function (this, dt)
        
    end
    
    core.draw = function (this)
        for i, v in ipairs(core.blockers) do
            v:draw()
        end
    end
    
    core.insertBlockers = function (this, cellX, cellY)
        local topL, topR, btmL, btmR = get4Cells(this.mapData)
        
        local blockerL = newBlockerLeft()
        table.insert(this.blockers, blockerL)
        table.insert(topL, blockerL)
        
        local blockerR = newBlockerRight()
        table.insert(this.blockers, blockerR)
        table.insert(topR, blockerR)
        
        local leverL = newLeverLeft()
        table.insert(this.blockers, leverL)
        table.insert(btmL, leverL)
        
        local leverR = newLeverRight()
        table.insert(this.blockers, leverR)
        table.insert(btmR, leverR)
    end
    
    return core
end
