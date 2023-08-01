### CIDR Notation

A way of defining a subnet and its size with a "mask", a smaller mask = more  address bits usable by the subnet & more IPs in the range. Most common ones:
  + `192.0.2.1/32` (a single IP address, `192.0.2.1`) netmask = `255.255.255.255`
  + `192.0.2.1/24` (255 IPs from `192.0.2.0`-`192.0.2.255`) netmask = ` 255.255.255.0`
  + `192.0.2.1/16` (65,536 IPs from `192.0.0.0` - `192.0.255.255`) netmask = `255.255.0.0`
  + `192.0.2.1/8` (16,777,216 IPs from `192.0.0.0` - `192.255.255.255`) netmask = `255.0.0.0`
  + `0.0.0.1/0` (4,294,967,296 IPs from `0.0.0.0` - `255.255.255.255`) netmask = `0.0.0.0`
  + IPv6 CIDR notation is also supported e.g. `2001:DB8::/64`
 
https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing

To people just getting started `192.0.2.1/32` may seem like a weird and confusing way to refer to a single IP.  This design is nice though because it allows peers to expose multiple IPs if needed without needing multiple notations.  Just know that anywhere you see something like `192.0.2.3/32`, it really just means `192.0.2.3`.
