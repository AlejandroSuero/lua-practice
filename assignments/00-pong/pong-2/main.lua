--[[
    
    PONG Remake

    Author: Alejandro Suero Mejías "aome"
    asuerome@gmail.com

    pong-2
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

--[[
    Runs when the game first starts up, only once; used to initialize the game
]]
function love.load()
    -- use the nearest-neighbor filtering on upscaling and downscaling to prevent
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- more 'retro-looking' font object
    small_font = love.graphics.newFont('font.ttf', 8)

    -- set LÖVE2D's active font to the samllFont object
    love.graphics.setFont(small_font)
    
    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

--[[
    Keyboard handling, called by LÖVE2D each frame;
    passes in the key we pressed so we can acces.
]]
function love.keypressed(key)
    -- if the user wants to quit, press ESC or escape
    if key == 'escape' then
        love.event.quit()
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
    love.graphics.printf('Hello Pong!', 0, 20, VIRTUAL_WIDTH, 'center')

    --
    -- paddles are simply rectangles we draw on the screen at certain points,
    -- as is the ball
    --

    -- render first paddle (left side)
    love.graphics.rectangle('fill', 10, 30, 5, 20)

    -- render second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    -- render ball (center)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    
    -- stop rendering at virtual resolution
    push:apply('end')
end