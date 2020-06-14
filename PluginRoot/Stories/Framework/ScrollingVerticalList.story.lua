local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local ScrollingVerticalList = load("Framework/ScrollingVerticalList")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local section = e(ScrollingVerticalList, {
		size = UDim2.new(0, 200, 0, 200),
		position = UDim2.new(0, 20, 0, 20),
		width = UDim.new(0, 200),
		paddingTop = 12,
		paddingRight = 12,
		paddingBottom = 12,
		paddingLeft = 12,
		paddingList = 12,
	}, {
		Text1 = e("TextLabel", {
			Text = "Text1",
			Size = UDim2.new(0, 100, 0, 100),
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			TextColor3 = Color3.new(1, 1, 1),
			LayoutOrder = 1,
		}),

		Text2 = e("TextLabel", {
			Text = "Text2",
			Size = UDim2.new(1, 0, 0, 100),
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			TextColor3 = Color3.new(1, 1, 1),
			LayoutOrder = 2,
		}),
	})
	local handle = Roact.mount(section, target)

	return function()
		Roact.unmount(handle)
	end
end
