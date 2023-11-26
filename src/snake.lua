require "utils"
require "blood"

snake = { x = 100, y = 100, radius = 30, dir = 0, speed = 300, turn_speed = 4, tail_length = 7, tail_distance = 30, visible = false }

function snake:load(ui)
    self.ui = ui
    self.anim = Animation(LizardAnimLoader("head"), 64, 30, 1.5, 0.15)
end

function snake:reset()
    while #snake.tail ~= snake.tail_length do
        if #snake.tail < snake.tail_length then
            snake:grow()
        else
            snake:damage()
        end
    end
end

function snake:grow()
    local index = #self.tail + 1
    self.tail[index] = {
        x = self.x - (snake.tail_distance * (#self.tail + 1)),
        y = self.y,
        dir = 0,
        radius = 25
    }

    if index == 1 then
        self.tail[index].anim = Animation(LizardAnimLoader("arms"), 64, 47, 1.5, 0.15)
    elseif index == 2 then
        self.tail[index].anim = Animation(LizardAnimLoader("body"), 64, 62, 1.5, 0.15)
    elseif index == 3 then
        self.tail[index].anim = Animation(LizardAnimLoader("legs"), 64, 93, 1.5, 0.15)
    elseif (index - 3) % 2 == 0 then
        self.tail[index].anim = Animation(LizardAnimLoader("tail"), 69, 110, 1.5, 0.15)
    end
end

snake.tail = {}
for i = 1, snake.tail_length do
    snake:grow()
end

function snake:damage()
    table.remove(self.tail, #self.tail)

    splats:spawn(self.tail[#self.tail].x, self.tail[#self.tail].y, self.tail[#self.tail].dir)

    table.remove(self.tail, #self.tail)
    if #self.tail < 4 then
        self.ui:setState("end")
    end
end

function snake:hitHead(x, y, radius)
    return distance(torus_x(x), torus_y(y), torus_x(self.x), torus_y(self.y)) <= self.radius + radius
end

function snake:hitTail(x, y, radius)
    for i = 1, #self.tail do
        if distance(torus_x(x), torus_y(y), torus_x(self.tail[i].x), torus_y(self.tail[i].y)) <= self.tail[i].radius + radius then
            return true
        end
    end
    return false
end

function snake:distanceHead(x, y)
    return distance(torus_x(x), torus_y(y), torus_x(self.x), torus_y(self.y))
end

function snake:distance(x, y)
    local d = distance(torus_x(x), torus_y(y), torus_x(self.x), torus_y(self.y))
    for i = 1, #self.tail do
        local td = distance(torus_x(x), torus_y(y), torus_x(self.tail[i].x), torus_y(self.tail[i].y))
        if td < d then
            d = td
        end
    end
    return d
end

function snake:draw()
    if not self.visible then
        return
    end

    love.graphics.push()
    local shadow_scale = 1.1

    for i = #self.tail, 1, -1 do
        love.graphics.origin()
        love.graphics.translate(torus_x(self.tail[i].x) - 7, torus_y(self.tail[i].y))
        love.graphics.rotate(-self.tail[i].dir)
        love.graphics.setColor(0, 0, 0, 0.15)
        love.graphics.scale(shadow_scale, shadow_scale)
        if self.tail[i].anim ~= nil then
            self.tail[i].anim:draw()
        end

        love.graphics.origin()
        love.graphics.translate(torus_x(self.tail[i].x), torus_y(self.tail[i].y))
        love.graphics.rotate(-self.tail[i].dir)
        love.graphics.setColor(1, 1, 1, 1)
        if self.tail[i].anim ~= nil then
            self.tail[i].anim:draw()
        end
    end

    love.graphics.origin()
    love.graphics.translate(torus_x(self.x) - 7, torus_y(self.y))
    love.graphics.rotate(-self.dir)
    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.scale(shadow_scale, shadow_scale)
    self.anim:draw()

    love.graphics.origin()
    love.graphics.translate(torus_x(self.x), torus_y(self.y))
    love.graphics.rotate(-self.dir)
    love.graphics.setColor(1, 1, 1, 1)
    self.anim:draw()

    love.graphics.pop()
end

function snake:update(dt)
    if love.keyboard.isDown("left") then
        self.dir = self.dir + (self.turn_speed * dt)
    end

    if love.keyboard.isDown("right") then
        self.dir = self.dir - (self.turn_speed * dt)
    end

    self.anim:update()

    self.x = self.x + (self.speed * dt * math.sin(self.dir))
    self.y = self.y + (self.speed * dt * math.cos(self.dir))

    local tx = self.x
    local ty = self.y

    for i = 1, #self.tail do
        local tail_distance = self.tail_distance

        dist = distance(tx, ty, self.tail[i].x, self.tail[i].y) - tail_distance
        dir = math.atan2(tx - self.tail[i].x, ty - self.tail[i].y)

        self.tail[i].dir = dir
        self.tail[i].x = self.tail[i].x + (dist * math.sin(dir))
        self.tail[i].y = self.tail[i].y + (dist * math.cos(dir))

        tx = self.tail[i].x
        ty = self.tail[i].y


        if self.tail[i].anim ~= nil then
            self.tail[i].anim:update()
        end
    end

    snake:checkSelfHit()
end

function snake:checkSelfHit()
    for i = 2, #self.tail do
        if i < #self.tail then -- check to see if we damaged ourself
            if snake:hitHead(self.tail[i].x, self.tail[i].y, self.tail[i].radius) then
                snake:damage()
            end
        end
    end
end

function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end
