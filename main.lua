local globalState = {
  state = require('startState'),
  common = require('common'),
}

function love.load()
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
  if globalState.state.draw then
    globalState.state.draw(globalState)
  end
end
