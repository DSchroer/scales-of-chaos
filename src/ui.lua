require "enemies"
require "pickup"
require "snake"
require "blood"

ui = {
    score = 0,
    highscore = 0,
    state = "mainmenu"
}

scorefile = "soc.save"

function ui:load()
    self.font = love.graphics.newFont("assets/fonts/dogicapixelbold.ttf", 41)
    self.mainmenu = love.graphics.newImage("assets/screens/mainmenu.png")
    self.gameover = love.graphics.newImage("assets/screens/gameover.png")
    self.pregame = love.graphics.newImage("assets/screens/pregame.png")

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
        for i = 1, #splats do
            splats[i] = nil
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

    if #enemies < (math.log(self.score) * 1.5) then
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
    if not love.keyboard.isDown("return") then
        self.debounce = false;
    end

    if self.state == "mainmenu" and love.keyboard.isDown("return") and not self.debounce then
        self.debounce = true;
        self:setState("pregame")
    end

    if self.state == "pregame" and love.keyboard.isDown("return") and not self.debounce then
        self:setState("game")
    end

    if self.state == "end" and love.keyboard.isDown("escape") then
        self:setState("mainmenu")
    end

    if self.state == "end" and love.keyboard.isDown("return") then
        self:setState("game")
    end
end

function ui:draw()
    width, height, flags = love.window.getMode()

    love.graphics.push()

    if self.state == "mainmenu" then
        love.graphics.draw(self.mainmenu)
    elseif self.state == "pregame" then
        love.graphics.draw(self.pregame)
    elseif self.state == "game" then
        love.graphics.setColor(147, 221, 19, 1)
        love.graphics.print(string.format("Score: %d", self.score), self.font, width - 300, 32, 0, 0.75, 0.75)
    elseif self.state == "end" then
        love.graphics.draw(self.gameover)

        love.graphics.setColor(147, 221, 19, 1)
        love.graphics.print(string.format("%d", self.score), self.font, 675, 311, 0, 1, 1)
        love.graphics.print(string.format("%d", self.highscore), self.font, 395, 370, 0, 1, 1)
    end

    love.graphics.pop()
end
