-- install chronos with luarocks to run
local q = {}
--local chronos = require("chronos")
CHUNKSIZE = 64
local bench = function(name, func, loops)
    loops=loops or 1000

    --local q0 = chronos.nanotime()
    local q0 = os.clock()
    for i=1,loops do
        func()
    end
    local q1 = os.clock()
    --local q1 = chronos.nanotime()
    local time = q1 - q0
    print (name .. " took " .. time/loops)
end

local create_list = function(size)
    res = {}
    for i=1,size do
        res[i] = math.random()
    end
    return res
end

q['wrap'] = function (arg)
    return coroutine.create(
        function()
            local n = 1
            local res = {}
            while 1 do
                if n > #arg
                    then
                        return res
                    else
                        if #res == CHUNKSIZE then
                            coroutine.yield(res)
                            res = {}
                        else
                            res[#res + 1] = arg[n]
                        end
                    end
                    coroutine.yield(arg[n])
                    n = n + 1
                end
            end)
end

q['add'] = function (arg1, arg2)
    return coroutine.create(
        function()
            while 1 do
                local status1, value1 = coroutine.resume(arg1)
                local status2, value2 = coroutine.resume(arg2)
                if not status1 == status2
                    then
                        error("mismatched")
                    end
                    if not status1
                        then
                            return
                        end
                        coroutine.yield(q.add_basic(value1, value2))
                    end
                end)
end


q['add_basic'] = function(arg1, arg2)
    if #arg1 ~= #arg2 then
        print ("Error: Unequal lengths" .. #arg1 .. " is not same as " .. #arg2)
        return
    end
    res = {}
    for i = 1, #arg1 do
        res[i] = arg1[i] + arg2[i]
    end
    return res
end


local ax = create_list(1000*100)
local bx = create_list(1000*100)

local simple_function = function()
    return q.add_basic(ax, bx)
end

local eval_coroutine = function(coro)
    local ret_vals = {}
    local status, result = true, nil
    while status do
        status, result = coroutine.resume(coro)
        --print( 'hey' )
        for i=1,#result do
            ret_vals[#ret_vals + 1] = result[#result]
        end
    end
end

local simple_single_compound_function = function()
    local t1 = q.add_basic(ax, bx)
    return q.add_basic(ax, t1)
end

local coroutine_single_compound_function = function()
    routine = q.add(q.wrap(ax) , q.add(q.wrap(ax), q.wrap(bx)))
    return eval_coroutine(routine) 
end

local simple_double_compound_function = function()
    local t1 = q.add_basic(ax, bx)
    local t2 = q.add_basic(t1, bx)
    return q.add_basic(ax, t2)
end

local coroutine_double_compound_function = function()
    routine = q.add(q.wrap(ax) , q.add(q.wrap(bx) , q.add(q.wrap(ax), q.wrap(bx))))
    return eval_coroutine(routine)
end

local simple_triple_compound_function = function()
    local t1 = q.add_basic(ax, bx)
    local t2 = q.add_basic(t1, bx)
    local t3 = q.add_basic(t2, ax)
    return q.add_basic(ax, t3)
end

local coroutine_triple_compound_function = function()
    routine = q.add(q.wrap(ax) ,q.add(q.wrap(ax) , q.add(q.wrap(bx) , q.add(q.wrap(ax), q.wrap(bx)))))
    return eval_coroutine(routine)
end

local simple_quad_compound_function = function()
    local t1 = q.add_basic(ax, bx)
    local t2 = q.add_basic(t1, bx)
    local t3 = q.add_basic(t2, ax)
    local t4 = q.add_basic(t3, bx)
    return q.add_basic(ax, t4)
end

local coroutine_quad_compound_function = function()
    routine = q.add(q.wrap(ax), q.add(q.wrap(ax) ,q.add(q.wrap(ax) , q.add(q.wrap(bx) , q.add(q.wrap(ax), q.wrap(bx))))))
    return eval_coroutine(routine)
end

local coroutine_quad_make_compound_function = function()
   routine = q.add(q.wrap(ax), q.add(q.wrap(ax) ,q.add(q.wrap(ax) , q.add(q.wrap(bx) , q.add(q.wrap(ax), q.wrap(bx))))))
   return
    --return eval_coroutine(routine)
end


bench("co routine single ", coroutine_single_compound_function, 1000)
bench("simple single ", simple_single_compound_function, 1000)
bench("co routine double ", coroutine_double_compound_function, 1000)
bench("simple double ", simple_double_compound_function, 1000)
bench("co routine triple ", coroutine_triple_compound_function, 1000)
bench("simple triple ", simple_triple_compound_function, 1000)
bench("co routine quad ", coroutine_quad_compound_function, 1000)
bench("simple quad ", simple_quad_compound_function, 1000)
bench("coroutine quad make alone", coroutine_quad_make_compound_function, 1000)

