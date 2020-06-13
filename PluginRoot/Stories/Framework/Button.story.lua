local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local Button = load("Framework/Button")

local e = Roact.createElement

return function(target)
	local pressCount, updatePressCount = Roact.createBinding(0)
	local clickCount, updateClickCount = Roact.createBinding(0)
	local buttonState, updateButtonState = Roact.createBinding("Default")

	local button  = e(Button, {
		size = UDim2.new(0, 100, 0, 100),
		position = UDim2.new(0, 100, 0, 100),
		mouse1Press = function()
			updatePressCount(pressCount:getValue() + 1)
		end,
		mouse1Click = function()
			updateClickCount(clickCount:getValue() + 1)
		end,
		buttonStateChange = updateButtonState,
	}, {
		Frame = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
		}),

		Text = e("TextLabel", {
			BackgroundTransparency = 1,
			Text = Roact.joinBindings({pressCount, clickCount, buttonState}):map(function(values)
				return ("Pressed: %d\nClicked: %d\nState: %s"):format(values[1], values[2], values[3])
			end),
			Size = UDim2.fromScale(1, 1),
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
		}),
	})
	local handle = Roact.mount(button, target)

	return function()
		Roact.unmount(handle)
	end
end
