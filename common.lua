local colorStack = require('colorStack')

local common = {}

local noiseTile

function common.load()
  noiseTile = love.graphics.newImage('noise.png')

  common.font = love.graphics.newImageFont('font.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 Ö*?/,', 1)
end

function common.drawNoiseTiles(globalState, alpha)
  local w,h = common.scaledDimensions(globalState)
  local horTiles = math.ceil(w/512) + 1
  local verTiles = math.ceil(h/512) + 1

  local randX = math.random(512)
  local randY = math.random(512)

  colorStack.push(1,1,1, alpha)
    for x=1,horTiles do
      for y=1,verTiles do
        love.graphics.draw(noiseTile, x * 512 + randX -1024, y * 512 + randY -1024)
      end
    end
  colorStack.pop()
end

function common.scaledDimensions(globalState)
  local w,h = love.graphics.getDimensions()
  w = math.ceil(w / globalState.scale)
  h = math.ceil(h / globalState.scale)
  return w,h
end

return common
