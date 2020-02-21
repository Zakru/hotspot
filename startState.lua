local startState = {}

function startState.draw(globalState)
  globalState.common.drawNoiseTiles(1)
  love.graphics.print("Asdf", 0, 0)
end

return startState
