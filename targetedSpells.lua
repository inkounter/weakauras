-- Custom Group by Frame

function(frames, activeRegions)
    local lgf = LibStub("LibGetFrame-1.0")
    for _, regionData in ipairs(activeRegions) do
        local target = (regionData['region']['state']
                                 and regionData['region']['state']['destUnit'])
        if target then
            local frame = lgf.GetFrame(target)
            if frame then
                frames[frame] = frames[frame] or {}
                tinsert(frames[frame], regionData)
            end
        end
    end
end
