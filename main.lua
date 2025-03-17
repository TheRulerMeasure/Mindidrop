-- main.lua

local gameNew = require "game"

local game = nil

local blocker = nil
local coin = nil

love.load = function ()
    game = gameNew()
    
    blocker = love.graphics.newImage("assets/textures/blocker_sheet.png")
    coin = love.graphics.newImage("assets/textures/coin.png")
end

love.update = function (dt)
    game:update(dt)
end

love.draw = function ()
    game:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(blocker, 10, 10)
    love.graphics.draw(coin, 10, 50)
end

love.keypressed = function (key, scancode)
    game:keypressed(key, scancode)
end
