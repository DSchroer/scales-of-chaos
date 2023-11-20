require "utils"

splats = {}

bloodAnim = Animation(AnimLoader("blood"), 64, 64, 1, 0.15)

function bloodAnim:update()
    if self.frame < #self.frames then
        self.frame = self.frame + self.speed
    end
end

function splats:spawn(x, y, dir)
    if #self > 100 then
        table.remove(self, 1)
    end

    self[#self + 1] = {
        x = torus_x(x),
        y = torus_y(y),
        dir = dir,
        anim = table.copy(bloodAnim)
    }
end

function splats:update(dt)
    for i = 1, #self do
        self[i].anim:update(dt)
    end
end

function splats:draw()
    love.graphics.push()

    for i = 1, #self do
        love.graphics.origin()
        love.graphics.translate(self[i].x, self[i].y)
        love.graphics.rotate(self[i].dir)

        self[i].anim:draw()
    end

    love.graphics.pop()
end
