ui = {
    score = 0
}

width, height, flags = love.window.getMode()

function ui:draw()
    love.graphics.push()
    love.graphics.setColor(1, 0, 0, 0.8)
    love.graphics.print(string.format("Score: %d", self.score), width - 200, 32, 0, 3, 3)
    love.graphics.pop()
end
