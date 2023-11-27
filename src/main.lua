require "snake"
require "enemies"
require "ui"
require "pickup"
require "blood"

function love.load()
    love.window.setMode(1280, 720)
    background = love.audio.newSource("assets/audio/background.mp3", "static")
    game = love.audio.newSource("assets/audio/game.mp3", "static")
    background:setVolume(0.15)
    background:setLooping(true)
    game:setVolume(0.15)
    game:setLooping(true)
    love.audio.play(background)
    love.audio.stop(game)
    ui:load();

    bg = love.graphics.newImage("assets/background.jpg")

    snake:load(ui)
end

function love.update(dt)
    ui:update(dt)

    if ui.state == "game" then
	love.audio.stop(background)
	love.audio.play(game)
        splats:update(dt)
        enemies:update(dt)
        pickups:update(dt)
        snake:update(dt)
    end

end

function love.draw()
    love.graphics.reset()
    love.graphics.draw(bg, 0, 0, 0, 2, 2)

    splats:draw()
    enemies:draw()
    pickups:draw()
    snake:draw()

    ui:draw()
end
