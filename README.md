== statsd-mosquitto

statsd publisher for mosquitto broker stats.  Very primitive, only a few
metrics are published, and it's open ended what sort of metric they should be,
but shows how simple it is to get going.

This works out of the box with netdata for instance: 
![some sample graphs](https://imgur.com/a/Xqudn "Sample graphs")


== Installation

[statsd from luarocks.](https://github.com/stvp/lua-statsd-client)
[lua-mosquitto from luarocks.](https://github.com/flukso/lua-mosquitto)

== Why lua?
So it runs nicely on openwrt/LEDE and other more constrained environments,
where python/node are jumbotron beasts.
