local util = require 'pegparser.util'
local lfs = require "lfs"


local EXCEPTIONS = {
    damerau_levenshtein_2_rule = true,
    damerau_levenshtein_3_rule = true,
    mutation = true,
    bfs3 = true,
    random = true,
}

function inException(name)
    return EXCEPTIONS[name] or false
end

function isDir(path)
    -- lfs.attributes will error on a filename ending in '/'
    return path:sub(-1) == "/" or lfs.attributes(path, "mode") == "directory"
end

local function recursiveTestYes(root, dir, ext, p, output)
    if output[dir:sub(#root)] == nil then
        output[dir:sub(#root)] = { util.testYes(dir, ext, p) }
    else
        table.insert(output[dir:sub(#root)], util.testYes(dir, ext, p))
    end
    for file in lfs.dir(dir) do
        if file ~= "." and file ~= ".." and 
           isDir(dir .. file) and not inException(file) then
            recursiveTestYes(root, dir .. file .. "/", ext, p, output)
        end
    end
end

local function recursiveTestNo(root, dir, ext, p, output)
    if output[dir:sub(#root)] == nil then
        output[dir:sub(#root)] = { util.testNo(dir, ext, p) }
    else
        table.insert(output[dir:sub(#root)], util.testNo(dir, ext, p))
    end
    for file in lfs.dir(dir) do
        if file ~= "." and file ~= ".." and 
           isDir(dir .. file) and not inException(file) then
            recursiveTestNo(root, dir .. file .. "/", ext, p, output)
        end
    end
end

local function writeLog(times, filename)
    if filename ~= nil then 
        io.output(filename)
    end
    local space = 0
    for dir, list in pairs(times) do
        space = math.max(#dir, space)
    end
    for dir, list in pairs(times) do
        io.write(string.format("%-" .. space + 2 .. "s", dir .. ", "))
        for i, t in ipairs(list) do 
            io.write(string.format("%.03f, ", t))
        end
        io.write("\n")
    end
    io.output(io.stdout)
end


if arg[3] == nil then
    print("Use: " .. arg[0] .. " <exemples_folder> <extension> <grammar_file>")
    return
end

local grammar_namefile = arg[3]
if string.sub(grammar_namefile, -4) == ".lua" then
    grammar_namefile = string.sub(grammar_namefile, 1, -5)
end
local g = require(grammar_namefile)

local times = {}
local dir = arg[1]
if string.sub(dir, -1) ~= "/" then
    dir = dir .. "/"
end

local root = util.getPath(dir)
local ext = arg[2]

for i = 1, 10 do
    if arg[4] == "-n" then
        recursiveTestNo(root, dir, ext, g.grammar, times)
    else
        recursiveTestYes(root, dir, ext, g.grammar, times)
    end
end

table.sort(times)
writeLog(times)