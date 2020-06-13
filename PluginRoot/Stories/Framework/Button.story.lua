local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local Button = load("Framework/Button")

local e = Roact.createElement

return function(target)
	local counter, updateCounter = Roact.createBinding(0)

	local button  = e(Button, {
		size = UDim2.new(0, 100, 0, 100),
		position = UDim2.new(0, 100, 0, 100),
		onClick = function()
			updateCounter(counter:getValue() + 1)
		end
	}, {
		Text = e("TextLabel", {
			BackgroundTransparency = 1,
			Text = counter:map(function(count) return "Click me: " .. tostring(counter:getValue()) end),
			Size = UDim2.fromScale(1, 1),
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			TextColor3 = Color3.new(1, 1, 1),
		}),
	})
	local handle = Roact.mount(button, target)

	return function()
		Roact.unmount(handle)
	end
end
