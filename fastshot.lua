-- fastshot.lua
task.spawn(function()
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" then
            if rawget(gcVal, "ShootCooldown") then gcVal["ShootCooldown"] = 0 end
            if rawget(gcVal, "ShootSpread") then gcVal["ShootSpread"] = 0 end
            if rawget(gcVal, "ShootRecoil") then gcVal["ShootRecoil"] = 0 end
            if rawget(gcVal, "AttackCooldown") then gcVal["AttackCooldown"] = 0.1 end
            if rawget(gcVal, "HeavyAttackCooldown") then gcVal["HeavyAttackCooldown"] = 0.05 end
            if rawget(gcVal, "DashCooldown") then gcVal["DashCooldown"] = 0.05 end
            if rawget(gcVal, "BladeCooldown") then gcVal["BladeCooldown"] = 0 end
        end
    end
    print("fastshot.lua 적용 완료!")
end)
