local FrequencySet = require('FrequencySet')
local Frequency = require('Frequency')

local Map = {}

Map.masterTiles = {}
Map.noneTile = {}

local function loadTile(name)
  Map.masterTiles[name] = love.graphics.newImage(name .. '.png')
end

function Map.load()
  loadTile('black_top')
  loadTile('black_bottom')
  loadTile('black_right')
  loadTile('black_left')

  loadTile('black_t_top')
  loadTile('black_t_bottom')
  loadTile('black_t_right')
  loadTile('black_t_left')

  loadTile('black_top_right')
  loadTile('black_top_left')
  loadTile('black_bottom_right')
  loadTile('black_bottom_left')

  loadTile('black_vertical')
  loadTile('black_horizontal')
  loadTile('black_single')

  loadTile('black_flag')

  loadTile('red_single')
  loadTile('blue_single')
  loadTile('green_single')
end

function Map.newMap(startfreq, startx, starty, collisions, frequencies)
  local m = {}

  m.startfreq = startfreq
  m.startx = startx
  m.starty = starty
  m.collisions = collisions
  m.frequencies = frequencies

  setmetatable(m, { __index = Map })

  return m
end

function Map.read(path)
  print('loading ' .. path)
  local data = love.filesystem.read(path)

  local line = data:gmatch('([^\n]+)\n?')

  local startfreq = tonumber(line())
  local startx = tonumber(line())
  local starty = tonumber(line())

  local palette = {}
  for i=1,tonumber(line()) do
    palette[i] = Map.masterTiles[line()]
  end

  local collisions = {}
  for row in line():gmatch('([^;]+);?') do
    local rowData = {}
    for item in row:gmatch('([^,]+),?') do
      table.insert(rowData, item == '1')
    end
    table.insert(collisions, rowData)
  end

  local frequencies = FrequencySet.newFrequencySet()
  local tilemaps = {}
  while true do
    local freq = line()
    if freq == nil then break end
    freq = tonumber(freq)

    local distance = tonumber(line())
    local musicfile = line()
    local frequency = Frequency.newFrequency(freq, distance, musicfile)

    local tiles = {}
    for row in line():gmatch('([^;]+);?') do
      local rowData = {}
      for item in row:gmatch('([^,]+),?') do
        local tileid = tonumber(item)
        table.insert(rowData, (tileid > 0 and palette[tileid]) or Map.noneTile)
      end
      table.insert(tiles, rowData)
    end
    frequency.tilemap = tiles
    table.insert(frequencies.frequencies, frequency)
  end

  return Map.newMap(startfreq, startx, starty, collisions, frequencies)
end

function Map:update(freq)
  self.frequencies:update(freq)
end

function Map:draw(globalState, freq, xoff, yoff)
  local closest = self.frequencies:maxProximityFrequency(freq)
  if closest then
    for y,row in ipairs(closest.tilemap) do
      for x,item in ipairs(row) do
        if item ~= Map.noneTile then
          love.graphics.draw(item, x*16+xoff - 16, y*16+yoff - 16)
        end
      end
    end
  end
end

function Map:drawNoise(globalState, freq)
  self.frequencies:drawNoise(globalState, freq)
end

function Map:stop()
  self.frequencies.noiseSource:stop()
  self.frequencies.noiseSource:release()
  for f,frequency in ipairs(self.frequencies.frequencies) do
    frequency.source:stop()
    frequency.source:release()
  end
end

return Map
