-- trigger (status): INK_PI_TARGET_CHANGED
function()
    return true
end

-- untrigger
function()
    return false
end

-- name
function()
    local macroName = "Void Eruption"
    local macroBody = GetMacroBody(macroName)
    local targetBegin, targetEnd = string.find(macroBody, "@[^@]+]Power")
    targetBegin = targetBegin + 1
    targetEnd = targetEnd - 6

    local target = string.sub(macroBody, targetBegin, targetEnd)

    return target
end

--[[
Macro to set the PI target:
```
local t=GetUnitName("target", true)
if t ~= nil then
    local n="Void Eruption"
    local m=GetMacroBody(n)
    m=string.gsub(m, "@[^@]+]Power", "@"..t.."]Power")
    EditMacro(n,n,nil,m)
    WeakAuras.ScanEvents("INK_PI_TARGET_CHANGED")
end
```

Sample "Void Eruption" macro:
```
#showtooltip
/stopmacro [channeling:Void Torrent][@target,noexists][@target,noharm][noform:1]
/cqs
/cast Void Eruption
/use Rotcrusted Voodoo Doll
/cast [@Ellieharris-Proudmoore]Power Infusion
/cast Void Bolt
```
]]
