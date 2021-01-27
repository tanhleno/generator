local m = require "pegparser.parser"
local coder = require 'pegparser.coder'

local s = [[
    json   <-  value EOF
    obj    <- '{' pair (',' pair)* '}'
    pair   <- STRING ':' value
    arr    <- '[' value (',' value)* ']' 
    value  <- STRING
            / NUMBER
            / obj 
            / arr
            / 'null'
            / 'true'
            / 'false'
    STRING <-  '"' (!'"' .)* '"'  
            /  "'" (!"'" .)* "'"
    NUMBER <- [0-9]+ ('.'!'.' [0-9]*)?
    EOF    <- !.
]]

local graph = m.match(s)
local grammar = coder.makeg(graph)

return {
    s = s,
    graph = graph,
    grammar = grammar
}
