local M = {}

---parse a string in to parts to process in to variants
---
---TODO: add comments to pattern
---
---@param str string a string to make in to a parts table
---@return table tmp a table containing the parts of a word
local function parse_str(str)
    local tbl = {}

    local start = 1

    while start <= str:len() do
        local part = str:sub(start, str:len())

        local start_idx, end_idx = part:find("{.-}")

        -- if `start_idx` is 0 or nil then add it to the part table
        -- as its either just a full string or the remaninder
        -- after the last pattern
        if not start_idx then
            table.insert(tbl, part)
            break
        end

        -- if `start_idx` is greter then one there is some text befor the pattern
        if start_idx > 1 then
            local first = part:sub(0, start_idx - 1)
            table.insert(tbl, first)
        end

        -- add a trailing comma so lua pattern matching will catch all the
        -- values
        local second = part:sub(start_idx + 1, end_idx - 1) .. ","

        local tmp = {}
        for v in second:gmatch("([^,]*),") do
            table.insert(tmp, v)
        end

        table.insert(tbl, tmp)

        -- `start` starts at 1 so adding `end_idx` will always put us over
        -- the current end index
        start = start + end_idx
    end

    return tbl
end

---take items from a `tbl` and add values from `to_add` making a new table
---
---@param tbl table a table to copy the values from
---@param to_add string|table a value or values to copy to a new table
---@return table tmp a table that the values will be copied it to
local function add_value(tbl, to_add)
    local tmp = {}

    -- if table is empty then just add whatever is in `to_add` to tmp
    if not next(tbl) then
        if type(to_add) == "string" then
            table.insert(tmp, to_add)
        else
            for _, v in ipairs(to_add) do
                table.insert(tmp, v)
            end
        end
        -- concat elemnts in `tbl` with `to_add` in to `tmp`
    else
        if type(to_add) == "string" then
            for _, item in ipairs(tbl) do
                table.insert(tmp, item .. to_add)
            end
        else
            for _, item in ipairs(tbl) do
                for _, v in ipairs(to_add) do
                    table.insert(tmp, item .. v)
                end
            end
        end
    end

    return tmp
end

---duplicate items in a given table by a count
---
---@param tbl table the values to dupe
---@param count number about of time the values should be duped
---@return tmp table the new values
local function dup_values(tbl, count)
    local tmp = {}

    for _, item in ipairs(tbl) do
        for _ = 1, count do
            table.insert(tmp, item)
        end
    end

    return tmp
end

---make the variants from the given parts
---
---this largely works becuse we add the individule parts in order as they apper
---to the parts table then always iterate in order adding every varint to a list
---in that order
---there is no way to assosiate correct variants out of order so this works fine
---
---@param lhs table the left hand side parts
---@param rhs table the right hand side parts
---@return table variants
local function mk_variants(lhs, rhs)
    assert(#lhs >= #rhs, "lhs should be longer then rhs")

    local tmp = { lhs = {}, rhs = {} }

    if #rhs == 1 then
        table.insert(tmp.rhs, rhs[1])
    end

    -- this alows lhs and rhs to iterate at diffrent indexs
    local rhs_idx = 1

    local lhs_idx = 1
    for i = 1, #lhs do
        local l = lhs[i]

        tmp.lhs = add_value(tmp.lhs, l)

        -- if rhs is grater then one elemnt create variants
        if #rhs ~= 1 then
            local r = rhs[rhs_idx]

            if type(r) == "table" then
                assert(type(l) == "table",
                    "rhs variants should correspond to lhs variants")

                -- rhs is empty or only has an empty string then
                -- use the left hand side for variants
                if not next(r) or (#r == 1 and r[1] == "") then
                    tmp.rhs = add_value(tmp.rhs, l)
                else
                    tmp.rhs = add_value(tmp.rhs, r)
                end

                rhs_idx = rhs_idx + 1

                -- TODO: imporove this comment
                -- if rhs is not a table and lhs is then we are
                -- adding variants to lhs that should not be added to rhs
            elseif type(l) == "table" then
                tmp.rhs = dup_values(tmp.rhs, #l)
            else
                tmp.rhs = add_value(tmp.rhs, r)
                rhs_idx = rhs_idx + 1
            end
        end

        lhs_idx = lhs_idx + 1
    end

    return tmp
end

---make all the alternatives lower, uppercase and capitalized
---in to a table keyed by lhs and rhs as value
---
---@param tbl table a table with all the lhs and rhs variants
---@return table tmp a table keyed my lhs
local function mk_alternatives(tbl)
    local tmp = {}

    local lhs = tbl.lhs
    local rhs = tbl.rhs

    local rhs_idx = 1

    for i = 1, #lhs do
        if #rhs ~= 1 then
            rhs_idx = i
        end

        tmp[lhs[i]] = rhs[rhs_idx]

        tmp[string.lower(lhs[i])] = string.lower(rhs[rhs_idx])

        tmp[string.upper(lhs[i])] = string.upper(rhs[rhs_idx])

        local cap_l = string.upper(lhs[i]:sub(1, 1))
        local cap_r = string.upper(rhs[rhs_idx]:sub(1, 1))

        local full_l = cap_l .. lhs[i]:sub(2, lhs[i]:len())
        local full_r = cap_r .. rhs[rhs_idx]:sub(2, rhs[rhs_idx]:len())

        tmp[full_l] = full_r
    end

    return tmp
end

---make abbreviations from lhs and rhs strings
---
---@param to_make table a table containing the lhs and rhs string to make in to abbreviations
---@return table alternatives abbreviations to be used with vim.cmd("abbreviate "..)
local function mk_abbreviations(to_make)
    assert((to_make[1] and type(to_make[1]) == "string")
        and (to_make[2] and type(to_make[2]) == "string"),
            "abbreviations needs a lhs and rhs and should both be strings")

    local lhs_part = parse_str(to_make[1])
    local rhs_part = parse_str(to_make[3])

    local variants = mk_variants(lhs_part, rhs_part)

    return mk_alternatives(variants)
end

---take a table of alternatives and make abbreviations
---
---@param alternatives table a table of alternatives, the key is lhs and rhs is the target
local function call_vim_abrev(alternatives)
    for k, v in pairs(alternatives) do
        vim.cmd("abbreviate " .. k .. " " .. v)
    end
end

---the setup function
---
---@param opts table the options for plugin
M.setup = function(opts)
    assert(type(opts) == "table", "opts needs to be a table")

    if not next(opts) then
        return
    end

    if opts.abrevs == nil then
        return
    end

    for _, item in ipairs(opts.abrevs) do
        local abbreviations = mk_abbreviations(item)

        call_vim_abrev(abbreviations)
    end
end

M.mk_abbreviations = mk_abbreviations
return M