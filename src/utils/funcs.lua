local funcs = {}

function funcs.print_r(t, fd)
    fd = fd or io.stdout
    local function print(str)
        str = str or ""
        fd:write(str .. "\n")
    end
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

function funcs.printKeys(tab)
    local keyset = {}
    local n = 0

    for k, v in pairs(tab) do
        n = n + 1
        keyset[n] = k
    end

    print(table.concat(keyset, ", "))
end

function funcs.get_file_name(file)
    local file_name = file:match("[^/]*.lua$")
    return file_name:sub(0, #file_name - 4)
end

function funcs.pointInRectangle(px, py, x1, y1, x2, y2)
    return px >= x1 and px <= x2 and py >= y1 and py <= y2
end

function funcs.filter(t, filterIter)
    local out = {}

    for k, v in pairs(t) do
        if filterIter(v, k, t) then table.insert(out, v) end
    end

    return out
end

function funcs.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

return funcs;
