require "pimpl"
local lfs = require "lfs"
local relabel = require "relabel"

local function assertValidFile(filename, grammar)
    local file = io.open(filename, 'r')
    local content = file:read('*all')
    res, lab, errpos = grammar:match(content)

    if res then
        print(filename .. ": success.")
    else
        l, c = relabel.calcline(content, errpos)
        print(filename .. ": error in line " .. l .. ", col " .. c .. ".")
    end
end

local function runAllTests()
    for fname in lfs.dir("./test/yes/") do
        if fname ~= '.' and fname ~= '..' then
            assertValidFile('./test/yes/' .. fname, pimpl)
        end
    end
end

runAllTests()