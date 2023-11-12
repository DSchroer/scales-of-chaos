require "enemies"
-- require "pickup"
-- require "snake"

ui = {
    score = 0,
    paused = false
}

function ui:scoreUp()
    self.score = self.score + 1

    if self.score % 5 == 0 then
        enemies:spawn(self)
    end

    if self.score % 15 then
        -- pickups:spawn(function()
        --     -- snake:grow()
        -- end)
    end
end

function ui:draw()
    width, height, flags = love.window.getMode()

    love.graphics.push()
    love.graphics.setColor(1, 0, 0, 0.8)
    love.graphics.print(string.format("Score: %d", self.score), width - 200, 32, 0, 3, 3)


    if self.paused then
        love.graphics.print("Game Over!", width / 4, height / 4, 0, 5, 5)
    end

    love.graphics.pop()
end
