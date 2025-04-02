-- sprite.lua

local newSprite = function (img, x, y, spOpt)
    local width = img:getWidth()
    local height = img:getHeight()

    local sliceX = spOpt.sliceX or 1
    local sliceY = spOpt.sliceY or 1
    
    local quadWidth = math.floor(width / sliceX)
    local quadHeight = math.floor(height / sliceY)

    local quads = {}
    for fy = 1, sliceY do
        for fx = 1, sliceX do
            local quad = love.graphics.newQuad((fx-1) * quadWidth,
                                                (fy-1) * quadHeight,
                                                quadWidth,
                                                quadHeight,
                                                width,
                                                height)
            table.insert(quads, quad)
        end
    end

    return {
        x = x or 0,
        y = y or 0,
        sx = 1,
        sy = 1,
        frame = 1,
        img = img,
        quads = quads,
        width = quadWidth,
        height = quadHeight,

        draw = function (sp)
            local ox, oy
            ox = sp.width * 0.5
            oy = sp.height * 0.5
            love.graphics.draw(sp.img,
                                sp.quads[sp.frame],
                                sp.x, sp.y,
                                sp.r,
                                sp.sx, sp.sy,
                                ox, oy)
        end,
    }
end

return newSprite
