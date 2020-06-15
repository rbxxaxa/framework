local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local TextButton = load("Framework/TextButton")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local pressCount, updatePressCount = Roact.createBinding(0)
	local clickCount, updateClickCount = Roact.createBinding(0)

	local button  = e(TextButton, {
		size = UDim2.new(0, 100, 0, 100),
		position = UDim2.new(0, 100, 0, 100),
		mouse1Pressed = function()
			updatePressCount(pressCount:getValue() + 1)
		end,
		mouse1Clicked = function()
			updateClickCount(clickCount:getValue() + 1)
		end,
		text = "ASDF",
	})
	local handle = Roact.mount(button, target)

	return function()
		Roact.unmount(handle)
	end
end
