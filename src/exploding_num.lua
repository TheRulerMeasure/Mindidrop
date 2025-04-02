-- exploding_num.lua

local maxDisplaySeconds = 0.25

local newAnimSprite = require("anim_sprite")

local newExplodingNum = function (img, explodeSound, x, y)
    local num = {}
    num.number = 2
    num.boomSprite = newAnimSprite(img, x or 0, y or 0, {
        sliceX = 5,
        sliceY = 1,
        anims = {
            ["explode"] = {
                minFrame = 1,
                maxFrame = 5,
                forward = true,
                speed = 19,
            },
        },
    })
    num.showBoom = false
    
    num.t = maxDisplaySeconds
    
    num.explodeSound = explodeSound
    
    num.update = function (this, dt)
        this.boomSprite:update(dt)
        if this.t < maxDisplaySeconds then
            this.t = this.t + dt
        else
            this.showBoom = false
        end
    end
    
    num.draw = function (this)
        love.graphics.setColor(love.math.colorFromBytes(77, 41, 3))
        local numText = tostring(this.number)
        local coordX, coordY
        coordX = this.boomSprite.x - #numText * 6
        coordY = this.boomSprite.y - 8
        love.graphics.print(numText, coordX, coordY)
        if this.showBoom then
            love.graphics.setColor(1, 1, 1)
            num.boomSprite:draw()
        end
    end
    
    num.setNum = function (this, newNum)
        this.number = newNum
        this.t = 0
        this.boomSprite:play("explode")
        love.audio.play(this.explodeSound)
        this.showBoom = true
    end
    
    return num
end

return newExplodingNum
