require "enemies"
require "pickup"
require "snake"

ui = {
    score = 0,
    highscore = 0,
    state = "title"
}

scorefile = "soc.save"

function ui:load()
    self.font = love.graphics.newFont("assets/fonts/dogicapixelbold.ttf", 30)

    if love.filesystem.getInfo(scorefile) ~= nil then
        saveTxt = love.filesystem.read(scorefile)
        self.highscore = tonumber(saveTxt)
    else
        love.filesystem.write(scorefile, "0")
    end
end

function ui:setState(state)
    if state == "game" then
        ui.score = 0
        snake.visible = true
        snake:reset()
        for i = 1, #enemies do
            enemies[i] = nil
        end
        for i = 1, #pickups do
            pickups[i] = nil
        end
        enemies:spawn(ui)
    end

    if state == "end" then
        if self.score > self.highscore then
            self.highscore = self.score
            love.filesystem.write(scorefile, string.format("%d", self.score))
        end
    end

    self.state = state
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

function ui:update(dt)
    if self.state == "title" and love.keyboard.isDown("return") then
        self:setState("game")
    end

    if self.state == "title" and love.keyboard.isDown("c") then
        self:setState("credits")
    end

    if self.state == "credits" and love.keyboard.isDown("escape") then
        self:setState("title")
    end

    if self.state == "end" and love.keyboard.isDown("escape") then
        self:setState("title")
    end

    if self.state == "end" and love.keyboard.isDown("return") then
        self:setState("game")
    end
end

function ui:draw()
    width, height, flags = love.window.getMode()

    love.graphics.push()
    love.graphics.setColor(1, 0, 0, 1)

    if self.state == "title" then
        love.graphics.print("Scales Of Chaos", self.font, width / 4, height / 3, 0, 1.5, 1.5)

        love.graphics.print("Move with arrow keys.", self.font, width / 3, height / 2, 0, 0.75, 0.75)
        love.graphics.print("Press enter to start.", self.font, width / 3, (height / 2) + 100, 0, 0.75, 0.75)
        love.graphics.print("Press c for credits.", self.font, width / 3, (height / 2) + 150, 0, 0.75, 0.75)
    elseif self.state == "credits" then
        love.graphics.print("Credits", self.font, (width / 3) + 75, height / 3, 0, 1.5, 1.5)

        love.graphics.print("Design: Rebecca Goodine & Dominick Schroer", self.font, width / 5, (height / 2), 0, 0.75,
            0.75)
        love.graphics.print("Art: Rebecca Goodine", self.font, width / 5, (height / 2) + 50, 0, 0.75, 0.75)
        love.graphics.print("Programming: Dominick Schroer", self.font, width / 5, (height / 2) + 100, 0, 0.75, 0.75)

        love.graphics.print("Press escape for menu.", self.font, width / 3, (height / 2) + 200, 0, 0.75, 0.75)
    elseif self.state == "game" then
        love.graphics.print(string.format("Score: %d", self.score), self.font, width - 300, 32, 0, 1, 1)
    elseif self.state == "end" then
        love.graphics.print(string.format("Score: %d", self.score), self.font, width - 300, 32, 0, 1, 1)
        love.graphics.print(string.format("Best: %d", self.highscore), self.font, width - 300, 32 + 50, 0, 1, 1)

        love.graphics.print("Game Over!", self.font, width / 4, height / 3, 0, 2.5, 2.5)

        love.graphics.print("Press enter to retry.", self.font, width / 3, (height / 2), 0, 0.75, 0.75)
        love.graphics.print("Press escape for menu.", self.font, width / 3, (height / 2) + 50, 0, 0.75, 0.75)
    end

    love.graphics.pop()
end
