-- main.lua

local newCore = require "core"

local core = nil

love.load = function ()
    core = newCore()
    core:init()
end

love.update = function (dt)
    core:update(dt)
end

love.draw = function ()
    core:draw()
end
