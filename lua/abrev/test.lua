local abrev = require("./lua/abrev")

-- local to_test = {
--     { "b{r,ra,re,rea,ear}k{,e}",                           "break", },
--     { "clieant{,s}",                                       "client{,s}", },
--     { "creat",                                             "crate", },
--     { "lein",                                              "line", },
--     { "liek",                                              "like", },
--     { "nedl",                                              "endl", },
--     { "ot",                                                "to", },
--     { "sdt",                                               "std", },
--     { "shitf",                                             "shift", },
--     { "sl{ef,fe}",                                         "self", },
--     { "som{,t,th}ing",                                     "something", },
--     { "everytihng",                                        "everything", },
--     { "statice",                                           "static", },
--     { "teh",                                               "the", },
--     { "hte",                                               "the", },
--     { "paht",                                              "path", },
--     { "tets",                                              "test", },
--     { "thay",                                              "they", },
--     { "ting",                                              "thing", },
--     { "tsd",                                               "std", },
--     { "useing",                                            "using", },
--     { "viod",                                              "void", },
--     { "wpgu",                                              "wgpu", },
--     { "yeald",                                             "yield", },
--     { "m{,e}sg",                                           "message", },
--     { "m{,e}sgs",                                          "messages", },
--     { "obj{,s}",                                           "object{,s}", },
--     { "anme",                                              "name", },
--     { "stroing",                                           "string", },
--     { "p{,i}xl{,e}",                                       "pixel", },
--     { "in{it,ti}ng",                                       "initializing", },
--     { "titel",                                             "title", },
--     { "hashamp",                                           "hashmap", },
--     { "{despa,desp,sepe}rat{e,es,ed,ing,ely,ion,ions,or}", "{despe,despe,sepa}rat{}", },
--     { "rnage",                                             "range", },
-- }

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
