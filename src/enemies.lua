require "snake"
require "utils"

enemies = {}

walks = {}
walks[1] = Animation(EnemyAnimLoader("walk", 1), 64, 64, 1, 0.15)
walks[2] = Animation(EnemyAnimLoader("walk", 2), 64, 64, 1, 0.15)

attacks = {}
attacks[1] = Animation(EnemyAnimLoader("attack", 1), 64, 64, 1, 0.15)
attacks[2] = Animation(EnemyAnimLoader("attack", 2), 64, 64, 1, 0.15)

HUNT = {
    name = "hunt",
    start = function(self)
        self.dir = math.rad(math.random(0, 360))
        self.maxT = math.random(3, 10)
        self.anim = table.copy(walks[self.anim_index])
    end,
    update = function(self, dt)
        local switch = 256

        self.t = (self.t or 0) + dt
        if self.t > self.maxT then
            HUNT.start(self)
            self.t = 0
        end

        local distance = snake:distance(self.x, self.y)
        if distance < switch and snake:distanceHead(self.x, self.y) > distance then
            self:setState(ATTACK)
        elseif distance < switch then
            self:setState(RUN)
        end
    end,
    draw = function(self)
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
    draw = function(self)
    end
}
ATTACK_COOLDOWN = {
    name = "cooldown",
    start = function(self)
        self.iframes = 5;
        self.anim = table.copy(walks[self.anim_index])
    end,
    update = function(self, dt)
        self.iframes = self.iframes - dt

        if self.iframes <= 0 then
            self:setState(HUNT)
        end

        self.dir = math.atan2(torus_x(self.x) - torus_x(snake.x), torus_y(self.y) - torus_y(snake.y))
    end,
    draw = function(self)
    end
}
RUN = {
    name = "run",
    start = function(self)
        self.anim = table.copy(walks[self.anim_index])
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
    draw = function(self)
    end
}

function enemies:spawn(ui)
    width, height, flags = love.window.getMode()

    local i = #self + 1
    local anim_index = (math.random(0, 10) % 2) + 1
    self[i] = {
        x = math.random(0, width),
        y = math.random(0, height),
        ui = ui,
        radius = 25,
        iframes = 0,
        anim_index = anim_index,
        anim = table.copy(walks[anim_index]),
        setState = function(self, state)
            if self.state == nil or self.state.name ~= state.name then
                self.state = table.copy(state)
                self.state.start(self)
            end
        end,
        update = function(self, dt)
            local speed = 150

            self.state.update(self, dt);

            self.x = self.x + (speed * dt * math.sin(self.dir))
            self.y = self.y + (speed * dt * math.cos(self.dir))
        end,
    }

    self[i]:setState(HUNT)
end

function enemies:update(dt)
    width, height, flags = love.window.getMode()

    for i = 1, #self do
        self[i].anim:update(dt)
        self[i]:update(dt)

        if snake:hitHead(self[i].x, self[i].y, self[i].radius) then
            splats:spawn(self[i].x, self[i].y, -snake.dir)
            self:respawn(i)
            self[i]:setState(HUNT);
            self[i].iframes = 0
            self[i].ui:scoreUp()
        end

        if snake:hitTail(self[i].x, self[i].y, self[i].radius) and self[i].iframes <= 0 then
            snake:damage()
            self[i]:setState(ATTACK_COOLDOWN)
        end
    end
end

function enemies:respawn(i)
    self[i].x = math.random(0, width)
    self[i].y = math.random(0, height)
    self[i].anim_index = (math.random(0, 10) % 2) + 1

    if snake:hitHead(self[i].x, self[i].y, self[i].radius) or snake:hitTail(self[i].x, self[i].y, self[i].radius) then
        self:respawn(i)
    end
end

function enemies:draw()
    love.graphics.push()

    for i = 1, #self do
        love.graphics.origin()
        love.graphics.translate(torus_x(self[i].x), torus_y(self[i].y))

        self[i].state.draw(self[i])

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
    end

    love.graphics.pop()
end
