local m = require "pegparser.parser"
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require 'pegparser.util'


s = [[
    prog     <- PROGRAM ID ':' fdef* MAIN ':' body
    fdef     <- ID ':' TAKES vdecl (';' vdecl)* RETURNS (type / NOTHING) body
    vdecl    <- ID (',' ID)* ':' type
    type     <- (BOOLEAN / INTEGER) ARRAY?
    body     <- decls? stmts END
    decls    <- vdecl (';' vdecl)*
    stmts    <- CHILLAX / stmt (';' stmt)*
    stmt     <- assign / call / return / input / output / case / loop
    assign   <- LET ID ('[' simple ']')? '=' (expr / ARRAY simple)
    call     <- DO ID '(' expr (',' expr)* ')'
    return   <- POP expr?
    input    <- INPUT ID ('[' simple ']')?
    output   <- OUTPUT (STRING / expr) ('.' (STRING / expr))*
    case     <- WHEN CASE expr ':' stmts END (CASE expr ':' stmts END)*
                (OTHERWISE ':' stmts END)?
    loop     <- WHILE expr ':' stmts END
    expr     <- simple (RELOP simple)?
    simple   <- '-'? term (ADDOP term)*
    term     <- factor (MULOP factor)*
    factor   <- ID ('[' simple ']' / '(' expr (',' expr)* ')')? / 
                NUM / '(' expr ')' / NOT factor / TRUE / FALSE

    RELOP    <- '=' / '>=' / '>' / '<=' / '<' / '/='
    ADDOP    <- '-' / OR / '+'
    MULOP    <- AND / '/' / '*' / REM

    Keywords <- PROGRAM / MAIN / TAKES / RETURNS / NOTHING / BOOLEAN / INTEGER / ARRAY /
                END / CHILLAX / LET / DO / POP / INPUT / OUTPUT / WHEN / CASE / WHILE /
                OR / AND / REM / NOT / TRUE / FALSE / OTHERWISE

    PROGRAM   <- 'program' ![a-zA-Z_0-9]
    MAIN      <- 'main' ![a-zA-Z_0-9]
    TAKES     <- 'takes' ![a-zA-Z_0-9]
    RETURNS   <- 'returns' ![a-zA-Z_0-9]
    NOTHING   <- 'nothing' ![a-zA-Z_0-9]
    BOOLEAN   <- 'boolean' ![a-zA-Z_0-9]
    INTEGER   <- 'integer' ![a-zA-Z_0-9]
    ARRAY     <- 'array' ![a-zA-Z_0-9]
    END       <- 'end' ![a-zA-Z_0-9]
    CHILLAX   <- 'chillax' ![a-zA-Z_0-9]
    LET       <- 'let' ![a-zA-Z_0-9]
    DO        <- 'do' ![a-zA-Z_0-9]
    POP       <- 'pop' ![a-zA-Z_0-9]
    INPUT     <- 'input' ![a-zA-Z_0-9]
    OUTPUT    <- 'output' ![a-zA-Z_0-9]
    WHEN      <- 'when' ![a-zA-Z_0-9]
    CASE      <- 'case' ![a-zA-Z_0-9]
    WHILE     <- 'while' ![a-zA-Z_0-9]
    OR        <- 'or' ![a-zA-Z_0-9]
    AND       <- 'and' ![a-zA-Z_0-9]
    REM       <- 'rem' ![a-zA-Z_0-9]
    NOT       <- 'not' ![a-zA-Z_0-9]
    TRUE      <- 'true' ![a-zA-Z_0-9]
    FALSE     <- 'false' ![a-zA-Z_0-9]
    OTHERWISE <- 'otherwise' ![a-zA-Z_0-9]

    ID       <- !Keywords [a-zA-Z_] [a-zA-Z_0-9]*
    NUM      <- [0-9]+
    STRING   <- '"' ([a-zA-Z_0-9 !#-/:-?] / '\' [nt"\])* '"'
]]


local graph = m.match(s)
--print(pretty.printg(graph), '\n')

pimpl = coder.makeg(graph)