# Dispersion: a naive proxy that slows things down

Basically, this adds a half-second onto every request that routes through the
proxy.

It needs to be fixed up to slow down the responses, ideally to 56K speeds (i.e.
7KB/s)
