
function newObject(value,onchange)
    local changeCB = onchange
    local haschange = false 
    local default = value
    local await = nil
    return function(action,v) 
        if action == 'get' then 
            return value 
        elseif action == 'set' then 
            if value ~= v then 
                haschange = true
                value = v 
                if changeCB then changeCB(value,v) end 
            else 
                haschange = false 
            end 
        elseif action == 'setawait' then 
            await = v 
        elseif action == 'resetawait' then 
            await = nil
        elseif action == 'getawait' then 
            return await
        elseif action == 'reset' then 
            value = default
        elseif action == 'has' then 
            return value ~= nil
        elseif action == 'haschange' then 
            local r = haschange
            haschange = false 
            return r
        else 
            error "invalid action"
        end 
    end 
end 

function optsMatch(match,...)
    local found,opts = false,{...}
    for i = 1, #opts do if opts[i] == match then 
        found = true break
    end end 
    return found 
end 

