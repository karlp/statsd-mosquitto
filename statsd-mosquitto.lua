#!/usr/bin/env lua
--[[
--statsd client for mosquitto broker stats
--idea is useable with netdata
--Considered to be available under your choice of, (at your preference)
--  MIT/ISC/X11/BSD 2clause
-- Karl Palsson <karlp@tweak.net.au> Sept 2017
--]]

local Statsd = require("statsd")
local mqtt = require("mosquitto")

-- create statsd object, which will open up a persistent port
local statsd = Statsd({
  --host = "stats.mysite.com" -- default: 127.0.0.1
  --port = 8888 -- default: 8125
  namespace = "t.m.o.stats" -- default: none
})

local client = mqtt.new()

client.ON_CONNECT = function()
        print("connected")
        client:subscribe("$SYS/#")
end

client.ON_MESSAGE = function(mid, topic, payload)
	-- strip $SYS for the name
	topic = topic:sub(5)
        print(topic, payload)
	-- TODO - which is the right statsd type for which metric?
	if topic:find("broker/clients") then
		statsd:gauge(topic, payload)
	end
	if topic:find("broker/load") then
		statsd:gauge(topic, payload)
	end
end

local broker = arg[1] -- defaults to "localhost" if arg not set
client:connect(broker)
client:loop_forever()
