-- main.lua
local gameConst = require("game_const")
local newAnimSprite = require("anim_sprite")
local newGame = require("game")


local menuButtonX = 300
local menuButtonY = 386
local menuButtonSpacing = 64
local menuButtonLabels = {
    "Player vs Computer",
    "Player vs Player",
    "Exit",
}

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
            this.curChoiceIndex = math.min(this.curChoiceIndex, #menuButtonLabels)
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



-- This is the current game state where : 
-- 1 = initial load
-- 2 = game is running 
local currentGameState = 1

-- the active instance of the main-menu
local mainMenu = nil
-- our current instance of the game 
local game = nil

love.load = function ()
    mainMenu = newMainMenu()
end

love.update = function (dt)
    -- if the game is running, keep retriggering the gameplayloop.
    if currentGameState == 2 then
        local isOver = game:update(dt)
        if isOver then
            game = nil
            mainMenu = newMainMenu()
            currentGameState = 1
        end
        return
    end

    -- we are still in the main menu, handle that input.
    -- 0: no choice made, 1: vs CPU, 2: vs player, 3: Quit
    local choice = mainMenu:update(dt)
    if choice == 0 then 
        return
    end
    
    if choice == 3 then
        love.event.quit(0)
        return
    end

    -- initialise a new game
    local withCPU = (choice == 1)
    game = newGame(withCPU)
    mainMenu = nil
    currentGameState = 2
end

love.draw = function ()
    if currentGameState == 2 then
        game:draw()
    else
        mainMenu:draw()
    end
end

love.keypressed = function (key, scancode)
    if currentGameState == 2 then
        game:keypressed(key, scancode)
    else
        mainMenu:keypressed(key, scancode)
    end
end
