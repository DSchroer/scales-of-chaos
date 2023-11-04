require "snake"
require "enemies"

enemies:spawn()
enemies:spawn()
enemies:spawn()

function love.update(dt)
    enemies:update(dt)
    snake:update(dt)
end

function love.draw()
    enemies:draw()
    snake:draw()
end
