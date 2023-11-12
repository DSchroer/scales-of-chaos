ui = {
    score = 0,
    paused = false
}


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
