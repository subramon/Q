-- NO_OP
require 'init'

register_shcb (function() print('cb1') end)
register_shcb (function() print('cb2') end)

--print(g_qtypes.I8.short_code)
shutdown()
