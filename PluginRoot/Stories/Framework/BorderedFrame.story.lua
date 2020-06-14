local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local BorderedFrame = load("Framework/BorderedFrame")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local squareFrame = e(BorderedFrame, {
		size = UDim2.new(0, 100, 0, 100),
		position = UDim2.new(0, 100, 0, 100),
		borderStyle = "Square",
		backgroundColor = Color3.new(0, 1, 0),
		borderColor = Color3.new(0, 0, 1),
	}, {
		Text = e("TextLabel", {
			BackgroundTransparency = 1,
			Text = "borderStyle = Square",
			Size = UDim2.fromScale(1, 1),
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			TextColor3 = Color3.new(1, 1, 1),
		}),
	})
	local squareHandle = Roact.mount(squareFrame, target)

	local roundFrame = e(BorderedFrame, {
		size = UDim2.new(0, 100, 0, 100),
		position = UDim2.new(0, 100, 0, 220),
		borderStyle = "Round",
		backgroundColor = Color3.new(1, 0, 0),
		borderColor = Color3.new(0, 1, 0),
	}, {
		Text = e("TextLabel", {
			BackgroundTransparency = 1,
			Text = "borderStyle = Round",
			Size = UDim2.fromScale(1, 1),
			TextStrokeColor3 = Color3.new(0, 0, 0),
			TextStrokeTransparency = 0,
			TextColor3 = Color3.new(1, 1, 1),
		}),
	})
	local roundHandle = Roact.mount(roundFrame, target)

	return function()
		Roact.unmount(squareHandle)
		Roact.unmount(roundHandle)
	end
end
