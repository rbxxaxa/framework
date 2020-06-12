if not plugin then
    return
end

local PluginRoot = script.Parent.Parent
local PluginMain = require(PluginRoot.Core.PluginMain)

local function main()
    PluginMain.start({
        plugin = plugin,
    })
end

main()