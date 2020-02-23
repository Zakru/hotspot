local colorStack = require('colorStack')

local globalState = {
  state = require('startState'),
  common = require('common'),
  scale = 1,
}

function globalState.changeState(newState)
  if globalState.state.unload then
    globalState.state.unload(globalState)
  end
  globalState.state = newState
  if newState.load then
    newState.load(globalState)
  end
end

local menu = false

local textExitMenu
local textQuit
local textFS
local textVolume
local textFrequency
local textMove
local textJump
local textHint

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.audio.setVolume(0.25)
  love.mouse.setVisible(false)

  globalState.common.load()

  textExitMenu = love.graphics.newText(globalState.common.font, 'USE ESC AGAIN TO EXIT MENU')
  textQuit = love.graphics.newText(globalState.common.font, 'USE Q TO QUIT')
  textFS = love.graphics.newText(globalState.common.font, 'PRESS F11 TO TOGGLE FULLSCREEN')
  textVolume = love.graphics.newText(globalState.common.font, 'ADJUST VOLUME WITH N AND M IN MENU')
  textFrequency = love.graphics.newText(globalState.common.font, 'USE J AND K TO FIND A FREQUENCY')
  textMove = love.graphics.newText(globalState.common.font, 'MOVE WITH A AND D OR ARROWS')
  textJump = love.graphics.newText(globalState.common.font, 'JUMP WITH W, UP ARROW OR SPACEBAR')
  textHint = love.graphics.newText(globalState.common.font, 'WHEN STUCK, REMEMBER TO CHECK EVERY FREQUENCY')

  if globalState.state.load then
    globalState.state.load(globalState)
  end
end

function love.update(dt)
  if menu then
    if love.keyboard.isDown('n') then
      love.audio.setVolume(math.max(love.audio.getVolume() - dt * 0.25, 0))
    end
    if love.keyboard.isDown('m') then
      love.audio.setVolume(math.min(love.audio.getVolume() + dt * 0.25, 1))
    end
  end

  if globalState.state.update then
    globalState.state.update(globalState, dt)
  end
end

function love.draw()
  local w,h = love.graphics.getDimensions()
  globalState.scale = math.max(math.floor(h / 250), 1)
  love.graphics.scale(globalState.scale, globalState.scale)

  if globalState.state.draw then
    globalState.state.draw(globalState)
  end

  if menu then
    colorStack.push(0,0,0, 0.5)
      love.graphics.rectangle('fill', 0,0, globalState.common.scaledDimensions(globalState))
    colorStack.pop()

    love.graphics.draw(textExitMenu, 8, 8)
    love.graphics.draw(textQuit, 8, 24)
    love.graphics.draw(textFS, 8, 32)
    love.graphics.draw(textVolume, 8, 40)
    love.graphics.draw(textFrequency, 8, 48)
    love.graphics.draw(textMove, 8, 56)
    love.graphics.draw(textJump, 8, 64)
    love.graphics.draw(textHint, 8, 80)
  end
end

function love.keypressed(k, sc, r)
  if k == 'f11' then
    love.window.setFullscreen(not love.window.getFullscreen())
  end

  if globalState.state.keypressed then
    globalState.state.keypressed(globalState, k, sc, r)
  end

  if k == 'escape' then
    menu = not menu
  end
  if k == 'q' and menu then
    love.event.quit()
  end
end
