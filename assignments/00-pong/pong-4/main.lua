--[[
    
    PONG Remake

    Author: Alejandro Suero Mejías "aome"
    asuerome@gmail.com

    pong-4
    "The Rectangle Update"

]]

-- https://github.com/Ulydev/
push = require 'push'

-- Window resolution 720p (rendered at)
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- Virtual resolution 240p
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- speed at which we will move our paddle; multiplied by dt in pudate
PADDLE_SPEED = 200

--[[
    Runs when the game first starts up, only once; used to initialize the game
]]
function love.load()
    -- use the nearest-neighbor filtering on upscaling and downscaling to prevent
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- "seed" the RNG so that calls ro random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- more 'retro-looking' font object
    small_font = love.graphics.newFont('font.ttf', 8)

    -- larger font for drawinf the score on the screen
    score_font = love.graphics.newFont('font.ttf', 32)

    -- set LÖVE2D's active font to the samllFont object
    love.graphics.setFont(small_font)
    
    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- initialize score variables, used for rendering on the screen and keeping
    -- track of the winner
    player1_score = 0
    player2_score = 0

    -- paddle position on the Y axis (they can only move up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    -- velocity and position variables for our ball when play starts
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2

    -- math.random return a random value between the left and right number
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)

    -- game state variable used to transition between different parts of the game
    -- (used for beginning, menus, main game, high score list, etc.)
    -- we will use this to determine behavior during render and update
    game_state = 'start'
    
end

--[[
    Runs every frame, with "dt" passed in, our delta in seconds
    since the last dram, which LÖVE2D supplies us.
]]

function love.update(dt)
    love.graphics.setFont(small_font)
    love.graphics.print(tostring(dt), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)

    -- player 1 movement
    if love.keyboard.isDown("w") then
        -- add negative paddle speed to current Y scaled by deltaTime
        -- player1Y = player1Y + (-PADDLE_SPEED * dt)
        player1Y = math.max(0, player1Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown("s") then
        -- add positive paddle speed to current Y scaled by deltaTime
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED * dt)
    end

    -- player 2 movement
    if love.keyboard.isDown("up") then
        -- add negative paddle speed to current Y scaled by deltaTime
        player2Y = math.max(0, player2Y + -PADDLE_SPEED * dt)
    elseif love.keyboard.isDown("down") then
        -- add positive paddle speed to current Y scaled by deltaTime
        player2Y = math.min(VIRTUAL_HEIGHT - 20, player2Y + PADDLE_SPEED * dt)
    end

    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if game_state == 'play' then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end

end

function switchGameState()
    if game_state == 'start' then
        game_state = 'play'
    else
        game_state = 'start'

        -- start ball's position in the middle of the screen
        ballX = VIRTUAL_WIDTH / 2 - 2
        ballY = VIRTUAL_HEIGHT / 2 - 2

        -- given ball's X and Y velocity a random starting value
        -- the and/or pattern her is Lua's wat of accomplishin a ternary
        ballDX = math.random(2) == 1 and 100 or -100
        ballDY = math.random(-50, 50) * 1.5
    end
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]
function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        switchGameState()
    end
end


--[[
    Called after update by LÖVE2D, used to draw anything to the screen,
    updated or otherwise.
]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a scpecific color; in this case, a color similar
    -- to some version of the original Pong
    --                     R      G       B        a
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw welcome text toward the top of the screen
    love.graphics.setFont(small_font)
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(score_font)
    love.graphics.print(tostring(player1_score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2_score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- render first paddle (left side)
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', ballX, ballY, 4, 4)
    
    -- stop rendering at virtual resolution
    push:apply('end')
end