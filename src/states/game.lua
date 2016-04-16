local game = {}

gravity = vector(0, 300)

tileWidth = 64

tileSet = {
	[0] = {0,20,20},
	[1] = {10,200,10}
}

tiles = {
	[0] = {collides = false},
	[1] = {collides = true}
}

map = {
	{0,0,0,0,0},
	{1,1,1,1,0},
	{1,0,0,0,0},
	{0,1,0,0,1},
	{0,0,0,0,1},
	{1,1,1,1,1}
}

function mapAt(v)
	local v = v / tileWidth
	local x = math.floor(v.x)
	local y = math.floor(v.y)
	if map[y] then
		return map[y][x]
	end
end

function corners(o)
	return {o.pos, o.pos+vector(o.scale.x, 0), o.pos+o.scale, o.pos+vector(0,o.scale.y)}
end

List = {}

setmetatable(List, {__call = function(...) return List:new(...) end})

List.__index = function(t, k)
	if rawget(List, k) then return List[k] end
	return function(t, ...)
		for i,v in ipairs(t.items) do
			if v[k] and type(v[k]) == "function" then
				v[k](v,...)
			end
		end
	end
end

function List:new(t)
	local o = {items = {}}
	
	if t then
		if getmetatable(t) == self then
			o.items = t.items
		else
			o.items = t
		end
	end
	
	return setmetatable(o, self)
end

function List:add(o)
	table.insert(self.items, o)
end

function List:remove(self, o)
	for i = #self.items,1,-1 do
		if self.items[i] == o then
			table.remove(self.items, i)
		end
	end
end

player =
{
	pos = vector(200,220),
	vel = vector(0,0),
	accel = vector(0,0),
	scale = vector(32,32),
	colour = {255,0,0,150},
	speed = 100,
	jump = 200
}

function player:standing()
	for i,v in ipairs(corners(self)) do
		local tile = mapAt(v)
		print(tile)
		if tile then
			if tiles[tile].collides then
				print("Colliding!")
				return true
			end
		end
	end
end

function player:check(delta)
	local oldpos = self.pos
	local newpos = oldpos + delta
	self.pos = newpos
	
	-- if there are no collisions
	-- return newpos
	local standing = self:standing()
	
	self.pos = oldpos
	
	if not standing then
		return true
	end
end

function player:update(dt)
	--self.vel = self.vel + (self.accel * dt)
	self.vel = self.vel + (gravity * dt)
	local offset = (self.vel * dt)
	
	
	local xOffset = vector(offset.x, 0)
	if love.keyboard.isDown("right") then
		xOffset = xOffset + (vector(self.speed,0) * dt)
	elseif love.keyboard.isDown("left") then
		xOffset = xOffset + (vector(-self.speed,0) * dt)
	end
	
	if self:check(xOffset) then
		self.pos.x = self.pos.x+xOffset.x
	else
		self.vel.x = 0
	end
	
	local yOffset = vector(0, offset.y)
	
	if self:check(yOffset) then
		self.pos.y = self.pos.y + yOffset.y
	else
		self.vel.y = 0
	end
	
	--self.vel = self.vel + (-self.vel:normalized()*dt)
	
	
end

function player:keypressed(key)
	if key == "space" then
		self.vel.y = -self.jump
	end
end

function player:draw()
	love.graphics.setColor(self.colour)
	love.graphics.rectangle("fill",self.pos.x,self.pos.y,self.scale.x,self.scale.y)
end

function game:init()
	self.objects = List()
	
	self.objects:add(player)
end

function game:update(dt)
	self.objects:update(dt)
end

function game:keypressed(key)
	self.objects:keypressed(key)
end

function game:draw()
	
	for y = 1,#map do
		for x = 1,#map[1] do
			love.graphics.setColor(tileSet[map[y][x]])
			love.graphics.rectangle("fill", x*tileWidth, y*tileWidth, tileWidth, tileWidth)
		end
	end
	
	self.objects:draw()
end

return game