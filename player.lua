local colorStack = require('colorStack')
local Map = require('Map')

local player = {}

player.x = 0
player.y = 0

function player.draw(globalState, xoff, yoff)
  local x = player.x
  local y = player.y
  colorStack.push(0,0,0, 1)
    love.graphics.rectangle("fill", x+xoff, y+yoff, 0.625, 0.625)
    for i=1,10 do
      local s = math.random()*0.25 + 0.125
      love.graphics.rectangle("fill", x+xoff + math.random()*(0.875 - s)-0.125, y+yoff + math.random()*(0.875 - s)-0.125, s, s)
    end
  colorStack.pop()
end

function player.tryGo(map, x,y, freq, dir)
  local minX = math.floor(x)+1
  local maxX = math.floor(x+10/16)+1
  local minY = math.floor(y)+1
  local maxY = math.floor(y+10/16)+1
  if maxX == x+10/16 + 1 then maxX = maxX - 1 end
  if maxY == y+10/16 + 1 then maxY = maxY - 1 end
  local closest = map.frequencies:maxProximityFrequency(freq)
  -- If blocked by blue
  if closest then
    for y=minY,maxY do
      for x=minX,maxX do
        if closest.tilemap and closest.tilemap[y] and closest.tilemap[y][x] == Map.masterTiles['blue_single'] then
          if dir == 0 then
            player.y = y
          elseif dir == 1 then
            player.x = x - 1.625
          elseif dir == 2 then
            player.y = y - 1.625
          elseif dir == 3 then
            player.x = x
          end
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
            if dir == 0 then
              player.y = y
            elseif dir == 1 then
              player.x = x - 1.625
            elseif dir == 2 then
              player.y = y - 1.625
            elseif dir == 3 then
              player.x = x
            end
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
        if dir == 0 then
          player.y = y
        elseif dir == 1 then
          player.x = x - 1.625
        elseif dir == 2 then
          player.y = y - 1.625
        elseif dir == 3 then
          player.x = x
        end
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
