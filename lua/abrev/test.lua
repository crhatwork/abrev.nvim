local abrev = require("./lua/abrev")

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return '"' .. tostring(o) .. '"'
    end
end

local to_test = {
    { "foo{baz,bar}{r,g}{a,b}f", "foo{this,that}foo" },
    { "b{r,ra,re,rea,ear}k{,e}", "break", },
    { "clieant{,s}",             "client{,s}", },
    { "creat",                   "crate", },
    { "lein",                    "line", },
    { "liek",                    "like", },
    { "nedl",                    "endl", },
    { "ot",                      "to", },
    { "sdt",                     "std", },
    { "shitf",                   "shift", },
    { "sl{ef,fe}",               "self", },
    { "som{,t,th}ing",           "something", },
    { "everytihng",              "everything", },
    { "statice",                 "static", },
    { "teh",                     "the", },
    { "hte",                     "the", },
    { "paht",                    "path", },
    { "tets",                    "test", },
    { "thay",                    "they", },
    { "ting",                    "thing", },
    { "tsd",                     "std", },
    { "useing",                  "using", },
    { "viod",                    "void", },
    { "wpgu",                    "wgpu", },
    { "yeald",                   "yield", },
    { "m{,e}sg",                 "message", },
    { "m{,e}sgs",                "messages", },
    { "obj{,s}",                 "object{,s}", },
    { "anme",                    "name", },
    { "stroing",                 "string", },
    { "p{,i}xl{,e}",             "pixel", },
    { "in{it,ti}ng",             "initializing", },
    { "titel",                   "title", },
    { "hashamp",                 "hashmap", },
    { "rnage",                   "range", },
    { "javascrpt",               "JavaScript", },
}

local function main()
    for _, item in ipairs(to_test) do
        print(item[1], item[2])
        local tbl = abrev.mk_abbreviations(item)

        for k, v in pairs(tbl) do
            print(k, " -> ", v)
        end

        break
    end
end

main()
