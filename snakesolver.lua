#!/usr/bin/luajit-2

require('utils')
require('dumper')

local dim= 4
local snake_short= "5 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2 2"
-- local snake_short="7 1 1 2 1 1 1 6 1 1 2 2 4 2 3 4 3 5 5 2 2 4 2 2"
-- local snake_short="2 4 2 2 4 4 4 2 2 4 1 1 4 2 2 4 4 4 2 2 4 3 1"
local exit_after_first_solution= true

local dimm1= dim - 1
local dimp1= dim + 1;
local dimp2= dim + 2;
local dimp2sq= dimp2 * dimp2;
local slen= dim * dim * dim;

local snake= {}
local color= 2
for i,k in ipairs(split_string(snake_short, " ")) do
    color= 3 - color
    for j = 1,k do snake[#snake + 1]= color end
end

if slen ~= #snake then
    print ("snake length is not slen!")
    os.exit(1)
end
if #snake % 2 ~= 0 then
    print ("snake length is uneven!")
    os.exit(1)
end

local xyz2n= function(x, y, z) return z * dimp2sq + y * dimp2 + x + 1 end
local n2x= function(n) return (n - 1) % dimp2 end
local n2y= function(n) return math.floor((n - 1) / dimp2) % dimp2 end
local n2z= function(n) return math.floor((n - 1) / dimp2sq) % dimp2 end

local offset= 0
local tries= 0

local result= {}
local solved= {}

for x = 0,dimp1 do
    for y = 0,dimp1 do
        for z = 0,dimp1 do
            local n= xyz2n(x, y, z)
            if x == 0 or y == 0 or z == 0 or x == dimp1 or y == dimp1 or z == dimp1 then
                result[n]= -1
                solved[n]= 0
            elseif x == 1 or y == 1 or z == 1 or x == dim or y == dim or z == dim then
                result[n]= -2
                solved[n]= (math.floor((x - 1) / 2) + math.floor((y - 1) / 2) + math.floor((z - 1) / 2))% 2 + 1;
            else
                result[n]= -2
                solved[n]= 0
            end
        end
    end
end

local get_cube= function()
    local r= ""
    for z = 1,dim do
        r= r .. "z=" .. z .. "\n"
            .. "\t+----+----+----+----+"
            .. "\t+---+---+---+---+\n"

        for y = 1,dim do
            r= r .. "\t|"

            for x = 1,dim do
                local n= xyz2n(x, y, z)
                r= r .. string.format(" %2d |", result[n])
            end
            r= r .. "\t|"

            for x = 1,dim do
                local n= xyz2n(x, y, z)

                local snake_i= result[n]
                if snake_i < 0 then
                    r= r .. " ? |"
                elseif snake[snake_i] == 1 then
                    r= r .. " X |"
                else
                    r= r .. "   |"
                end
            end

            r= r .. "\n\t+----+----+----+----+"
            r= r .. "\t+---+---+---+---+\n"
        end
        r= r .. "\n"
    end

    return r
end

local print_cube= function()
    print (get_cube())
end

local has_solved= function()
    print ("\n\nSOLVED with " .. tries .. " tries\n")
    print_cube()

    if exit_after_first_solution then 
        os.exit(1)
    end
end

local t= function(check, if_true, if_false)
    if check then return if_true else return if_false end
end

local find_way
find_way= function(n, idx, dir, fin)

    if fin then

        -- ist naechstes element ist der anfang der schlange?
        if result[n] == 1 then has_solved() end
        return
    end

    if result[n] > -2 then return end -- already set
    if solved[n] > 0 and solved[n] ~= snake[idx] then return end -- color cares but does not match

--    print ("fin=" .. t(fin, "true", "false") .. " idx=" .. idx .. " dir=" .. dir .. " n=" .. n .. " xyz=[" .. n2x(n) .. " " .. n2y(n) .. " " .. n2z(n) .. "]\n")
  
    tries= tries + 1
  
    if tries % 1000000 == 0 then
        print ("\rtries: " .. tries .. " (" .. n2x(n) .. "," .. n2y(n) .. "," .. n2z(n) .. ") -> idx: " .. snake[idx])
    end

    result[n]= idx

    idx= idx + 1
    fin= idx > #snake

    if dir ~= 1 then find_way(n + 1,       idx, 0, fin) end
    if dir ~= 0 then find_way(n - 1,       idx, 1, fin) end
    if dir ~= 3 then find_way(n + dimp2,   idx, 2, fin) end
    if dir ~= 2 then find_way(n - dimp2,   idx, 3, fin) end
    if dir ~= 5 then find_way(n + dimp2sq, idx, 4, fin) end
    if dir ~= 4 then find_way(n - dimp2sq, idx, 5, fin) end

    result[n]= -2
end

while offset < slen do
    if offset > 0 then
        table.insert(snake, 1, table.remove(snake, #snake))
        print ("\nstarting over (" .. offset .. ")\n")
    end
    offset= offset + 1

    find_way(xyz2n(1, 1, 1), 1, -1, false)
end
