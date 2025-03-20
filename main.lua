-- main.lua

local newGame = require "game"

local game = nil

love.load = function ()
    game = newGame({
        ["blocker_sheet"] = love.graphics.newImage("assets/textures/blocker_sheet.png"),
        ["coin"] = love.graphics.newImage("assets/textures/coin.png")
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
