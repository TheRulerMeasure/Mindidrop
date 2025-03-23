-- anim_sprite.lua

local newSprite = require("sprite")

local newAnimSprite = function (img, x, y, animSpOpt)
    local sp = newSprite(img, x, y, {
        sliceX = animSpOpt.sliceX,
        sliceY = animSpOpt.sliceY,
    })

    sp.time = 0

    sp.anims = animSpOpt.anims
    sp.curAnim = ""

    sp.update = function (this, dt)
        if #this.curAnim <= 0 then return end
        local anim = this.anims[this.curAnim]
        this:updateFrame(anim, dt)
    end
    
    sp.updateFrame = function (this, anim, dt)
        this.time = this.time + anim.speed * dt
        local diff = math.abs(anim.maxFrame - anim.minFrame)
        local frame
        if anim.loop then
            frame = math.floor(this.time) % (diff + 1)
        else
            frame = math.min(math.floor(this.time), diff)
        end
        if not anim.forward then
            frame = diff - frame
        end
        frame = anim.minFrame + frame
        this.frame = frame
    end

    sp.play = function (this, anim, resetAnim)
        this.curAnim = anim
        local anim = this.anims[this.curAnim]
        this.frame = anim.minFrame
        if resetAnim then
            return
        end
        this.time = 0
    end

    return sp
end

return newAnimSprite
