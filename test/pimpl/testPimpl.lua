require "pimpl"
local util = require 'pegparser.util'

local dir = util.getPath(arg[0]) .. '/test'
if arg[1] then
  dir = util.getPath(arg[1])
end

util.testYes(dir .. '/yes/', 'pimpl', pimpl)
util.testNo(dir .. '/no/', 'pimpl', pimpl)