require "pimplAutoLabeled"
local util = require 'pegparser.util'

local dir = util.getPath(arg[0]) .. '/test'
if arg[1] then
  dir = util.getPath(arg[1])
end

util.testYes(dir .. '/yes/', 'pimpl', pimplauto)
util.testNo(dir .. '/no/', 'pimpl', pimplauto)