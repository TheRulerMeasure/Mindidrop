-- main.lua

local newGame = require "game"

local game = nil

love.load = function ()
    love.graphics.setBackgroundColor(love.math.colorFromBytes(117, 107, 95))
    local newFont = love.graphics.newImageFont("assets/fonts/dojmun_font_line_lv.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()_-+=[{]}\\|;:'\",<.>/?")
    love.graphics.setFont(newFont)
    game = newGame({
        ["blocker_sheet"] = love.graphics.newImage("assets/textures/blocker_sheet.png"),
        ["coin"] = love.graphics.newImage("assets/textures/coin.png"),
        ["insert_arrow_sheet"] = love.graphics.newImage("assets/textures/insert_arrow_sheet.png"),
        ["board_front"] = love.graphics.newImage("assets/textures/board_front.png"),
        ["board_back"] = love.graphics.newImage("assets/textures/board_back.png"),
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
