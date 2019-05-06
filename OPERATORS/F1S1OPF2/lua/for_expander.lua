
    if type(x) == "lVector" and ( ( type(y) == "number" ) or ( type(y) == "string" ) ) then
        local status, col = pcall(expander_f1f2opf3, vs<<operator>>, x, y)
        if ( not status ) then print(col) end
        assert(status, "Could not execute vs<<operator>>")
        return col
    end
