local Map = require('Map')
local Radio = require('Radio')
local fade = require('fade')
local player = require('player')
local creditsState = require('creditsState')

local gameState = {}

local radio
local map

local moveInstr
local jumpInstr

local playerVelx
local playerVely
local playerJumpTimer
local jumped
local camTrackX
local camTrackY

local levelnum = 0
local nextlevel = 1
local levels = {
  'level_1',
  'level_2',
  'level_blue_intro',
  'level_blue_parkour',
  'level_blue_drop_test',
  'level_red_intro',
  'level_red_memory_maze',
  'level_green_intro',
  'level_green_drop_sequence',
  'level_green_prank_jump',
  'level_green_blue_switcheroo',
  'level_think_fast',
  'level_blue_switcheroo',
  'level_tower_of_doom',
}

function gameState.load(globalState)
  levelnum = nextlevel
  map = Map.read(levels[levelnum])
  map.frequencies.noiseSource:play()

  radio = Radio.newRadio()
  radio.frequency = map.startfreq
  radio:update()
  radio.source:play()

  player.x = map.startx
  player.y = map.starty
  camTrackX = map.startx * 16
  camTrackY = map.starty * 16
  playerVelx = 0
  playerVely = 0
  playerJumpTimer = 0
  jumpWasPressed = false

  moveInstr = love.graphics.newImage('movement_instructions.png')
  jumpInstr = love.graphics.newImage('jump_instructions.png')
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
  if ground and jump and not jumped then
    playerVely = -16
    playerJumpTimer = 0.5
    jumped = true
  elseif not jump then
    playerJumpTimer = 0
    jumped = false
  end

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

  local w,h = globalState.common.scaledDimensions(globalState)
  local playerScreenX = math.min(math.max(player.x * 16, math.floor(w/2)), #map.collisions[1] * 16 - math.floor(w/2))
  local playerScreenY = math.min(math.max(player.y * 16, math.floor(h/2)), #map.collisions * 16 - math.floor(h/2))
  camTrackX = playerScreenX + (camTrackX - playerScreenX) * math.pow(0.1, dt)
  camTrackY = playerScreenY + (camTrackY - playerScreenY) * math.pow(0.1, dt)
  camTrackX = math.min(math.max(camTrackX, math.floor(w/2)), #map.collisions[1] * 16 - math.floor(w/2))
  camTrackY = math.min(math.max(camTrackY, math.floor(h/2)), #map.collisions * 16 - math.floor(h/2))

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

  local mapWidth = #map.collisions[1] * 16
  local mapHeight = #map.collisions * 16
  local w,h = globalState.common.scaledDimensions(globalState)
  local xoff, yoff
  if mapWidth > w then
    xoff = w / 2 - camTrackX
  else
    xoff = w / 2 - mapWidth / 2
  end
  if mapHeight > h then
    yoff = h / 2 - camTrackY
  else
    yoff = h / 2 - mapHeight / 2
  end

  map:draw(globalState, radio.frequency, xoff, yoff)

  if levelnum == 1 then
    local closest = map.frequencies:maxProximityFrequency(radio.frequency)
    if closest == map.frequencies.frequencies[1] then
      love.graphics.draw(moveInstr, w/2, h/2 + 64, 0, 2, 2, moveInstr:getWidth()/2, moveInstr:getHeight()/2)
    else
      love.graphics.draw(jumpInstr, w/2, h/2 - 64, 0, 2, 2, jumpInstr:getWidth()/2, jumpInstr:getHeight()/2)
    end
  end

  map:drawNoise(globalState, radio.frequency)

  player.draw(globalState, xoff, yoff)

  fade.draw(globalState)
end

return gameState
