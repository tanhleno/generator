local m = require "pegparser.parser"
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'

local ampl = require 'notLabeled'


--[[
    prog    <-  PROGRAM^Err_001 ID^Err_002 ':'^Err_003 (fdef  /  !(MAIN  /  !.) %{Err_004} .)*
                MAIN^Err_005 ':'^Err_006 body^Err_007
    fdef    <-  ID ':'^Err_008 TAKES^Err_009 vdecl^Err_010
                (';' vdecl^Err_011  /  !(RETURNS  /  !.) %{Err_012} .)* RETURNS^Err_013 
                (type  /  NOTHING^Err_014)^Err_015 body^Err_016
    vdecl   <-  ID (',' ID^Err_017  /  !(':'  /  !.) %{Err_018} .)* ':'^Err_019 type^Err_020
    type    <-  (BOOLEAN  /  INTEGER) (ARRAY  /  !(WHILE  /  WHEN  /  RETURNS  /  POP  /
                OUTPUT  /  LET  /  INPUT  /  ID  /  DO  /  CHILLAX  /  ';'  /  !.) %{Err_021} .)?
    body    <-  (decls  /  !(WHILE  /  WHEN  /  POP  /  OUTPUT  /  LET  /  INPUT  /  DO  /
                CHILLAX  /  !.) %{Err_022} .)? stmts^Err_023 END^Err_024
    decls   <-  vdecl ';'^Err_025 (vdecl ';'^Err_026  /  !(WHILE  /  WHEN  /  POP  /  OUTPUT  /  
                LET  /  INPUT  /  DO  /  CHILLAX  /  !.) %{Err_027} .)*
    stmts   <-  (CHILLAX  /  stmt^Err_028 (';' stmt^Err_029  /  !(END  /  !.) 
                %{Err_030} .)*)^Err_031
    stmt    <-  (assign  /  call  /  return  /  input  /  output  /  
                case  /  loop^Err_032)^Err_033
    assign  <-  LET ID^Err_034 ('[' simple^Err_035 ']'^Err_036  /  !('='  /  !.) %{Err_037} .)? 
                '='^Err_038 (expr  /  ARRAY^Err_039 simple^Err_040)^Err_041
    call    <-  DO ID^Err_042 '('^Err_043 expr^Err_044 
                (',' expr^Err_045  /  !(')'  /  !.) %{Err_046} .)* ')'^Err_047
    return  <-  POP (expr  /  !(END  /  ';'  /  !.) %{Err_048} .)?
    input   <-  INPUT ID^Err_049 ('[' simple^Err_050 ']'^Err_051  /  
                !(END  /  ';'  /  !.) %{Err_052} .)?
    output  <-  OUTPUT (STRING  /  expr^Err_053)^Err_054 ('.' (STRING  /  expr^Err_055)^Err_056  /
                !(END  /  ';'  /  !.) %{Err_057} .)*
    case    <-  WHEN CASE^Err_058 expr^Err_059 ':'^Err_060 stmts^Err_061 END^Err_062 
                (CASE expr^Err_063 ':'^Err_064 stmts^Err_065 END^Err_066  /  
                !(OTHERWISE  /  END  /  ';'  /  !.) %{Err_067} .)* 
                (OTHERWISE ':'^Err_068 stmts^Err_069 END^Err_070  /  
                !(END  /  ';'  /  !.) %{Err_071} .)?
    loop    <-  WHILE^Err_072 expr^Err_073 ':'^Err_074 stmts^Err_075 END^Err_076
    expr    <-  simple (RELOP simple^Err_077)?
    simple  <-  '-'? term (ADDOP term^Err_078)*
    term    <-  factor (MULOP factor^Err_079)*
    factor  <-  ID ('[' simple ']'  /  '(' expr (',' expr)* ')')?  /  NUM  /  
                '(' expr^Err_080 ')'^Err_081  /  NOT factor^Err_082  /  TRUE  /  FALSE
--]]

local g = m.match(ampl.s)
local graph = recovery.putlabels(g, 'upath', false)
local grammar = coder.makeg(graph)

return {
    graph = graph,
    grammar = grammar
}