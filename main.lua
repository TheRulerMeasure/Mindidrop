-- main.lua

local gameNew = require "game"

local game = nil

love.load = function ()
    game = gameNew()
    game:insertCoin(1)
    game:insertCoin(1)
end

love.update = function (dt)
    game:update(dt)
end

love.draw = function ()
    game:draw()
end

love.keypressed = function (key, scancode)
    game:keypressed(key, scancode)
end
