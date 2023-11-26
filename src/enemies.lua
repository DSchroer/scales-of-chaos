require "snake"
require "utils"

enemies = {}

walks = {}
walks[1] = Animation(EnemyAnimLoader("walk", 1), 64, 64, 1, 0.15)
walks[2] = Animation(EnemyAnimLoader("walk", 2), 64, 64, 1, 0.15)

attacks = {}
attacks[1] = Animation(EnemyAnimLoader("attack", 1), 64, 64, 1, 0.15)
attacks[2] = Animation(EnemyAnimLoader("attack", 2), 64, 64, 1, 0.15)

angryEmote = love.graphics.newImage("assets/enemy_emotes/angry_v1.png")
scaredEmote = love.graphics.newImage("assets/enemy_emotes/scared_v1.png")

crunch = love.audio.newSource("assets/audio/crunch.mp3", "static")

eep = love.audio.newSource("assets/audio/eep.mp3", "static")
eep:setVolume(0.25)

rage = love.audio.newSource("assets/audio/rage.mp3", "static")
rage:setVolume(0.75)

hit = love.audio.newSource("assets/audio/hit.mp3", "static")

HUNT = {
    name = "hunt",
    start = function(self)
        self.dir = math.rad(math.random(0, 360))
        self.maxT = math.random(3, 10)
        self.anim = table.copy(walks[self.anim_index])
        self.rage = math.random(10) == 5
    end,
    update = function(self, dt)
        local switch = 256

        self.t = (self.t or 0) + dt
        if self.t > self.maxT then
            HUNT.start(self)
            self.t = 0
            if self.rage then
                self:setState(RAGE)
            end
        end

        local distance = snake:distance(self.x, self.y)
        if distance < switch and snake:distanceHead(self.x, self.y) > distance then
            self:setState(ATTACK)
        elseif distance < switch then
            self:setState(RUN)
        end
    end,
    finish = function(self)
    end,
    draw = function(self)
    end
}
RAGE = {
    name = "rage",
    start = function(self)
        self.speed = self.speed * 1.5
        self.anim = table.copy(attacks[self.anim_index])

        rage:setPitch(1 + (math.random() * 0.5))
        love.audio.play(rage)
    end,
    update = function(self)
        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y)) + math.pi
    end,
    finish = function(self)
        self.speed = self.speed / 1.5
    end,
    draw = function(self)
        love.graphics.translate(-32, -64)
        love.graphics.draw(angryEmote)
    end
}
ATTACK = {
    name = "attack",
    start = function(self)
        self.anim = table.copy(attacks[self.anim_index])
    end,
    update = function(self)
        local switch = 256

        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y)) + math.pi

        local distance = snake:distance(self.x, self.y)
        if snake:distanceHead(self.x, self.y) < distance then
            self:setState(RUN)
        elseif distance > switch then
            self:setState(HUNT)
        end
    end,
    finish = function(self)
    end,
    draw = function(self)
    end
}
ATTACK_COOLDOWN = {
    name = "cooldown",
    start = function(self)
        self.iframes = 5;
        self.anim = table.copy(walks[self.anim_index])
        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y))
    end,
    update = function(self, dt)
        self.iframes = self.iframes - dt

        if self.iframes <= 0 then
            self:setState(HUNT)
        end
    end,
    finish = function(self)
    end,
    draw = function(self)
    end
}
RUN = {
    name = "run",
    start = function(self)
        self.speed = self.speed * 1.25
        self.anim = table.copy(walks[self.anim_index])
        eep:setPitch(1 + (math.random() * 0.5))
        love.audio.play(eep)
    end,
    update = function(self)
        local switch = 256

        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y))

        local distance = snake:distance(self.x, self.y)
        if snake:distanceHead(self.x, self.y) > distance then
            self:setState(ATTACK)
        elseif distance > switch then
            self:setState(HUNT)
        end
    end,
    finish = function(self)
        self.speed = self.speed / 1.25
    end,
    draw = function(self)
        love.graphics.translate(-32, -64)
        love.graphics.draw(scaredEmote)
    end
}

function enemies:spawn(ui)
    width, height, flags = love.window.getMode()

    local i = #self + 1
    local anim_index = (math.random(0, 10) % 2) + 1
    self[i] = {
        x = 0,
        y = 0,
        ui = ui,
        radius = 25,
        iframes = 0,
        anim_index = anim_index,
        anim = table.copy(walks[anim_index]),
        speed = 150,
        setState = function(self, state)
            if self.state == nil or self.state.name ~= state.name then
                if self.state ~= nil then
                    self.state.finish(self, state)
                end
                self.state = table.copy(state)
                self.state.start(self)
            end
        end,
        update = function(self, dt)
            self.state.update(self, dt);

            self.x = self.x + (self.speed * dt * math.sin(self.dir))
            self.y = self.y + (self.speed * dt * math.cos(self.dir))
        end,
    }

    self[i]:setState(HUNT)
    enemies:respawn(i)
end

function enemies:update(dt)
    width, height, flags = love.window.getMode()

    for i = 1, #self do
        self[i].anim:update(dt)
        self[i]:update(dt)

        if snake:hitHead(self[i].x, self[i].y, self[i].radius) then
            love.audio.stop(crunch)
            crunch:setPitch(1 + (math.random() * 0.5))
            love.audio.play(crunch)

            splats:spawn(self[i].x, self[i].y, -snake.dir)
            self:respawn(i)
            self[i]:setState(HUNT);
            self[i].iframes = 0
            self[i].ui:scoreUp()
        end

        if snake:hitTail(self[i].x, self[i].y, self[i].radius) and self[i].iframes <= 0 then
            love.audio.play(hit)
            snake:damage()
            self[i]:setState(ATTACK_COOLDOWN)
        end
    end
end

function enemies:respawn(i)
    self[i].x = math.random(0, width)
    self[i].y = math.random(0, height)
    self[i].anim_index = (math.random(0, 10) % 2) + 1

    if snake:distance(self[i].x, self[i].y) < 200 then
        self:respawn(i)
    end
end

function enemies:draw()
    love.graphics.push()

    for i = 1, #self do
        local shadow_scale = 1.1
        love.graphics.origin()
        love.graphics.translate(torus_x(self[i].x) - 7, torus_y(self[i].y))
        love.graphics.rotate(-self[i].dir)
        love.graphics.setColor(0, 0, 0, 0.15)
        love.graphics.scale(shadow_scale, shadow_scale)
        self[i].anim:draw()

        love.graphics.origin()
        love.graphics.translate(torus_x(self[i].x), torus_y(self[i].y))
        love.graphics.rotate(-self[i].dir)
        love.graphics.setColor(1, 1, 1, 1)
        self[i].anim:draw()

        love.graphics.rotate(self[i].dir)
        self[i].state.draw(self[i])
    end

    love.graphics.pop()
end
