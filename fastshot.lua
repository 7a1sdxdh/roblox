-- fastshot.lua
task.spawn(function()
    local gc = getgc(true)
    local count = 0
    for _, gcVal in pairs(gc) do
        if type(gcVal) == "table" then
            if rawget(gcVal, "ShootCooldown") then gcVal["ShootCooldown"] = 0 end
            if rawget(gcVal, "ShootSpread") then gcVal["ShootSpread"] = 0 end
            if rawget(gcVal, "ShootRecoil") then gcVal["ShootRecoil"] = 0 end
            if rawget(gcVal, "AttackCooldown") then gcVal["AttackCooldown"] = 0.1 end
            if rawget(gcVal, "HeavyAttackCooldown") then gcVal["HeavyAttackCooldown"] = 0.05 end
            if rawget(gcVal, "DashCooldown") then gcVal["DashCooldown"] = 0.05 end
            if rawget(gcVal, "BladeCooldown") then gcVal["BladeCooldown"] = 0 end
        end
        count = count + 1
        if count % 500 == 0 then task.wait() end
    end
    print("fastshot.lua 적용 완료!")
end)
