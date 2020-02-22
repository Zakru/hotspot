local Map = require('Map')
local Radio = require('Radio')
local fade = require('fade')
local player = require('player')
local creditsState = require('creditsState')

local gameState = {}

local radio
local map

local playerVelx
local playerVely
local playerJumpTimer
local jumpWasPressed

local levelnum = 0
local nextlevel = 4
local levels = {
  'level_1',
  'level_2',
  'level_3',
  'level_4',
}

function gameState.load(globalState)
  radio = Radio.newRadio()
  radio.frequency = 1050
  radio:update()
  radio.source:play()

  levelnum = nextlevel
  map = Map.read(levels[levelnum])
  map.frequencies.noiseSource:play()

  player.x = map.startx
  player.y = map.starty
  playerVelx = 0
  playerVely = 0
  playerJumpTimer = 0
  jumpWasPressed = false
end

function gameState.unload(globalState)
  map:stop()
end

function gameState.update(globalState, dt)
  dt = math.min(dt, 0.1)
  local moved = false
  if love.keyboard.isDown('k') then
    moved = true
    radio:setFrequency(radio.frequency + dt * 200)
  end
  if love.keyboard.isDown('j') then
    moved = true
    radio:setFrequency(radio.frequency - dt * 200)
  end

  if not moved then
    local closest = map.frequencies:maxProximityFrequency(radio.frequency)
    if closest then
      radio:setFrequency(closest:snap(radio.frequency, 200 * dt))
    end
  end

  -- Player movement and collision stuff
  if playerJumpTimer > 0 then
    playerVely = playerVely + 32 * dt
    playerJumpTimer = playerJumpTimer - dt
  else
    playerVely = playerVely + 64 * dt
  end

  local playerMoved = false
  if love.keyboard.isDown('d') or love.keyboard.isDown('right') then
    playerMoved = true
    if playerVelx < 0 then
      playerVelx = playerVelx + 64 * dt
    else
      playerVelx = math.min(playerVelx + 32 * dt, 16)
    end
  end
  if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
    playerMoved = true
    if playerVelx > 0 then
      playerVelx = playerVelx - 64 * dt
    else
      playerVelx = math.max(playerVelx - 32 * dt, -16)
    end
  end

  if not playerMoved then
    if playerVelx < 0 then
      playerVelx = math.min(playerVelx + 32 * dt, 0)
    elseif playerVelx > 0 then
      playerVelx = math.max(playerVelx - 32 * dt, 0)
    end
  end

  if not player.tryGo(map, player.x + playerVelx*dt, player.y, radio.frequency) then
    playerVelx = 0
  end
  local ground = false
  if not player.tryGo(map, player.x, player.y + playerVely*dt, radio.frequency) then
    if playerVely > 0 then
      ground = true
    else
      playerJumpTimer = 0
    end
    playerVely = 0
  end

  local jump = love.keyboard.isDown('space') or love.keyboard.isDown('w') or love.keyboard.isDown('up')
  if ground and jump and not jumpWasPressed then
    playerVely = -16
    playerJumpTimer = 0.5
  elseif not jump then
    playerJumpTimer = 0
  end
  jumpWasPressed = jump

  if player.tileInside(map, radio.frequency) == Map.masterTiles['black_flag'] and fade.fading ~= 1 then
    nextlevel = levelnum + 1
    fade.begin(2,2)
  end
  if (player.y > #map.collisions or player.tileInside(map, radio.frequency) == Map.masterTiles['red_single']) and fade.fading ~= 1 then
    fade.begin(2,2)
  end

  radio:update()
  map:update(radio.frequency)

  fade.update()
  radio.source:setVolume(1 - fade.depth())

  if fade.isFadedOut() then
    if nextlevel == #levels + 1 then
      globalState.changeState(creditsState)
    else
      globalState.changeState(gameState)
      fade.fading = -1
    end
  end
end

function gameState.draw(globalState)
  love.graphics.clear(1,1,1,1)

  map:draw(globalState, radio.frequency)
  map:drawNoise(globalState, radio.frequency)

  player.draw(globalState, map)

  fade.draw(globalState)
end

return gameState
