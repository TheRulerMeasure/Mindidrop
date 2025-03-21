-- main.lua

local newGame = require "game"

local game = nil

love.load = function ()
    local newFont = love.graphics.newImageFont("assets/fonts/dojmun_font_line_lv.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()_-+=[{]}\\|;:'\",<.>/?")
    love.graphics.setFont(newFont)
    game = newGame({
        ["blocker_sheet"] = love.graphics.newImage("assets/textures/blocker_sheet.png"),
        ["coin"] = love.graphics.newImage("assets/textures/coin.png"),
        ["insert_arrow_sheet"] = love.graphics.newImage("assets/textures/insert_arrow_sheet.png"),
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
