-- wallcheck.lua
local AimbotSettings = _G.AimbotSettings

local function toggleWallCheck()
    AimbotSettings.WallCheck = not AimbotSettings.WallCheck
end
_G.toggleWallCheck = toggleWallCheck

print("wallcheck.lua 로드 완료!")
