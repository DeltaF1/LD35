local game = {}

gravity = vector(0, 600)

tileWidth = 34

tileSet = {
	[0] = {0,20,20},
	[1] = {10,200,10}
}

tiles = {
	[0] = {collides = false},
	[1] = {collides = true}
}

map = {
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
}

function genRandMap(w,h)
	w = w or 100
	h = h or 10
	map = {}
	
	for y = 1,h do
		map[y] = {}
		local platform = false
		for x = 1,w do
			if y % 2 == 0 then
				if not platform then
					if love.math.random() > 0.9 then
						platform = not platform
					end
				else
					if love.math.random() > 0.5 then
						platform = not platform
					end
				end
			end
			
			local tile = 0
			if y == 1 or y ==h then
				tile = 1
			end
			if platform then tile = 1 end
			map[y][x] = tile
		end
	end
	
end

genRandMap()

function mapAt(v)
	local v = v / tileWidth
	local x = math.floor(v.x)
	local y = math.floor(v.y)
	if map[y] then
		return map[y][x]
	end
end

function corners(o)
	local t = {}
	for x = o.pos.x, o.pos.x+o.scale.x, (o.scale.x/(math.ceil(o.scale.x/tileWidth))) do
		for y = o.pos.y, o.pos.y+o.scale.y, (o.scale.y/(math.ceil(o.scale.y/tileWidth))) do
			table.insert(t, vector(x,y))
		end
	end
	return t
end

function mapcast(start, finish)
	local tilesToCheck = {}
	
	localdx = finish.x - start.x
	local dy = finish.y - start.y
	
	local D = dy - dx
	
	local y = start.y
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

function List:remove(o)
	for i = #self.items,1,-1 do
		if self.items[i] == o then
			table.remove(self.items, i)
		end
	end
end

Monsters = {
	Troll = {
		scale = vector(30,60),
		colour = {10,230,0,255},
		speed = 50,
		jump = 150,
	}
}

Mobile = class{}

function Mobile:init(pos, scale, stats)
	self.pos = pos
	self.scale = scale
	self.vel = vector()
	self.accel = vector()
	self.xOffset = 0
	self.yOffset = 0
	self.stats = stats
	self.active = true
	for k,v in pairs(stats) do
		self[k] = copy3(v)
	end
end

function Mobile:contains(point)
	if point.x > self.pos.x and point.x < self.pos.x+self.scale.x and
		point.y > self.pos.y and point.y < self.pos.y+self.scale.y then
		return true
	end
end

function Mobile:draw()
	love.graphics.setColor(self.colour)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.scale.x, self.scale.y)
end

function Mobile:standing()
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

function Mobile:check(delta)
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

Monster = class(Mobile)

function Monster:update(dt)
	self.facing = self.vel:normalized()
end

player = Mobile(
	vector(100,170),
	vector(32,32),
	{
		colour = {220,0,0,255},
		speed = 200,
		jump = 320
	}
)

setmetatable(player, Mobile)

function player:update(dt)	
	if love.keyboard.isDown("right") then
		self.xOffset = self.xOffset + (self.speed * dt)
	end
	if love.keyboard.isDown("left") then
		self.xOffset = self.xOffset + (-self.speed * dt)
	end
	
	Mobile.update(self,dt)
end

function Mobile:update(dt)
	self.vel = self.vel + (gravity * dt)
	
	self.yOffset = self.yOffset + (self.vel.y * dt)
	self.xOffset = self.xOffset + (self.vel.x * dt)
	
	if self:check(vector(self.xOffset, 0)) then
		self.pos.x = self.pos.x+self.xOffset
	else
		self.vel.x = 0
	end
	
	if self:check(vector(0, self.yOffset)) then
		self.pos.y = self.pos.y + self.yOffset
	else
		self.vel.y = 0
	end
	
	self.xOffset, self.yOffset = 0,0
end

function player:keypressed(key)
	if key == "space" and not self:check(vector(0,1)) then
		self.vel.y = -self.jump
	end
end

function player:draw()
	love.graphics.setColor(self.colour)
	love.graphics.rectangle("fill",self.pos.x,self.pos.y,self.scale.x,self.scale.y)
end

function game:init()
	self.objects = List()
	
	screenWidth, screenHeight = love.graphics.getDimensions()
	
	
	self.objects:add(player)
	local troll = Mobile(vector(250, 100), nil, Monsters.Troll)
	self.objects:add(troll)
	
	for i = 1,20 do
		self.objects:add(Mobile(vector(i*5*tileWidth, 150), vector(love.math.random(20,60), love.math.random(20,60)), {speed=love.math.random(100,150),jump=love.math.random(300, 500),colour={love.math.random(255),love.math.random(255),love.math.random(255),255}}))
	end
	
	self.timer = require "hump.timer"
	self.camera = (require "hump.camera").new(player.pos.x, player.pos.y)
end

function game:update(dt)
	self.timer(dt)
	self.objects:update(dt)
	self.camera:lookAt(player.pos.x, player.pos.y)
end

function game:mousepressed(x,y, button)
	x,y = self.camera:worldCoords(x,y)
	for i = 1,#self.objects.items do
		local obj = self.objects.items[i]
		
		if obj.active and obj ~= player then
			
			
			if obj:contains(vector(x,y)) then
				self.timer.tween(0.5, player.pos, {x=obj.pos.x, y=obj.pos.y}, "linear", function()
					obj.active = false
					player:init(obj.pos, obj.scale, obj.stats)
					self.objects:remove(obj)
				end)
				self.timer.tween(0.5, player.colour, {[4]=0})
			end
		end
	end
end

function game:keypressed(key)
	self.objects:keypressed(key)
end

function game:draw()
	
	self.camera:attach()
	for y = 1,#map do
		for x = 1,#map[1] do
			love.graphics.setColor(tileSet[map[y][x]])
			love.graphics.rectangle("fill", x*tileWidth, y*tileWidth, tileWidth, tileWidth)
		end
	end
	
	self.objects:draw()
	self.camera:detach()
end

return game