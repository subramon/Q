local expander_approx_frequent = require 'Q/OPERATORS/APPROX/FREQUENT/lua/expander_approx_frequent'

local function approx_frequent(x, min_freq, err)
  assert(type(x) == 'lVector', 'x must be a lVector')
  assert(type(min_freq) == 'number' and min_freq > 0,
         'min_freq must be a positive number')
  assert(type(err) == 'number' and err > 0 and min_freq > err,
         'err must be a positive number less than min_freq')

  return expander_approx_frequent(x, min_freq, err)
end
require('Q/q_export').export('approx_frequent', approx_frequent)

return approx_frequent
