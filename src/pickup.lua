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
        anim = Animation(AnimLoader("heart"), 32, 32, 1, 0.15)
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
        local shadow_scale = 1.1
        love.graphics.origin()
        love.graphics.translate(torus_x(self[i].x) - 7, torus_y(self[i].y))
        love.graphics.rotate(math.pi)
        love.graphics.setColor(0, 0, 0, 0.15)
        love.graphics.scale(shadow_scale, shadow_scale)
        self[i].anim:draw()

        love.graphics.origin()
        love.graphics.translate(torus_x(self[i].x), torus_y(self[i].y))
        love.graphics.rotate(math.pi)
        love.graphics.setColor(1, 1, 1, 1)
        self[i].anim:draw()
    end

    love.graphics.pop()
end
