-- main.lua

local maxMenuButtons = 3
local menuButtonX = 300
local menuButtonY = 386
local menuButtonSpacing = 64
local menuButtonLabels = {
    "Player vs Computer",
    "Player vs Player",
    "Exit",
}

local gameConst = require("game_const")

local newAnimSprite = require("anim_sprite")

local newGame = require("game")

local newMainMenu = function ()
    local mm = {}
    mm.curChoiceIndex = 1
    mm.choice = 0
    
    mm.arrowSprite = newAnimSprite(love.graphics.newImage("assets/textures/double_arrows_sheet.png"), menuButtonX, menuButtonY, {
        sliceX = 1,
        sliceY = 2,
        anims = {
            ["dance"] = {
                minFrame = 1,
                maxFrame = 2,
                forward = true,
                loop = true,
                speed = 8,
            }
        },
    })
    mm.arrowSprite:play("dance")
    
    mm.update = function (this, dt)
        this.arrowSprite:update(dt)
        return this.choice
    end
    
    mm.draw = function (this)
        love.graphics.setColor(0.12, 0.12, 0.12)
        for i, v in ipairs(menuButtonLabels) do
            local coordX, coordY
            coordX = menuButtonX - #v * 4
            coordY = menuButtonY + (i-1) * menuButtonSpacing
            love.graphics.print(v, coordX, coordY)
        end
        love.graphics.print("[Up/Down], [Enter]", 230, 750)
        love.graphics.setColor(1, 1, 1)
        this.arrowSprite:draw()
    end
    
    mm.keypressed = function (this, key, scancode)
        if this.choice > 0 then
            return
        end
        if scancode == "up" or scancode == 'w' then
            this.curChoiceIndex = this.curChoiceIndex - 1
            this.curChoiceIndex = math.max(this.curChoiceIndex, 1)
            this:setArrowSpritePosFromIndex(this.curChoiceIndex)
        elseif scancode == "down" or scancode == 's' then
            this.curChoiceIndex = this.curChoiceIndex + 1
            this.curChoiceIndex = math.min(this.curChoiceIndex, maxMenuButtons)
            this:setArrowSpritePosFromIndex(this.curChoiceIndex)
        elseif scancode == "return" or key == "space" then
            this.choice = this.curChoiceIndex
        end
    end
    
    mm.setArrowSpritePosFromIndex = function (this, n)
        this.arrowSprite.y = 386 + (n-1) * menuButtonSpacing
    end
    
    return mm
end

local getGameAssets = function () return {
    ["blocker_sheet"] = love.graphics.newImage("assets/textures/blocker_sheet.png"),
    ["coin"] = love.graphics.newImage("assets/textures/coin.png"),
    ["insert_arrow_sheet"] = love.graphics.newImage("assets/textures/insert_arrow_sheet.png"),
    ["board_front"] = love.graphics.newImage("assets/textures/board_front.png"),
    ["board_back"] = love.graphics.newImage("assets/textures/board_back.png"),
    ["bubv_sheet"] = love.graphics.newImage("assets/textures/bubv_sheet.png"),
    ["mindi_tower_sheet"] = love.graphics.newImage("assets/textures/mindi_tower_sheet.png"),
    ["mindi_pgbar_bg"] = love.graphics.newImage("assets/textures/mindi_progbar_background.png"),
    ["mindi_pgbar_over"] = love.graphics.newImage("assets/textures/mindi_progbar_over.png"),
    ["label_sheet"] = love.graphics.newImage("assets/textures/label_sheet.png"),
    ["boom_sheet"] = love.graphics.newImage("assets/textures/small_boom_sheet.png"),
    
    ["coin_hit_coin"] = love.audio.newSource("assets/sounds/coin_hit_coin.wav", "static"),
    ["coin_scored"] = love.audio.newSource("assets/sounds/coin_scored.wav", "static"),
    ["explosion"] = love.audio.newSource("assets/sounds/explosion.wav", "static"),
    ["lever_move"] = love.audio.newSource("assets/sounds/lever_move.wav", "static"),
    ["game_end"] = love.audio.newSource("assets/sounds/game_end.wav", "static"),
    ["round_begin"] = love.audio.newSource("assets/sounds/round_begin.wav", "static"),
} end

local curState = 1

local mainMenu = nil
local game = nil

love.load = function ()
    love.graphics.setBackgroundColor(love.math.colorFromBytes(117, 107, 95))
    local newFont = love.graphics.newImageFont("assets/fonts/dojmun_font_line_lv.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~`!@#$%^&*()_-+=[{]}\\|;:'\",<.>/?")
    love.graphics.setFont(newFont)
    mainMenu = newMainMenu()
end

love.update = function (dt)
    if curState == 2 then
        local isOver = game:update(dt)
        if isOver then
            game = nil
            mainMenu = newMainMenu()
            curState = 1
        end
    else
        local choice = mainMenu:update(dt)
        if choice == 1 then
            game = newGame(getGameAssets(), true)
            mainMenu = nil
            curState = 2
        elseif choice == 2 then
            game = newGame(getGameAssets(), false)
            mainMenu = nil
            curState = 2
        elseif choice == 3 then
            love.event.quit(0)
        end
    end
end

love.draw = function ()
    if curState == 2 then
        game:draw(0)
    else
        mainMenu:draw()
    end
end

love.keypressed = function (key, scancode)
    if curState == 2 then
        game:keypressed(key, scancode)
    else
        mainMenu:keypressed(key, scancode)
    end
end
