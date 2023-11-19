require "enemies"
require "pickup"
require "snake"

ui = {
    score = 0,
    paused = false
}

function ui:load()
    self.font = love.graphics.newFont("assets/fonts/dogicapixelbold.ttf", 30)
end

function ui:scoreUp()
    self.score = self.score + 1

    if self.score == 1 then
        pickups:spawn(function()
            snake:grow()
            snake:grow()
        end)
    end

    if self.score % 5 == 0 then
        enemies:spawn(self)
    end

    if self.score % 6 == 0 then
        pickups:spawn(function()
            snake:grow()
            snake:grow()
        end)
    end
end

function ui:draw()
    width, height, flags = love.window.getMode()

    love.graphics.push()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print(string.format("Score: %d", self.score), self.font, width - 300, 32, 0, 1, 1)


    if self.paused then
        love.graphics.print("Game Over!", self.font, width / 4, height / 3, 0, 2.5, 2.5)
    end

    love.graphics.pop()
end
