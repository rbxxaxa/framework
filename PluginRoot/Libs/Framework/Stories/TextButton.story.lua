local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local TextButton = load("Framework/TextButton")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local button  = e(TextButton, {
		size = UDim2.new(0, 100, 0, 100),
		position = UDim2.new(0, 100, 0, 100),
		text = "Test Button",
	})
	local handle = Roact.mount(StoryWrapper({ modalTarget = target }, button), target)

	return function()
		Roact.unmount(handle)
	end
end
