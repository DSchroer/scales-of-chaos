require "snake"
require "utils"

enemies = {}


function enemies:spawn(ui)
    width, height, flags = love.window.getMode()

    local i = #self + 1
    self[i] = {
        x = math.random(0, width),
        y = math.random(0, height),
        ui = ui,
        radius = 25,
        hitPlayer = false,
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
    local speed = 300

    self.t = (self.t or 0) + dt
    if self.t > self.maxT then
        self:load()
        self.t = 0
    end

    self.x = self.x + (speed * dt * math.sin(self.dir))
    self.y = self.y + (speed * dt * math.cos(self.dir))
end

function enemies:update(dt)
    width, height, flags = love.window.getMode()

    for i = 1, #self do
        self[i]:update(dt)

        if snake:hitHead(self[i].x, self[i].y, self[i].radius) then
            self:respawn(i)
            self[i]:load()
            self[i].hitPlayer = false
            self[i].ui:scoreUp()
        end

        if snake:hitTail(self[i].x, self[i].y, self[i].radius) and not self[i].hitPlayer then
            snake:damage()
            self[i].hitPlayer = true
        else
            self[i].hitPlayer = false
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

        if self[i].hitPlayer then
            love.graphics.setColor(0, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.circle("line", 0, 0, 25, 10)
    end

    love.graphics.pop()
end
