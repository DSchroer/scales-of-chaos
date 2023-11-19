require "snake"
require "utils"

pickups = {}

function pickups:spawn(onHit)
    width, height, flags = love.window.getMode()

    self[#self + 1] = {
        x = math.random(0, width),
        y = math.random(0, height),
        radius = 25,
        hit = onHit,
        anim = Animation(AnimLoader("heart"), 64, 64, 1, 0.15)
    }
end

function pickups:update(dt)
    for i = 1, #self do
        self[i].anim:update(dt)

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
        love.graphics.rotate(math.pi)

        self[i].anim:draw()
    end

    love.graphics.scale(1, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end
