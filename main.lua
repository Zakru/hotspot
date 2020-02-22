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

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")

  globalState.common.load()

  if globalState.state.load then
    globalState.state.load(globalState)
  end
end

function love.update(dt)
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
end

function love.keypressed(k, sc, r)
  if k == 'f11' then
    love.window.setFullscreen(not love.window.getFullscreen())
  end

  if globalState.state.keypressed then
    globalState.state.keypressed(globalState, k, sc, r)
  end
end
