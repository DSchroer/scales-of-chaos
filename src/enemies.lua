require "snake"
require "ui"

enemies = {}


function enemies:spawn()
    width, height, flags = love.window.getMode()

    self[#self + 1] = {
        x = math.random(0, width),
        y = math.random(0, height),
        radius = 25,
        hitPlayer = false
    }
end

function enemies:update(dt)
    width, height, flags = love.window.getMode()

    for i = 1, #self do
        if snake:hitHead(self[i].x, self[i].y, self[i].radius) then
            self:respawn(i)
            self[i].hitPlayer = false
            ui.score = ui.score + 1
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
        love.graphics.translate(self[i].x, self[i].y)

        if self[i].hitPlayer then
            love.graphics.setColor(0, 1, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.circle("line", 0, 0, 25, 10)
    end

    love.graphics.pop()
end
