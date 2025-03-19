-- event_handler.lua

return function ()
    local evh = {}
    evh.connectedMethods = {}
    
    evh.addEvent = function (this, evName, fn)
        if not this.connectedMethods[evName] then
            this.connectedMethods[evName] = {}
        end
        table.insert(this.connectedMethods, fn)
    end
    
    evn.triggerEvent = function (this, evName)
        for i, v in ipairs(this.connectedMethods[evName]) do
            v()
        end
    end
    
    return evh
end
