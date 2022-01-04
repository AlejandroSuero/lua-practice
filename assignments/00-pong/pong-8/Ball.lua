--[[
    
    PONG Remake

    Author: Alejandro Suero Mejías "aome"
    asuerome@gmail.com

    pong-5
    "The Class Update"

]]

Ball = Class{}

--[[
    Ball's constructor

    Inits the Ball with a given x and y axis, and width and height to
    be rendered.
]]
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- these variables are for keeping track of our velocity in the
    -- X and Y axis, since the ball cna move in two dimensions
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

--[[
    Places the ball in the middle of the screen, with an initial random velocity
    on both axes.
]]
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

--[[
    Simply applies velocity to position, scaled by delta time.
]]
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

--[[
    Expects a paddle as an argument and retruns true or false, depending
    on whether their rectangles overlap.
]]
function Ball:collides(paddle)
    -- first, check to se if the left edge of either is farther to the right
    -- than the right edge of the ohter
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Renders the Ball.
]]
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
