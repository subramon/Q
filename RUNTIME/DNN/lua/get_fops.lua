local get_f_fops = function(npl, nI)
  local cnt = 0
  for i = 2, #npl do
    local factor
    if i==#npl then
      factor = 6
    else
      factor = 2
    end
    cnt = cnt + (npl[i-1] * npl[i] * nI * factor)
  end
  return cnt
end

local get_b_fops = function(npl, nI)
  local cnt = 0
  local da_last_fops = npl[#npl] * nI * 5
  local factor
  for i = #npl, 2, -1 do
    local dz_fops = 0
    if i == #npl then
      dz_fops = npl[i] * nI * 7
    end
    local da_prev_fops = npl[i] * npl[i-1] * nI * 2
    if i == 2 then
      da_prev_fops = 0
    end
    local dw_fops = npl[i] * npl[i-1] * nI * 2 + npl[i] * npl[i-1] * 1
    local db_fops = npl[i] * nI + npl[i] * 1
    cnt = cnt + dz_fops + da_prev_fops + dw_fops + db_fops
  end
  return cnt + da_last_fops
end

local get_update_wb_fops = function(npl)
  local cnt = 0
  for i = 2, #npl do
    local w_fops = npl[i-1] * npl[i] * 2
    local b_fops = npl[i] * 2
    cnt = cnt + w_fops + b_fops
  end
  return cnt
end


local test_get_fops = function()

  local npl -- network structure 
  local nI  -- number of instances
  local batch_size

  npl = { 128, 64, 32, 8, 4, 2, 1 }
  nI = 1024 * 1024
  batch_size = 4 * 1024

  local f_fops = 0
  local b_fops = 0
  local wb_fops = 0 

  local num_batches = nI / batch_size
  num_batches = math.ceil(num_batches)

  for i = 0, num_batches-1 do
    local lb = i  * batch_size;
    local ub = lb + batch_size;
    if i == (num_batches-1) then
      ub = nI
    end
    f_fops = f_fops + get_f_fops(npl, (ub - lb))
    b_fops = b_fops + get_b_fops(npl, (ub - lb))
    wb_fops = wb_fops + get_update_wb_fops(npl)

    print("num flops forward pass = " .. tostring(f_fops))
    print("num flops backword pass = " .. tostring(b_fops + wb_fops))
    print("total num flops = " .. tostring(f_fops+b_fops+wb_fops))

    print("batch " .. tostring(i) .. " completed, [" .. tostring(lb) .. ", " .. tostring(ub) .. "]")
  end
  print("===============TOTAL===================")
  print("num flops forward pass = " .. tostring(f_fops))
  print("num flops backword pass = " .. tostring(b_fops + wb_fops))
  print("total num flops = " .. tostring(f_fops+b_fops+wb_fops))
end

test_get_fops()

