local m = require "pegparser.parser"
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require 'pegparser.util'

local s = [[
    prog     <- 'program' ID ':' fdef* 'main' ':' body
    fdef     <- ID ':' 'takes' vdecl (';' vdecl)* 'returns' (type / 'nothing') body
    vdecl    <- ID (',' ID)* ':' type
    type     <- ('boolean' / 'integer') 'array'?
    body     <- decls? stmts 'end'
    decls    <- vdecl (';' vdecl)*
    stmts    <- 'chillax' / stmt (';' stmt)*
    stmt     <- assign / call / return / input / output / case / loop
    assign   <- 'let' ID ('[' simple ']')? '=' (expr / 'array' simple)
    call     <- 'do' ID (expr (',' expr)*)
    return   <- 'pop' expr?
    input    <- 'input' ID ('[' simple ']')?
    output   <- 'output' (STRING / expr) ('.' (STRING / expr))*
    case     <- 'when' ('case' expr ':' stmts 'end')+ ('otherwise' ':' stmts 'end')?
    loop     <- 'while' expr ':' stmts 'end'
    expr     <- simple (relop simple)?
    relop    <- '=' / '>=' / '>' / '<=' / '<' / '/='
    simple   <- '-'? term (addop term)*
    addop    <- '-' / 'or' / '+'
    term     <- factor (mulop factor)*
    mulop    <- 'and' / '/' / '*' / 'rem'
    factor   <- ID ('[' simple ']' / '(' expr (',' expr)* ')')? / 
                NUM / '(' expr ')' / 'not' factor / 'true' / 'false'

    RESERVED <- ('program' / 'main' / 'takes' / 'returns' / 'nothing' / 'boolean' /
                 'integer' / 'array' / 'end' / 'chillax' / 'let' / 'do' / 'pop' /
                 'input' / 'output' / 'when' / 'case' / 'while' / 'or' / 'and' /
                 'rem' / 'not' / 'true' / 'false') ![a-zA-Z_]
    ID       <- !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
    NUM      <- [0-9]+
    STRING   <- '"' ([a-zA-Z_0-9 !#-/:-?] / '\' [nt"\])* '"'
]]

local graph = m.match(s)
--print(pretty.printg(graph), '\n')

pimpl = coder.makeg(graph)