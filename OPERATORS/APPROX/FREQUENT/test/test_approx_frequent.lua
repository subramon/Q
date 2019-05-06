-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local ffi    = require 'Q/UTILS/lua/q_ffi'

local tests = {}

tests.t1 = function()
  local x_bare = {}
  local freq_ids = {}
  local freq_counts = {}

  local total_nums = 200000
  local min_freq = 10000
  local err = 10
  local num_freq = 10
  local freq_len = num_freq + (total_nums - min_freq * num_freq);

  for i = 0, num_freq - 1 do
    freq_ids[i] = i
    freq_counts[i] = min_freq
  end
  for i = num_freq, freq_len - 1 do
    freq_ids[i] = i
    freq_counts[i] = 1
  end

  local per = num_freq * 2
  for i = 0, total_nums / per - 1 do
    for j = 0, num_freq - 1 do
      x_bare[i * per + j * 2] = freq_ids[j]
      x_bare[i * per + j * 2 + 1] = freq_ids[(i + 1) * num_freq + j]
    end
  end

  local siz = #x_bare + 1
  for i = 0, siz - 1 do
    x_bare[siz - i] = x_bare[siz - i - 1]
  end

  local x = Q.mk_col(x_bare, "I4")
  local y, f, out_len = Q.approx_frequent(x, min_freq, err):eval()
  local _, y_c, _ = y:get_all()
  local _, f_c, _ = f:get_all()
  y = ffi.cast("int*", y_c)
  f = ffi.cast("uint64_t*", f_c)

  local j = 0
  local i = 0
  while (i < freq_len and j < out_len) do
    if (freq_ids[i] == y[j]) then
      assert(tonumber(f[j]) >= min_freq - err, '')
      assert(math.abs(tonumber(f[j]) - freq_counts[i]) <= err, '')
      i = i + 1
      j = j + 1
    elseif (freq_ids[i] < y[j]) then
      assert(freq_counts[i] < min_freq, '')
      i = i + 1
    else
      assert(false, '')
    end
  end
  assert(j >= out_len, '')
  while i < freq_len do
    assert(freq_counts[i] < min_freq, '')
    i = i + 1
  end
end

return tests
