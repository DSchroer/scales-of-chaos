function Animation(name, x, y, scale, speed)
    local anim = {
        originX = -x,
        originY = -y,
        scale = scale,
        frame = 1,
        speed = speed,
        frames = {},
        draw = drawFrame,
        update = updateFrame
    };
    local i = 1
    while true do
        local file = string.format("assets/lizard_frames/frame%d/frame%d_%s.png", i, i, name)
        if love.filesystem.getInfo(file) == nil then
            break
        end

        anim.frames[i] = love.graphics.newImage(file)
        i = i + 1
    end
    return anim
end

function updateFrame(self)
    self.frame = self.frame + self.speed
    if self.frame > #self.frames then
        self.frame = 1
    end
end

function drawFrame(self)
    love.graphics.push()

    love.graphics.rotate(math.pi)
    love.graphics.draw(self.frames[math.floor(self.frame)], self.originX * self.scale, self.originY * self.scale, 0,
        self.scale,
        self.scale)

    love.graphics.pop()
end
