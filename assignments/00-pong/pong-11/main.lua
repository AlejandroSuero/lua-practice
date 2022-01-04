--[[
    
    PONG Remake

    Author: Alejandro Suero Mejías "aome"
    asuerome@gmail.com

    pong-11
    "The Audio Update"

]]

-- https://github.com/Ulydev/
push = require 'push'

-- https://github.com/vrld/
Class = require 'class'

-- Paddle class which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- Ball class which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differentrly
require 'Ball'

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
    large_font = love.graphics.newFont('font.ttf', 16)
    
    -- larger font for drawinf the score on the screen
    score_font = love.graphics.newFont('font.ttf', 32)
    
    -- set LÖVE2D's active font to the samllFont object
    love.graphics.setFont(small_font)

    -- set up our sound effects; later, we can just index this table
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    -- initialize player paddles; make them global so that they can be detected
    -- by ohter functions and modules
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    serving_player = 1
    winning_player = 0

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

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

    if game_state == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if serving_player == 1 then
            ball.dx = math.random(140, 200)
        elseif serving_player == 2 then
            ball.dx = -math.random(140, 200)
        end
    elseif game_state == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position
        -- of the
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03 -- increases by 3% each hit
            ball.x = player1.x + 5

            -- keep velocity going in the same direction, but randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            sounds.paddle_hit:play()
        end

        -- detect upper and lower screen boundary collision and if collides
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds.wall_hit:play()
        end

        -- if we reach the left or right edge of the screen,
        -- go back to start and update the score
        if ball.x < 0 then
            serving_player = 1
            player2.score = player2.score + 1
            sounds.score:play()

            if player2.score == 10 then
                winning_player = 2
                game_state = 'done'
            else
                game_state = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            serving_player = 2
            player1.score = player1.score + 1
            sounds.score:play()

            if player1.score == 10 then
                winning_player = 1
                game_state = 'done'
            else
                game_state = 'serve'
                ball:reset()
            end
        end
        
        -- player 1 movement
        if love.keyboard.isDown("w") then
            -- add negative paddle speed to current Y scaled by deltaTime
            -- player1Y = player1Y + (-PADDLE_SPEED * dt)
            player1.y = math.max(0, player1.y + -PADDLE_SPEED * dt)
        elseif love.keyboard.isDown("s") then
            -- add positive paddle speed to current Y scaled by deltaTime
            player1.y = math.min(VIRTUAL_HEIGHT - 20, player1.y + PADDLE_SPEED * dt)
        end

        -- player 2 movement
        if love.keyboard.isDown("up") then
            -- add negative paddle speed to current Y scaled by deltaTime
            player2.y = math.max(0, player2.y + -PADDLE_SPEED * dt)
        elseif love.keyboard.isDown("down") then
            -- add positive paddle speed to current Y scaled by deltaTime
            player2.y = math.min(VIRTUAL_HEIGHT - 20, player2.y + PADDLE_SPEED * dt)
        end
        ball:update(dt)
        player1:update(dt)
        player2:update(dt)
    end
end

function love.resize(w, h)
    push:resize(w, h)
end

function switchGameState()
    if game_state == 'start' then
        game_state = 'serve'
    elseif game_state == 'serve' then
        game_state = 'play'
    elseif game_state == 'done' then
        game_state = 'serve'

        ball:reset()

        -- reset score to 0
        player1.score = 0
        player2.score = 0

        if winning_player == 1 then
            serving_player = 2
        elseif winning_player == 2 then
            serving_player = 1
        end
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
    push:start()

    -- clear the screen with a scpecific color; in this case, a color similar
    -- to some version of the original Pong
    --                     R      G       B        a
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- draw welcome text toward the top of the screen
    love.graphics.setFont(small_font)
    if game_state == 'start' then
        love.graphics.printf('Welcome to Pong', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press ENTER to Start', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif game_state == 'serve' then
        love.graphics.printf('Player ' .. tostring(serving_player) .. '\'s serving!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press ENTER to Serve', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif game_state == 'play' then
        -- no UI messages
    elseif game_state == 'done' then
        love.graphics.setFont(large_font)
        love.graphics.printf('PLayer ' .. tostring(winning_player) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(small_font)
        love.graphics.printf('Press ENTER to restart', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()
    ball:render()

    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(score_font)
    love.graphics.print(tostring(player1.score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2.score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    displayFPS()

    push:finish()
end

--[[
    Renders the current FPS
]]
function displayFPS()
    -- simple FPS display accross all states
    love.graphics.setFont(small_font)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 15, 5)
end