// Place globals in this file 
int g_foobar;
int g_halt;
int g_webserver_interested; 
// 1 => webserver is interested in acquiring Lua state 
int g_L_status; // values as described below 
// 0 => Lua state is free 
// 1 => Master owns Lua State 
// 2 => WebServer owns Lua State 
// XX int g_slave_active;
