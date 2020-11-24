local m = require "pegparser.parser"
local pretty = require 'pegparser.pretty'
local coder = require 'pegparser.coder'
local recovery = require 'pegparser.recovery'
local ast = require'pegparser.ast'
local util = require 'pegparser.util'

require "pimpl"

--[[
    prog    <-  PROGRAM^Err_001 ID^Err_002 ':'^Err_003 
                (fdef  /  !(MAIN  /  !.) %{Err_004} .)* MAIN^Err_005 ':'^Err_006 body^Err_007
    fdef    <-  ID ':'^Err_008 TAKES^Err_009 vdecl^Err_010 
                (';' vdecl^Err_011  /  !(RETURNS  /  !.) %{Err_012} .)* 
                RETURNS^Err_013 (type  /  NOTHING^Err_014)^Err_015 body^Err_016
    vdecl   <-  ID (',' ID^Err_017  /  !(':'  /  !.) %{Err_018} .)* ':'^Err_019 type^Err_020
    type    <-  (BOOLEAN  /  INTEGER) (ARRAY  /  !(WHILE  /  WHEN  /  RETURNS  /  POP  /  
                OUTPUT  /  LET  /  INPUT  /  ID  /  DO  /  CHILLAX  /  ';'  /  !.) %{Err_021} .)?
    body    <-  (decls  /  !(WHILE  /  WHEN  /  POP  /  OUTPUT  /  LET  /  INPUT  /  DO  /
                CHILLAX  /  !.) %{Err_022} .)? stmts^Err_023 END^Err_024
    decls   <-  vdecl (';' vdecl^Err_025  /  !(WHILE  /  WHEN  /  POP  /  OUTPUT  /  LET  /
                INPUT  /  DO  /  CHILLAX  /  !.) %{Err_026} .)*
    stmts   <-  (CHILLAX  /  stmt^Err_027 (';' stmt^Err_028  /
                !(END  /  !.)%{Err_029} .)*)^Err_030
    stmt    <-  (assign  /  call  /  return  /  input  /  output  /  case  /
                loop^Err_031)^Err_032
    assign  <-  LET ID^Err_033 ('[' simple^Err_034 ']'^Err_035  /  !('='  /  !.) %{Err_036} .)?
                '='^Err_037 (expr  /  ARRAY^Err_038 simple^Err_039)^Err_040
    call    <-  DO ID^Err_041 '('^Err_042 expr^Err_043 (',' expr^Err_044  /  !(')'  /  !.) 
                %{Err_045} .)* ')'^Err_046
    return  <-  POP (expr  /  !(END  /  ';'  /  !.) %{Err_047} .)?
    input   <-  INPUT ID^Err_048 ('[' simple^Err_049 ']'^Err_050  /  
                !(END  /  ';'  /  !.) %{Err_051} .)?
    output  <-  OUTPUT (STRING  /  expr^Err_052)^Err_053 ('.' (STRING  /  expr^Err_054)^Err_055  /  
                !(END  /  ';'  /  !.) %{Err_056} .)*
    case    <-  WHEN CASE^Err_057 expr^Err_058 ':'^Err_059 stmts^Err_060 END^Err_061 
                (CASE expr^Err_062 ':'^Err_063 stmts^Err_064 END^Err_065  /  
                !(OTHERWISE  /  END  /  ';'  /  !.) %{Err_066} .)* (OTHERWISE ':'^Err_067 
                stmts^Err_068 END^Err_069  /  !(END  /  ';'  /  !.) %{Err_070} .)?
    loop    <-  WHILE^Err_071 expr^Err_072 ':'^Err_073 stmts^Err_074 END^Err_075
    expr    <-  simple (RELOP simple^Err_076)?
    simple  <-  '-'? term (ADDOP term^Err_077)*
    term    <-  factor (MULOP factor^Err_078)*
    factor  <-  ID ('[' simple ']'  /  '(' expr (',' expr)* ')')?  /  NUM  /  
                '(' expr^Err_079 ')'^Err_080  /  NOT factor^Err_081  /  TRUE  /  FALSE	
--]]

local g = m.match(s)
local graph = recovery.putlabels(g, 'upath', false)
--print(pretty.printg(graph, true, nil, "notLex"), '\n')

pimplauto = coder.makeg(graph)