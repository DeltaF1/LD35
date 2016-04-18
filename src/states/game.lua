local game = {}

gravity = vector(0, 600)

tileWidth = 34

tileSet = {
	[0] = {0,20,20},
	[1] = {10,200,10},
}

tiles = {
	[0] = {collides = false},
	[1] = {collides = true},
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
			if (y + 1) % 2 == 0 then
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
			if y == 1 or y ==h or x ==1 or x == w then
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

mapcast_debug_tiles = {}

function mapcast(start, finish)
	local x0, y0 = (start/tileWidth):floor():unpack()
	local x1, y1 = (finish/tileWidth):floor():unpack()
	
	local dx = math.abs(x1 - x0)
	local dy = math.abs(y1 - y0)
	
	local x,y = x0,y0
	
	local sx = x0 > x1 and -1 or 1
	local sy = y0 > y1 and -1 or 1
	
	local tilesToCheck = {}
	
	if dx > dy then
		err = dx / 2
		while x ~= x1 do
			table.insert(tilesToCheck, {x,y})
			err = err - dy
			if err < 0 then
				y = y + sy
				err = err + dx
			end
			x = x + sx
		end
	else
		err = dy / 2
		while y ~= y1 do
			table.insert(tilesToCheck, {x,y})
			err = err - dx
			if err < 0 then
				x = x + sx
				err = err + dy
			end
			y = y + sy
		end
	end
	table.insert(tilesToCheck, {x,y})
	
	for i = 1,#tilesToCheck do
		local x,y = tilesToCheck[i][1], tilesToCheck[i][2]
		table.insert(mapcast_debug_tiles, {x*tileWidth, y*tileWidth})
	end
	
	for i = 1,#tilesToCheck do
		
		local coords = tilesToCheck[i]
		local x,y = coords[1], coords[2]
		
		if map[y] then
			local tile = map[y][x]
			if tile then
				if tiles[tile].collides then
					return coords
				end
			end
		end
	end
end

function posToMapPos(vec)
	return (vec/tileWidth):floor()
end

function mapPosToPos(vec)
	return vec*tileWidth
end

function neighbours(tile)
	local t = {}
	for _, off in {vector.left, vetor.right, vector.up, vector.down} do
		local x,y = tile.x + off.x, tile.y+off.y
		
		if map[y] and map[y][x] then
			table.insert(t, vector(x,y))
		end
	end
	return t
end

Node = class{}

function Node:init(pos)
	self.pos = pos
end

function buildNodes()
	nodes = {}
	for y = 1,#map do
		for x = 1,#map[1] do
			
		end
	end
end

function path(start, finish)
	local start, finish = posToMapPos(start), posToMapPos(finish)
	
	local closed = {}
	local open = {start}
	local cameFrom = {}
	local gScore = {}
	
end

--[[
function mapcast(start, finish)
	local x0, y0 = start:floor():unpack()
	local x1, y1 = finish:floor():unpack()
	
	local dx = x1 -x0
	local dy = y1 - y0
	
	local m = dy / dx
	
	for x = x0, x1, tileWidth*sign(dx) do
		local y = (m*x) + y0			
		
		table.insert(mapcast_debug_tiles, {x,y})
		
		local tile = mapAt(vector(x, y))
		
		if tiles[tile] and tiles[tile].collides then
			return {x,y}
		end
	end
end
--]]
--[[
function mapcast(start, finish)
	local tilesToCheck = {}
	
	local dx = finish.x - start.x
	local dy = finish.y - start.y
	
	local D = dy - dx
	
	local y = start.y
	
	for x = start.x, (finish.x - 1) do
		table.insert(tilesToCheck, {x,y})
		
		if D >= 0 then
			y = y + tileWidth
			D = D - dx
		end
		D = D + dy
	end
end
--]]
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
		jumpHeight = 150,
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

function Mobile:update(dt)
	self.vel = self.vel + (gravity * dt)
	
	self.facing = vector(self.vel.x, 0)
	
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
	
	self.center = self.pos + (self.scale/2)
end

function Mobile:jump()
	if self:standing() then
		self.vel.y = -self.jumpHeight
	end
end

function Mobile:draw()
	love.graphics.setColor(self.colour)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.scale.x, self.scale.y)
end

function Mobile:colliding()
	for i,v in ipairs(corners(self)) do
		local tile = mapAt(v)
		if tile then
			if tiles[tile].collides then
				return true
			end
		end
	end
end

function Mobile:standing()
	return not self:check(vector(0,1))
end

function Mobile:check(delta)
	local oldpos = self.pos
	local newpos = oldpos + delta
	self.pos = newpos
	
	-- if there are no collisions
	-- return newpos
	local standing = self:colliding()
	
	self.pos = oldpos
	
	if not standing then
		return true
	end
end

Monster = class{__includes=Mobile}

Monster.exclaimFont = love.graphics.newFont("assets/fonts/FFFFORWA.TTF", 20)

function Monster:init(...)
	Mobile.init(self, ...)
	dir = love.math.random() > 0.5 and 1 or -1
	self.vel = vector(self.speed * dir, 0)
	self.fov = math.pi/2
	self.sightDistance = tileWidth * 7
	self.alertAmount = 0
	self.alertTimer = 0
end

function Monster:inSight(obj)
	local ray = obj.pos - self.pos
	
	return ray:len() <= self.sightDistance and
		sign(self.facing.x) == sign(ray.x) and
		self.facing:angleTo2(ray) < (self.fov/2) and
		not mapcast(self.center, obj.center)
		
end

