-- sprite.lua
-- each sprite expect a "spritesheet", it needs to know how many tiles are on the spritesheet, and makes quads according to it.
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
            local quad = love.graphics.newQuad(
                (fx-1) * quadWidth,
                (fy-1) * quadHeight,
                quadWidth,
                quadHeight,
                width,
                height
            )
            table.insert(quads, quad)
        end
    end

    return {
        x = x or 0, -- x render position of the sprite
        y = y or 0, -- y render position of the sprite
        sx = 1, -- info: sx = scaleX
        sy = 1, -- info: sy = scaleY
        frame = 1, -- frame is the current rendered tile of the spritesheet, (for a non-animated sprite this is ALWAYS 1)
        img = img, -- the spritesheet itself
        quads = quads, -- every frame of the spritesheet is a quad, so a static sprite will ALWAYS be 1 quad 
        width = quadWidth, -- size of an individual tile, READONLY do not override.
        height = quadHeight, -- size of an individual tile, READONLY do not override.

        draw = function (self)
            -- ox & oy are origin points, we want to have x,y at the center of the sprite
            local ox = self.width * 0.5
            local oy = self.height * 0.5
            love.graphics.draw(
                self.img,
                self.quads[self.frame],
                self.x, self.y,
                nil, -- normally rotation, but N/A in this project
                self.sx, self.sy, 
                ox, oy
            )
        end,
    }
end

return newSprite
