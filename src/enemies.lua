require "snake"
require "utils"

enemies = {}

walks = {}
walks[1] = Animation(EnemyAnimLoader("walk", 1), 64, 64, 1, 0.15)
walks[2] = Animation(EnemyAnimLoader("walk", 2), 64, 64, 1, 0.15)

attacks = {}
attacks[1] = Animation(EnemyAnimLoader("attack", 1), 64, 64, 1, 0.15)
attacks[2] = Animation(EnemyAnimLoader("attack", 2), 64, 64, 1, 0.15)

function enemies:spawn(ui)
    width, height, flags = love.window.getMode()

    local i = #self + 1
    self[i] = {
        x = math.random(0, width),
        y = math.random(0, height),
        ui = ui,
        radius = 25,
        iframes = 0,
        anim = walks[(i % 2) + 1],
        load = direction_ai.load,
        update = direction_ai.update
    }

    self[i]:load()
end

direction_ai = {}

function direction_ai:load()
    self.dir = math.rad(math.random(0, 360))
    self.maxT = math.random(3, 10)
end

function direction_ai:update(dt)
    local speed = 150
    local switch = 256

    self.t = (self.t or 0) + dt
    if self.t > self.maxT then
        self:load()
        self.t = 0
    end

    local distance = snake:distance(self.x, self.y)
    if distance < switch and snake:distanceHead(self.x, self.y) > distance then
        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y)) + math.pi
    elseif distance < switch then
        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y))
    end

    self.x = self.x + (speed * dt * math.sin(self.dir))
    self.y = self.y + (speed * dt * math.cos(self.dir))
end

function enemies:update(dt)
    width, height, flags = love.window.getMode()

    for i = 1, #self do
        if self[i].anim ~= attacks[(i % 2) + 1] and snake:distance(self[i].x, self[i].y) < self[i].radius * 5 then
            self[i].anim = attacks[(i % 2) + 1]
        elseif self[i].anim ~= walks[(i % 2) + 1] then
            self[i].anim = walks[(i % 2) + 1]
        end

        if self[i].iframes > 0 then
            self[i].iframes = self[i].iframes - dt
        end

        self[i].anim:update(dt)
        self[i]:update(dt)

        if snake:hitHead(self[i].x, self[i].y, self[i].radius) then
            self:respawn(i)
            self[i]:load()
            self[i].iframes = 0
            self[i].ui:scoreUp()
        end

        if snake:hitTail(self[i].x, self[i].y, self[i].radius) and self[i].iframes <= 0 then
            snake:damage()
            self[i].iframes = 1
        end
    end
end

function enemies:respawn(i)
    self[i].x = math.random(0, width)
    self[i].y = math.random(0, height)

    if snake:hitHead(self[i].x, self[i].y, self[i].radius) or snake:hitTail(self[i].x, self[i].y, self[i].radius) then
        self:respawn(i)
    end
end

function enemies:draw()
    love.graphics.push()

    for i = 1, #self do
        love.graphics.origin()
        love.graphics.translate(torus_x(self[i].x), torus_y(self[i].y))
        love.graphics.rotate(-self[i].dir)

        self[i].anim:draw()
    end

    love.graphics.pop()
end
