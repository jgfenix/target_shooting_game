-- simple game to shooting a target with mouse key

-- width and height of window's game
g_windowWidth, g_windowHeight = 640, 480

-- game states enumeration to clarify code review
gameStateEnum = {
    menuPage = 1,
    playingGame = 2
}

-- mouse buttons enumeration to clarify code review -> https://love2d.org/wiki/love.mousepressed
mouseButtonsEnum = {
    left = 1,
    right = 2,
    middle = 3
}

function love.load()
    love.window.setMode(g_windowWidth, g_windowHeight)
    love.window.setTitle("Shoot!")

    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    score = 0
    timer = 0

    gameState = gameStateEnum.menuPage
    gameFontTitle = love.graphics.newFont(40)
    gameFontRules = love.graphics.newFont(20)

    sprites = {}
    sprites.sky = love.graphics.newImage('images/sky.png')
    sprites.target = love.graphics.newImage('images/target.png')
    sprites.crosshairs = love.graphics.newImage('images/crosshairs.png')

    love.mouse.setVisible(false) -- as we replace mouse icon for a crosshair, we hide original mouse icon
end

function love.update(dt)
    if timer > 0 then
        timer = timer - dt
    end

    if timer < 0 then
        timer = 0
        gameState = 1
    end
end

function love.draw()
    love.graphics.draw(sprites.sky, 0, 0)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gameFontTitle)
    love.graphics.print("Score: " .. score, 5, 5)
    love.graphics.print("Time: " .. math.ceil(timer), 300, 5)

    if gameState == gameStateEnum.menuPage then
        love.graphics.printf("Rules:", 0, 70, love.graphics.getWidth(), "center")

        love.graphics.setFont(gameFontRules)
        love.graphics.printf("You have 10 seconds to hit targets.", 0, 150, love.graphics.getWidth(), "center")
        love.graphics.printf("Hit the target with left click -> win 1 point.", 0, 180, love.graphics.getWidth(), "center")
        love.graphics.printf("Hit the target with right click -> win 2 points but lose 1 second.", 0, 210, love.graphics.getWidth(), "center")
        love.graphics.printf("Miss the target -> you lose a point on score.", 0, 240, love.graphics.getWidth(), "center")
        
        love.graphics.setFont(gameFontTitle)
        love.graphics.printf("Click anywhere to begin!", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.printf("Press Esc to quit", 0, 370, love.graphics.getWidth(), "center")
    end

    if gameState == gameStateEnum.playingGame then
        love.graphics.draw(sprites.target, target.x - target.radius, target.y - target.radius)
    end
    
    love.graphics.draw(sprites.crosshairs, love.mouse.getX()-20, love.mouse.getY()-20)
end

function love.mousepressed( x, y, button, istouch, presses )
    if gameState == gameStateEnum.playingGame then
        -- only process right and left mouse buttons
        if button == mouseButtonsEnum.middle then
            return
        end
        
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        
        -- player hit target
        if mouseToTarget < target.radius then
            if button == mouseButtonsEnum.left then
                score = score + 1
            elseif button == mouseButtonsEnum.right then
                score = score + 2
                if timer > 0 then
                    timer = timer - 1
                end
            end
        else -- player miss target, lose a point on score
            if score > 0 then
                score = score - 1
            end
        end

        -- changing target to a new position
        target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
        target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)

    -- elseif button == mouseButtonsEnum.left then
        -- print("button == mouseButtonsEnum.left")
    -- end
    elseif gameState == gameStateEnum.menuPage and button == mouseButtonsEnum.left then
        gameState = gameStateEnum.playingGame
        timer = 10
        score = 0
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        love.event.quit()
    end
end

-- math way to get distance between two points
function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end