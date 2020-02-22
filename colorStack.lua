local colorStack = {}

local stack = {}

function colorStack.push(r,g,b, a)
  table.insert(stack, 1, {love.graphics.getColor()})
  love.graphics.setColor(r,g,b, a)
end

function colorStack.pop()
  love.graphics.setColor(unpack(stack[1]))
  table.remove(stack, 1)
end

return colorStack
