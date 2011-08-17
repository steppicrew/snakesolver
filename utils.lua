
function split_string( str, sep, fieldNames )
    if str == nil then return nil end

    local fields = {}
    local sep = sep or ":"
    local pattern = string.format("[^%s]+", sep)
    local i= 1
    for c in string.gmatch(str, pattern) do
        if fieldNames ~= nil then
            fields[fieldNames[i]] = c
        else
            fields[i] = c
        end
        i = i + 1
    end
    return fields
end
