GameState = require "hump.gamestate"
Timer = require "hump.timer"
vector = require "hump.vector"

local _setColor = love.graphics.setColor
function love.graphics.setColor(r,g,b,a)
	if type(r) == "table" then
		_setColor(unpack(r))
	else
		_setColor(r,g,b,a)
	end
end

function love.load()
	GameState.registerEvents()
	
	states = {}
	
	for i,v in ipairs(love.filesystem.getDirectoryItems("states")) do
		local name = v:match("^([^.]*)%.")
		if name then
			states[name] = require("states."..name)
		end
	end
	
	GameState.switch(states.game)
end

function love.update(dt)
	Timer.update(dt)
end