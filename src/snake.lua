require "utils"
require "ui"

snake = { x = 100, y = 100, radius = 25, dir = 0, speed = 300, turn_speed = 3, tail_length = 5, tail_distance = 30 }

function snake:load()
    self.anim = Animation("head", 64, 34, 1.5, 0.15)
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
        self.tail[index].anim = Animation("arms", 64, 47, 1.5, 0.15)
    elseif index == 2 then
        self.tail[index].anim = Animation("body", 64, 62, 1.5, 0.15)
    elseif index == 3 then
        self.tail[index].anim = Animation("legs", 64, 93, 1.5, 0.15)
    else
        self.tail[index].anim = Animation("tail", 64, 111, 1.5, 0.15)
    end
end

snake.tail = {}
for i = 1, snake.tail_length do
    snake:grow()
end

function snake:damage()
    table.remove(self.tail, #self.tail)
    if #self.tail < 4 then
        ui.paused = true
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

function snake:draw()
    love.graphics.push()

    love.graphics.translate(torus_x(self.x), torus_y(self.y))
    love.graphics.rotate(-self.dir)
    self.anim:draw()

    for i = 1, #self.tail do
        love.graphics.origin()

        if i > 3 then
            love.graphics.setColor(1, 0.5, 0.5, 1)
        end

        love.graphics.translate(torus_x(self.tail[i].x), torus_y(self.tail[i].y))
        love.graphics.rotate(-self.tail[i].dir)
        self.tail[i].anim:draw()
    end

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
        dist = distance(tx, ty, self.tail[i].x, self.tail[i].y) - self.tail_distance
        dir = math.atan2(tx - self.tail[i].x, ty - self.tail[i].y)

        self.tail[i].dir = dir
        self.tail[i].x = self.tail[i].x + (dist * math.sin(dir))
        self.tail[i].y = self.tail[i].y + (dist * math.cos(dir))

        tx = self.tail[i].x
        ty = self.tail[i].y

        self.tail[i].anim:update()
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

function torus_x(x)
    width, height, flags = love.window.getMode()

    return x % width
end

function torus_y(x)
    width, height, flags = love.window.getMode()

    return x % height
end

function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end
