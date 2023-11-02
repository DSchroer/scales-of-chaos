snake = { x = 100, y = 100, dir = 0, speed = 300, turn_speed = 3, tail_length = 20, tail_distance = 30 }

snake.tail = {}
for i=1,snake.tail_length do
    snake.tail[i] = { x = snake.x - (snake.tail_distance * i), y = snake.y, dir = 0 }
end

function snake.draw()
    love.graphics.push()
    love.graphics.translate(torus_x(snake.x), torus_y(snake.y))
    love.graphics.rotate(-snake.dir)
    love.graphics.circle("line", 0, 0, 25, 10)
    love.graphics.pop()

    for i=1,#snake.tail do
        love.graphics.push()
        love.graphics.translate(torus_x(snake.tail[i].x), torus_y(snake.tail[i].y))
        love.graphics.rotate(-snake.tail[i].dir)
        love.graphics.circle("line", 0, 0, 25, 6)
        love.graphics.pop()
    end
end

function snake.update(dt)
    if love.keyboard.isDown("left") then
        snake.dir = snake.dir + (snake.turn_speed * dt)
    end

    if love.keyboard.isDown("right") then
        snake.dir = snake.dir - (snake.turn_speed * dt)
    end

    snake.x = snake.x + (snake.speed * dt * math.sin(snake.dir))
    snake.y = snake.y + (snake.speed * dt * math.cos(snake.dir))

    local tx = snake.x
    local ty = snake.y
 
    for i=1,#snake.tail do
        dist = distance(tx, ty, snake.tail[i].x, snake.tail[i].y) - snake.tail_distance
        dir = math.atan2(tx - snake.tail[i].x, ty - snake.tail[i].y)

        snake.tail[i].dir = dir
        snake.tail[i].x = snake.tail[i].x + (dist * math.sin(dir))
        snake.tail[i].y = snake.tail[i].y + (dist * math.cos(dir))

        tx = snake.tail[i].x
        ty = snake.tail[i].y
    end
end

width, height, flags = love.window.getMode()

function torus_x(x)
  return x % width
end

function torus_y(x)
  return x % height
end

function distance(x1, y1, x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt (dx * dx + dy * dy)
end
