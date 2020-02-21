local common = {}

local noiseTile

function common.load()
  noiseTile = love.graphics.newImage('noise.png')
end

function common.drawNoiseTiles()
  local w,h = love.graphics.getDimensions()
  local horTiles = math.ceil(w/512) + 1
  local verTiles = math.ceil(h/512) + 1

  local randX = math.random(512)
  local randY = math.random(512)

  for x=1,horTiles do
    for y=1,verTiles do
      love.graphics.draw(noiseTile, x * 512 + randX -1024, y * 512 + randY -1024)
    end
  end
end

return common
