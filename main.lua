local ok, err = pcall(function()
    local code = game:HttpGet(BASE_URL .. fileName .. ".lua")
    print(fileName, "받은 코드 길이:", #code)
    local fn = loadstring(code)
    if fn == nil then
        print(fileName, "loadstring nil - 코드 파싱 실패")
        return
    end
    fn()
end)
