function LizardAnimLoader(name)
    return function(i)
        return string.format("assets/lizard_frames/frame%d/frame%d_%s.png", i, i, name)
    end
end

function EnemyAnimLoader(name, n)
    return function(i)
        return string.format("assets/enemy%d_%s/enemy%d_%s%d.png", n, name, n, name, i)
    end
end

function EmoteLoader(name)
    return function(i)
        return string.format("assets/enemy_emotes/%s%d.png", name, i)
    end
end

function AnimLoader(name)
    return function(i)
        return string.format("assets/%s/%s%d.png", name, name, i)
    end
end

function Animation(loader, x, y, scale, speed)
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
        local file = loader(i)
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
    if self.frame > #self.frames + 1 then
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

function torus_x(x)
    width, height, flags = love.window.getMode()

    return x % width
end

function torus_y(x)
    width, height, flags = love.window.getMode()

    return x % height
end

function table.copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end
