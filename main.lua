-- main.lua

local gameNew = require "game"

local game = nil

love.load = function ()
    game = gameNew({
        ["blocker_sheet"] = love.graphics.newImage("assets/textures/blocker_sheet.png"),
    })
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
