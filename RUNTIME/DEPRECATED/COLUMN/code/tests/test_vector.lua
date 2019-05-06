local ffi = require "ffi"
require "globals"
local Vector = require "Vector"
local function describe()
    print "hello"
end
local function it()
    print "bye"
end

g_valid_types = {}
g_valid_types['i'] = 'int'
g_valid_types['f'] = 'float'
g_valid_types['d'] = 'double'
g_valid_types['c'] = 'char'
g_chunk_size = 15


describe( "Vectors ", function()
        describe("when files are input", function()
                it("uses global chunk size when size not specified", function()
                        local v1 = Vector{field_type='i',
                            filename='test_in.txt',
                        write_vector=true}
                        local x, x_size = v1:chunk(0)
                        assert.are.same(x_size, g_chunk_size)
                    end)
                it("uses specified chunk size when size is specified", function(chnk_size)
                        chnk_size = chnk_size or 64
                        local v1 = Vector{field_type='i',
                            filename='test_in.txt',
                            chunk_size=chnk_size,
                        write_vector=true}
                        local x, x_size = v1:chunk(0)
                        if v1:length() >= chnk_size then
                            assert.are.same(x_size, chnk_size)
                        else
                            assert.are_not.equals(x_size, chnk_size)
                        end
                    end)
                pending("file size is not a multiple of field size")

            end)
        describe("when files are output", function()
                pending("spy on bit vector sending correct output")
                pending("expected file length matches actual")

            end)
        pending("file write loop match")
        pending(" input from generators")


    end)

