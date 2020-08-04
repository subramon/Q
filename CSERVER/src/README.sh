#/bin/bash
set -e 
# Start the server on port 8080
port=8080
echo "Quick test of server"
echo ' Q.nop("hello my world")' > _x.lua 
curl -d @_x.lua --url "localhost:$port/DoString"
rm _x.lua 
echo "All done"
