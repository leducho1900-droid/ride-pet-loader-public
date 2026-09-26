--========================================================
-- Ride Pet V530 PROTECTED LOADSTRING LOADER
--
-- Put ONLY this small loader in public.
-- Keep the full V530 script on your private server.
--
-- Usage:
-- 1) Replace API_URL with your server link.
-- 2) Replace KEY_HERE with each buyer's key, or set getgenv().RAP_KEY before running.
--
-- Example:
-- getgenv().RAP_KEY = "ABC-123"
-- loadstring(game:HttpGet("YOUR_PUBLIC_LOADER_RAW_URL", true))()
--========================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local API_URL = "https://YOUR-SERVER.com/api/ridepet-v530"
local KEY = (getgenv and getgenv().RAP_KEY) or "KEY_HERE"

local function urlencode(v)
    local ok, res = pcall(function()
        return HttpService:UrlEncode(tostring(v or ""))
    end)
    return ok and res or tostring(v or "")
end

local function getDeviceId()
    local id = nil

    pcall(function()
        if gethwid then
            id = gethwid()
        end
    end)

    if not id or id == "" then
        pcall(function()
            id = game:GetService("RbxAnalyticsService"):GetClientId()
        end)
    end

    if not id or id == "" then
        id = tostring(Players.LocalPlayer and Players.LocalPlayer.UserId or "unknown")
    end

    return tostring(id)
end

local query =
    "?key=" .. urlencode(KEY)
    .. "&device=" .. urlencode(getDeviceId())
    .. "&userId=" .. urlencode(Players.LocalPlayer and Players.LocalPlayer.UserId or "0")
    .. "&username=" .. urlencode(Players.LocalPlayer and Players.LocalPlayer.Name or "unknown")
    .. "&placeId=" .. urlencode(game.PlaceId)
    .. "&version=530"

local ok, src = pcall(function()
    return game:HttpGet(API_URL .. query, true)
end)

if not ok or not src or src == "" then
    return
end

-- Server can return plain lua or JSON: {ok=true, code="..."}
local code = src
pcall(function()
    local decoded = HttpService:JSONDecode(src)
    if type(decoded) == "table" then
        if decoded.ok == false then
            code = ""
        elseif type(decoded.code) == "string" then
            code = decoded.code
        end
    end
end)

if not code or code == "" then
    return
end

local fn = loadstring(code)
if fn then
    fn()
end
