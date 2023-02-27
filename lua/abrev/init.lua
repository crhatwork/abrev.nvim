local M = {}

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


local function parse_str(str)
    local tbl = {}

    local start = 0

    while start < str:len() do
        local part = str:sub(start, str:len())

        local start_idx, end_idx = part:find("{.-}")

        if not start_idx then
            table.insert(tbl, part)
            break
        end

        -- we are looking for `{}` at least so we will either have `{}` or
        -- nothing

        local first = part:sub(0, start_idx - 1)

        if first and first ~= "" then
            table.insert(tbl, first)
        end

        local second = part:sub(start_idx + 1, end_idx - 1) .. ","

        local tmp = {}
        for v in second:gmatch("([^,]*),") do
            table.insert(tmp, v)
        end

        table.insert(tbl, tmp)

        start = start + end_idx + 1
    end

    return tbl
end

local function add_to_tbl(tbl, to_add)
    local tmp = {}

    if not next(tbl) then
        if type(to_add) == "string" then
            table.insert(tmp, to_add)
        else
            for _, v in ipairs(to_add) do
                table.insert(tmp, v)
            end
        end
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

local function mk_variants(lhs, rhs)
    assert(#lhs >= #rhs, "rhs should not be larger then lhs")
    local tmp = { lhs = {}, rhs = {} }


    if #rhs == 1 then
        table.insert(tmp.rhs, rhs[1])
    end

    for i = 1, #lhs do
        local l = lhs[i]

        tmp.lhs = add_to_tbl(tmp.lhs, l)

        if #rhs ~= 1 then
            local r = rhs[i]
            if type(rhs[i]) == "table" then
                if not next(r) or #r <= 1 then
                    tmp.rhs = add_to_tbl(tmp.rhs, l)
                else
                    tmp.rhs = add_to_tbl(tmp.rhs, r)
                end
            else
                tmp.rhs = add_to_tbl(tmp.rhs, r)
            end
        end
    end

    return tmp
end

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

        tmp[string.upper(lhs[i])] = string.upper(rhs[rhs_idx])


        local cap_l = string.upper(lhs[i]:sub(1, 1))
        local cap_r = string.upper(rhs[rhs_idx]:sub(1, 1))

        local full_l = cap_l .. lhs[i]:sub(2, lhs[i]:len())
        local full_r = cap_r .. rhs[rhs_idx]:sub(2, rhs[rhs_idx]:len())

        tmp[full_l] = full_r
    end

    return tmp
end

local function mk_abbreviations(to_make)
    assert(to_make[1] and to_make[2], "abbreviations needs a lhs and rhs")

    local lhs_part = parse_str(to_make[1])
    local rhs_part = parse_str(to_make[2])

    local variants = mk_variants(lhs_part, rhs_part)

    return mk_alternatives(variants)
end

local function call_vim_abrev(alternatives)
    for k, v in pairs(alternatives) do
        vim.cmd("abbreviate " .. k .. " " .. v)
    end
end

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
