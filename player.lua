local colorStack = require('colorStack')
local Map = require('Map')

local player = {}

player.x = 0
player.y = 0

function player.draw(globalState, xoff, yoff)
  local x = player.x * 16
  local y = player.y * 16
  colorStack.push(0,0,0, 1)
    love.graphics.rectangle("fill", x+xoff, y+yoff, 10, 10)
    for i=1,10 do
      local s = math.random(2,6)
      love.graphics.rectangle("fill", math.random(x+xoff-2, x+xoff+12-s), math.random(y+yoff-2, y+yoff+12-s), s, s)
    end
  colorStack.pop()
end

function player.tryGo(map, x,y, freq)
  local minX = math.floor(x)+1
  local maxX = math.floor(x+10/16)+1
  local minY = math.floor(y)+1
  local maxY = math.floor(y+10/16)+1
  local closest = map.frequencies:maxProximityFrequency(freq)
  -- If blocked by blue
  if closest then
    for y=minY,maxY do
      for x=minX,maxX do
        if closest.tilemap and closest.tilemap[y] and closest.tilemap[y][x] == Map.masterTiles['blue_single'] then
          return false
        end
      end
    end
  end
  -- If blocked by green in another
  for f,frequency in ipairs(map.frequencies) do
    if frequency ~= closest then
      for y=minY,maxY do
        for x=minX,maxX do
          if frequency.tilemap and frequency.tilemap[y] and frequency.tilemap[y][x] == Map.masterTiles['green_single'] then
            return false
          end
        end
      end
    end
  end
  -- If colliding
  for y=minY,maxY do
    for x=minX,maxX do
      if map.collisions and map.collisions[y] and map.collisions[y][x] then
        return false
      end
    end
  end
  player.x = x
  player.y = y
  return true
end

function player.tileInside(map, freq)
  local closest = map.frequencies:maxProximityFrequency(freq)
  if closest then
    local x = math.floor(player.x+5/16)+1
    local y = math.floor(player.y+5/16)+1
    if not closest.tilemap or not closest.tilemap[y] then return nil end
    return closest.tilemap[y][x]
  end
  return nil
end

return player
