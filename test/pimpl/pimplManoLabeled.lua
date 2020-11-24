local m = require "pegparser.parser"
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require 'pegparser.util'


local s = [[
    prog     <- 'program'^kwProgramErr ID^idProgErr ':'^colonErr1 
                (fdef / !'main' %{fdefErr})* 'main'^kwMainErr ':'^colonErr2 body^bodyErr1
    fdef     <- ID ':'^colonErr3 'takes'^kwTakesErr vdecl^vdeclErr1
                (';' vdecl^vdeclErr2 / !'returns' %{semicolonErr1})* 
                'returns'^kwReturnsErr (type / 'nothing')^typeReturnsErr body^bodyErr2
    vdecl    <- ID (',' ID^idVdeclErr / !':' %{commaErr1})*
                ':'^colonErr4 type^typeErr
    type     <- ('boolean' / 'integer')
                ('array' / !(ID / ';' / 'returns' / 'chillax' / 'let' /
                'do' / 'pop' / 'input' / 'output' / 'when' / 'while' / !.) %{kwArrayErr})?
    body     <- (decls / !('chillax' / 'let' / 'do' / 'pop' / 'input' /
                'output' / 'when' / 'while') %{declsErr})? stmts^stmtsErr1 'end'^endErr1
    decls    <- vdecl (';' vdecl^vdeclErr3 / !('chillax' / 'let' / 'do' / 'pop' / 'input' /
                'output' / 'when' / 'while') %{semicolonErr2})*
    stmts    <- ('chillax' / stmt (';' stmt^stmtErr /
                !('end' / !.) %{semicolonErr3})*)^stmtsErr2
    stmt     <- assign / call / return / input / output / case / loop
    assign   <- 'let' ID^idAssignErr ('[' simple^simpleErr1 ']'^braRErr1 / 
                !('=' / !.) %{braLErr1})? '='^EqErr1 
                (expr / 'array' simple^simpleErr2)^valueErr1
    call     <- 'do' ID^idCallErr '('^parLErr1 expr^exprErr1 (',' expr^exprErr2 /
                !(')' / !.) %{commaErr2})* ')'^parRErr1
    return   <- 'pop' (expr / !(';' / 'end' / !.) %{exprErr3})?
    input    <- 'input' ID^idInputErr ('[' simple^simpleErr3 ']'^braRErr2 /
                !(';' / 'end' / !.) %{braLErr2})?
    output   <- 'output' (STRING / expr)^valueErr2 ('.' (STRING / expr)^valueErr3 /
                !(';' / 'end' / !.) %{dotErr})*
    case     <- 'when' 'case'^kwCaseErr1 expr^exprErr4 ':'^colonErr5 stmts^stmtsErr3 'end'^endErr2
                ('case' expr^exprErr5 ':'^colonErr6 stmts^stmtsErr4 'end'^endErr3 /
                !(';' / 'end' / 'otherwise' / !.) %{kwCaseErr2})*
                ('otherwise' ':'^colonErr7 stmts^stmtsErr5 'end'^endErr3 / 
                !(';' / 'end' / !.) %{kwOtherwiseErr})?
    loop     <- 'while' expr^exprErr6 ':'^colonErr8 stmts^stmtsErr6 'end'^endErr4
    expr     <- simple (RELOP simple^simpleErr4)?
    simple   <- '-'? term (ADDOP term^termErr)*
    term     <- factor (MULOP factor^factorErr1)*
    factor   <- (ID ('[' simple^simpleErr5 ']'^braRErr3 / '(' expr^exprErr7 
                (',' expr^exprErr8 / !')' %{commaErr3})* ')'^parRErr2)? / 
                NUM / '(' expr^exprErr9 ')'^parRErr3 / 'not' factor^factorErr2 /
                'true' / 'false')

    RELOP    <- '=' / '>=' / '>' / '<=' / '<' / '/='
    ADDOP    <- '-' / 'or' / '+'
    MULOP    <- 'and' / '/' / '*' / 'rem'
    RESERVED <- ('program' / 'main' / 'takes' / 'returns' / 'nothing' / 'boolean' /
                 'integer' / 'array' / 'end' / 'chillax' / 'let' / 'do' / 'pop' /
                 'input' / 'output' / 'when' / 'case' / 'while' / 'or' / 'and' /
                 'rem' / 'not' / 'true' / 'false' / 'otherwise') ![a-zA-Z_]
    ID       <- !RESERVED [a-zA-Z_] [a-zA-Z_0-9]*
    NUM      <- [0-9]+
    STRING   <- '"' ([a-zA-Z_0-9 !#-/:-?] / '\' [nt"\])* '"'
]]

local graph = m.match(s)
--print(pretty.printg(graph), '\n')

pimplmano = coder.makeg(graph)