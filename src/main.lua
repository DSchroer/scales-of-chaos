require "snake"
require "enemies"

enemies:spawn()
enemies:spawn()
enemies:spawn()

function love.load()
    bg = love.graphics.newImage("assets/background.jpg")
end

function love.update(dt)
    enemies:update(dt)
    snake:update(dt)
end

function love.draw()
    love.graphics.reset()
    love.graphics.draw(bg, 0, 0, 0, 2, 2)

    enemies:draw()
    snake:draw()
end
