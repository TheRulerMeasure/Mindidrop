-- exploding_num.lua

local maxDisplaySeconds = 0.25

local newAnimSprite = require "anim_sprite"

local newExplodingNum = function (img, x, y)
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
        love.graphics.print(tostring(this.number), this.boomSprite.x - 6, this.boomSprite.y - 8)
        if this.showBoom then
            love.graphics.setColor(1, 1, 1)
            num.boomSprite:draw()
        end
    end
    
    num.setNum = function (this, newNum)
        this.number = newNum
        this.t = 0
        this.boomSprite:play("explode")
        this.showBoom = true
    end
    
    return num
end

return newExplodingNum
