--[[
    
    PONG Remake

    Author: Alejandro Suero Mejías "aome"
    asuerome@gmail.com

    pong-1
    "The Low Res Update"

]]

--[[
    push is a library that will allow us to draw our game at a virtual
    resolution, instead of however large our window is; used t provide
    a more retro aesthetic

    https://github.com/Ulydev/
]]
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

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions; replaces our love.window.setMode
    -- from the last example 'pong-0'
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

--[[
    Detects any key pressed by the user and process that key if needed
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

    love.graphics.printf('Hello Pong', 0, VIRTUAL_HEIGHT / 2 - 6, VIRTUAL_WIDTH, 'center')

    -- stop rendering at virtual resolution
    push:apply('end')
end