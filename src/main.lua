require "utils"
require "snake"
require "enemies"
require "ui"
require "pickup"
require "blood"

function love.load()
    load()

    love.window.setMode(1280, 720)
    ui:load();

    bg = love.graphics.newImage("assets/background.jpg")
    love.window.setIcon(love.image.newImageData("assets/lizard_flat/lizard_2.png"))

    snake:load(ui)
end

function love.update(dt)
    ui:update(dt)

    if ui.state == "game" then
        splats:update(dt)
        enemies:update(dt)
        pickups:update(dt)
        snake:update(dt)
    end
end

function love.draw()
    love.graphics.reset()
    love.graphics.draw(bg, 0, 0, 0, 1, 1)

    splats:draw()
    enemies:draw()
    pickups:draw()
    snake:draw()

    ui:draw()
end
