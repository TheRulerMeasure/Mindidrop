-- center_label.lua
local gameConst = require("game_const")
local newSprite = require("sprite")

local scaleRate = 0.15
local maxDisplaySeconds = 4

local round1 = 1
local round2 = 2
local round3 = 3
local round4 = 4
local p1Win = 5
local p2Win = 6

local newCenterLabel = function (img)
    local cl = {}
    cl.sprite = newSprite(img, gameConst.windowWidth * 0.5, gameConst.windowHeight * 0.5, {
        sliceX = 6,
        sliceY = 1,
    })
    cl.t = maxDisplaySeconds
    
    cl.alpha = 1
    
    cl.update = function (this, dt)
        if this.t >= maxDisplaySeconds then return end
        this.t = this.t + dt
        local sx, sy
        sx = 1 + (this.t * scaleRate)
        sy = 1 + (this.t * scaleRate)
        this.sprite.sx = sx
        this.sprite.sy = sy
        local alpha
        alpha = math.max(this.t - 3, 0)
        alpha = 1 - alpha
        this.alpha = math.min(alpha, 1)
    end
    
    cl.draw = function (this)
        if this.t >= maxDisplaySeconds then return end
        love.graphics.setColor(1, 1, 1, this.alpha)
        this.sprite:draw()
    end
    
    cl.displayLabel = function (this, n)
        this.t = 0
        this.alpha = 1
        this.sprite.frame = math.min(math.max(math.floor(n), 1), 6)
        this.sprite.sx = 1
        this.sprite.sy = 1
    end
    
    return cl
end

return {
    new = newCenterLabel,
    round1 = round1,
    round2 = round2,
    round3 = round3,
    round4 = round4,
    p1Win = p1Win,
    p2Win = p2Win,
}
