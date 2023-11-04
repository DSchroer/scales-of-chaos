snake = { x = 100, y = 100, radius = 25, dir = 0, speed = 300, turn_speed = 3, tail_length = 5, tail_distance = 30 }

function snake:grow() 
    self.tail[#self.tail + 1] = { 
        x = self.x - (snake.tail_distance * (#self.tail + 1)), 
        y = self.y, 
        dir = 0,
        radius = 25
    }
end

snake.tail = {}
for i=1,snake.tail_length do
    snake:grow()
end

function snake:damage()
    table.remove(self.tail, #self.tail)
end

function snake:hitHead(x, y, radius) 
    return distance(torus_x(x), torus_y(y), torus_x(self.x), torus_y(self.y)) <= self.radius + radius
end

function snake:hitTail(x, y, radius)
    for i=1,#self.tail do
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

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.line(0, 0, 0, 25)
    love.graphics.circle("line", 0, 0, 25, 10)

    for i=1,#self.tail do
        love.graphics.origin()
        love.graphics.translate(torus_x(self.tail[i].x), torus_y(self.tail[i].y))
        love.graphics.rotate(-self.tail[i].dir)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.line(0, 0, 0, 25)
        love.graphics.circle("line", 0, 0, 25, 10)
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

    self.x = self.x + (self.speed * dt * math.sin(self.dir))
    self.y = self.y + (self.speed * dt * math.cos(self.dir))

    local tx = self.x
    local ty = self.y
 
    for i=1,#self.tail do
        dist = distance(tx, ty, self.tail[i].x, self.tail[i].y) - self.tail_distance
        dir = math.atan2(tx - self.tail[i].x, ty - self.tail[i].y)

        self.tail[i].dir = dir
        self.tail[i].x = self.tail[i].x + (dist * math.sin(dir))
        self.tail[i].y = self.tail[i].y + (dist * math.cos(dir))

        tx = self.tail[i].x
        ty = self.tail[i].y
    end

    snake:checkSelfHit()
end

function snake:checkSelfHit()
    for i=2,#self.tail do
        if i < #self.tail then -- check to see if we damaged ourself
            if snake:hitHead(self.tail[i].x, self.tail[i].y, self.tail[i].radius) then
                snake:damage()
            end
        end 
    end
end

width, height, flags = love.window.getMode()

function torus_x(x)
  return x % width
end

function torus_y(x)
  return x % height
end

function distance(x1, y1, x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt (dx * dx + dy * dy)
end
