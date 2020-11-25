local m = require "pegparser.parser"
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require 'pegparser.util'


local s = [[
    prog     <- PROGRAM^kwProgramErr ID^idProgErr ':'^colonErr1 
                (fdef / !MAIN %{fdefErr})* MAIN^kwMainErr ':'^colonErr2 body^bodyErr1
    fdef     <- ID ':'^colonErr3 TAKES^kwTakesErr vdecl^vdeclErr1
                (';' vdecl^vdeclErr2 / !RETURNS %{semicolonErr1})* 
                RETURNS^kwReturnsErr (type / NOTHING)^typeReturnsErr body^bodyErr2
    vdecl    <- ID (',' ID^idVdeclErr / !':' %{commaErr1})*
                ':'^colonErr4 type^typeErr
    type     <- (BOOLEAN / INTEGER)
                (ARRAY / !(ID / ';' / RETURNS / CHILLAX / LET /
                DO / POP / INPUT / OUTPUT / WHEN / WHILE / !.) %{kwArrayErr})?
    body     <- (decls / !(CHILLAX / LET / DO / POP / INPUT /
                OUTPUT / WHEN / WHILE) %{declsErr})? stmts^stmtsErr1 END^endErr1
    decls    <- vdecl ';'^semicolonErr2 (vdecl ';'^semicolonErr3 / !(CHILLAX / LET / DO / POP /
                INPUT / OUTPUT / WHEN / WHILE) %{vdeclErr3})*
    stmts    <- (CHILLAX / stmt (';' stmt^stmtErr /
                !(END / !.) %{semicolonErr4})*)^stmtsErr2
    stmt     <- assign / call / return / input / output / case / loop
    assign   <- LET ID^idAssignErr ('[' simple^simpleErr1 ']'^braRErr1 / 
                !('=' / !.) %{braLErr1})? '='^EqErr1 
                (expr / ARRAY simple^simpleErr2)^valueErr1
    call     <- DO ID^idCallErr '('^parLErr1 expr^exprErr1 (',' expr^exprErr2 /
                !(')' / !.) %{commaErr2})* ')'^parRErr1
    return   <- POP (expr / !(';' / END / !.) %{exprErr3})?
    input    <- INPUT ID^idInputErr ('[' simple^simpleErr3 ']'^braRErr2 /
                !(';' / END / !.) %{braLErr2})?
    output   <- OUTPUT (STRING / expr)^valueErr2 ('.' (STRING / expr)^valueErr3 /
                !(';' / END / !.) %{dotErr})*
    case     <- WHEN CASE^kwCaseErr1 expr^exprErr4 ':'^colonErr5 stmts^stmtsErr3 END^endErr2
                (CASE expr^exprErr5 ':'^colonErr6 stmts^stmtsErr4 END^endErr3 /
                !(';' / END / OTHERWISE / !.) %{kwCaseErr2})*
                (OTHERWISE ':'^colonErr7 stmts^stmtsErr5 END^endErr3 / 
                !(';' / END / !.) %{kwOtherwiseErr})?
    loop     <- WHILE expr^exprErr6 ':'^colonErr8 stmts^stmtsErr6 END^endErr4
    expr     <- simple (RELOP simple^simpleErr4)?
    simple   <- '-'? term (ADDOP term^termErr)*
    term     <- factor (MULOP factor^factorErr1)*
    factor   <- (ID ('[' simple^simpleErr5 ']'^braRErr3 / '(' expr^exprErr7 
                (',' expr^exprErr8 / !')' %{commaErr3})* ')'^parRErr2)? / 
                NUM / '(' expr^exprErr9 ')'^parRErr3 / NOT factor^factorErr2 /
                TRUE / FALSE)

    RELOP    <- '=' / '>=' / '>' / '<=' / '<' / '/='
    ADDOP    <- '-' / OR / '+'
    MULOP    <- AND / '/' !'=' / '*' / REM

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
    STRING   <- '"' ('\\' / '\"' / !'"' .)* '"'
]]

local graph = m.match(s)
--print(pretty.printg(graph), '\n')

pimplmano = coder.makeg(graph)