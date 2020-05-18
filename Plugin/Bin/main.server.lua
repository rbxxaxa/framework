if not plugin then
    return
end

local PluginRoot = script.Parent.Parent
local PluginMain = require(PluginRoot.Core.PluginMain)

local function main()
    PluginMain.load(plugin)

    plugin.Unloading:Connect(function()
        PluginMain.unload()
    end)
end

main()