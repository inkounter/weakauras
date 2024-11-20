function(lhs, rhs)
    local orderedSpellIds = { 2823, 381664, 8679, 381637, 5761, 3408 }

    local lhsSpellId = lhs.region.state.spellId
    local rhsSpellId = rhs.region.state.spellId

    local lhsIndex = nil
    local rhsIndex = nil
    for k, v in ipairs(orderedSpellIds) do
        if lhsSpellId == v then
            lhsIndex = k
        elseif rhsSpellId == v then
            rhsIndex = k
        end

        if lhsIndex and rhsIndex then
            return rhsIndex > lhsIndex
        end
    end
end
