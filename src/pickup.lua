require "snake"

pickups = {}

function pickups:spawn(onHit)
    width, height, flags = love.window.getMode()

    self[#self + 1] = {
        x = math.random(0, width),
        y = math.random(0, height),
        radius = 25,
        hit = onHit
    }
end

function pickups:update(dt)
    for i = 1, #self do
        if snake:hitHead(self[i].x, self[i].y, self[i].radius) then
            self[i]:hit()
            table.remove(self, i)
            return
        end
    end
end

function pickups:draw()
    love.graphics.push()

    for i = 1, #self do
        love.graphics.origin()
        love.graphics.translate(self[i].x, self[i].y)

        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.circle("fill", 0, 0, 25, 10)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end