function Monster:update(dt)
	Mobile.update(self, dt)
	
	self.ray = player.center - self.center
	
	if not self.alerted then
		if self.vel.x == 0 then self.vel.x = self.speed end
		if math.random() > 0.99 then
			self.vel.x = -self.vel.x	
		end
		if self.alertAmount >= player.alertMax then
			self.alerted = true
		end
			
		if self:inSight(player) then -- Check to see if there are obstructions
			--self.colour = {255,0,0,255}
			-- be alerted
			self.alertAmount = self.alertAmount + dt * 3
		else
			self.colour = self.stats.colour
			if self.alertAmount > 0 then self.alertAmount = math.max(0, self.alertAmount - dt) end
		end
		
	else
		-- A* D:
		
		if self:inSight(player) then
			self.alertTimer = 10
		else
			self.alertTimer = self.alertTimer - dt
		end
		
		if self.alertTimer <= 0 then
			self.alerted = false
		end
		
		local dir = sign(self.ray.x)
		
		self.vel.x = self.speed * dir
		
		if self:standing() then
			game.timer.after(0.1, function()
				local nextFloor = tiles[mapAt(self.center + (vector(tileWidth * dir, (self.scale.y/2)+5)))]
				local inFront = tiles[mapAt(self.center + (vector(tileWidth*dir, 0)))]
				
				if not nextFloor.collides or inFront.collides then
					self:jump()
				end
			end)
		end
	end
end


function Monster:draw()
	Mobile.draw(self)
	--love.graphics.line(self.center.x, self.center.y, self.center.x+self.ray.x, self.center.y+self.ray.y)
	--love.graphics.setColor(0,0,255)
	--love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.facing.x, self.pos.y+self.facing.y)
	--love.graphics.print(tostring(self.alertAmount), self.pos.x, self.pos.y)
	
	love.graphics.setColor(255,255,255)
	
	if self.alertAmount > 0 then
		local ratio = (self.alertAmount/player.alertMax)
		local r = 255*ratio
		if ratio <= 0.9 then g = 255*ratio
		else g = 0 end
		love.graphics.setColor(r,g or 0,0)
		love.graphics.setFont(Monster.exclaimFont)
		love.graphics.print(ratio > 0.9 and "!" or "?",self.pos.x+(self.scale.x/2), self.pos.y-self.scale.y-5)
	end
	
	if not self.alerted then
		love.graphics.setColor(0,0,255)
		local theta = self.fov/2
		
		love.graphics.push()
		love.graphics.scale(sign(self.facing.x), 1)
		--love.graphics.translate(-self.center.x, -self.center.y)
		
		love.graphics.translate(sign(self.facing.x)*self.center.x, self.center.y)
		love.graphics.arc("line",0,0, self.sightDistance, theta, -theta)
		love.graphics.pop()
	end
end


player = Mobile(
	vector(100,170),
	vector(32,32),
	{
		colour = {220,0,0,255},
		speed = 200,
		jumpHeight = 320,
		alertMax = 1
	}
)

function player:update(dt)	
	if love.keyboard.isDown("right") then
		self.xOffset = self.xOffset + (self.speed * dt)
	end
	if love.keyboard.isDown("left") then
		self.xOffset = self.xOffset + (-self.speed * dt)
	end
	
	if self.alertMax > 1 then
		self.alertMax = math.max(self.alertMax - (dt/5), 1)
	end
	
	Mobile.update(self,dt)
end

function player:attack()
	-- make laser pew pew
	
	for i = 1,#game.objects.items do
		local obj = game.objects.items[i]
		if obj ~= self then
			if obj:inSight(self) then
				obj.alerted = true
				obj.alertAmount = self.alertMax
			end
		end
	end
end

function player:keypressed(key)
	if key == "space" then
		self:jump()
	elseif key == "lctrl" then
		self:attack()
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
	--local troll = Mobile(vector(250, 100), nil, Monsters.Troll)
	--self.objects:add(troll)
	
	for i = 1,20 do
		local mob = Monster(vector(i*5*tileWidth, 150), vector(love.math.random(20,60), love.math.random(20,60)), {speed=love.math.random(100,150),jumpHeight=love.math.random(300, 500),colour={love.math.random(255),love.math.random(255),love.math.random(255),255}})
		if not mob:colliding() then
			self.objects:add(mob)
		else
			i = i + 1
		end
	end
	
	self.timer = require "hump.timer"
	self.camera = (require "hump.camera").new(player.pos.x, player.pos.y)
end

function game:update(dt)
	mapcast_debug_tiles = {}
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
				for j = 1,#self.objects.items do
					local obj = self.objects.items[j]
					if obj.alertAmount then
						obj.alertAmount = obj.alertAmount*0.25
						obj.alerted = nil
					end
				end
				player.alertMax = 10
				
				self.timer.tween(0.5, player.pos, {x=obj.pos.x, y=obj.pos.y}, "linear", function()
					obj.active = false
					player:init(obj.pos, obj.scale, obj.stats)
					self.objects:remove(obj)
				end)
				self.timer.tween(0.5, player.colour, {[4]=0})
				break
			end
			
		end
	end
end

function game:keypressed(key)
	self.objects:keypressed(key)
	
	if key == "r" then genRandMap() end
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
	--[[
	love.graphics.setColor(200,10,10)
	for i = 1,#mapcast_debug_tiles do
		local coords = mapcast_debug_tiles[i]
		
		love.graphics.rectangle("line", coords[1], coords[2], tileWidth, tileWidth)
	end
	--]]
	self.camera:detach()
end

return game