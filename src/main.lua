require "snake"
require "enemies"
require "ui"
require "pickup"

enemies:spawn(ui)

function love.load()
    love.window.setMode((1920 / 3) * 2, (1080 / 3) * 2)

    ui:load();

    bg = love.graphics.newImage("assets/background.jpg")

    snake:load(ui)
end

function love.update(dt)
    if not ui.paused then
        enemies:update(dt)
        pickups:update(dt)
        snake:update(dt)
    end
end

function love.draw()
    love.graphics.reset()
    love.graphics.draw(bg, 0, 0, 0, 2, 2)

    enemies:draw()
    pickups:draw()
    snake:draw()

    ui:draw()
end
