if not plugin then
    return
end

local PluginRoot = script:FindFirstAncestor("PluginRoot")
local PluginMain = require(PluginRoot.Core.PluginMain)

local function main()
    PluginMain.start({
        plugin = plugin,
    })
end

main()
