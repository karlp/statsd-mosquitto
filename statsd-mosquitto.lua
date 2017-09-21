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
  namespace = "mosq.stats" -- default: none
})

-- how to do closures properly? no idea....
local function delta(a, x)
	local rval = nil
	if x.storage then
		rval =  a-x.storage
	end
	x.storage = a
	return rval
end

local tmaps = {
	["broker/store/messages/count"] = {f=statsd.gauge},
	["broker/store/messages/bytes"] = {f=statsd.gauge},
	["broker/bytes/received"] = {f=statsd.counter, pre=delta},
	["broker/bytes/sent"] = {f=statsd.counter, pre=delta},
	["broker/messages/received"] = {f=statsd.counter, pre=delta},
	["broker/messages/sent"] = {f=statsd.counter, pre=delta},
	["broker/clients/total"] = { f = statsd.gauge},
	["broker/load/publish/received/1min"] = {f=statsd.gauge},
	["broker/load/publish/received/5min"] = {f=statsd.gauge},
	["broker/load/publish/received/15min"] = {f=statsd.gauge},
	["broker/load/publish/sent/1min"] = {f=statsd.gauge},
	["broker/load/publish/sent/5min"] = {f=statsd.gauge},
	["broker/load/publish/sent/15min"] = {f=statsd.gauge},
}
local client = mqtt.new()

client.ON_CONNECT = function()
        print("connected")
	for t,o in pairs(tmaps) do
		print("subscribing to ", t)
	        client:subscribe("$SYS/" .. t)
	end
end

client.ON_MESSAGE = function(mid, topic, payload)
	-- strip $SYS/ from the name
	topic = topic:sub(6)
        print(topic, payload)
	local e = tmaps[topic]
	if e then
		local val = payload
		if e.pre then val = e.pre(payload, e) end
		print("publishing val", val)
		if val then e.f(statsd, topic, val) end
	end
end

local broker = arg[1] -- defaults to "localhost" if arg not set
client:connect(broker)
client:loop_forever()
