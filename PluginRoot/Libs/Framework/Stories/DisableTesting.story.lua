local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local TextButton = load("Framework/TextButton")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

local DisabledTestingStory = Roact.Component:extend("DisabledTestingStory")

function DisabledTestingStory:init()
	self.state = {
		enabledButton = 1,
	}
end

function DisabledTestingStory:render()
	return Roact.createFragment({
		e(TextButton, {
			size = UDim2.new(0, 100, 0, 100),
			position = UDim2.new(0, 100, 0, 100),
			text = self.state.enabledButton ~= 1 and "Disabled" or "Enabled",
			disabled = self.state.enabledButton ~= 1,
			mouse1Clicked = function()
				self:setState({
					enabledButton = 2,
				})
			end
		}),

		e(TextButton, {
			size = UDim2.new(0, 100, 0, 100),
			position = UDim2.new(0, 200, 0, 100),
			text = self.state.enabledButton ~= 2 and "Disabled" or "Enabled",
			disabled = self.state.enabledButton ~= 2,
			mouse1Clicked = function()
				self:setState({
					enabledButton = 3,
				})
			end
		}),

		e(TextButton, {
			size = UDim2.new(0, 100, 0, 100),
			position = UDim2.new(0, 300, 0, 100),
			text = self.state.enabledButton ~= 3 and "Disabled" or "Enabled",
			disabled = self.state.enabledButton ~= 3,
			mouse1Clicked = function()
				self:setState({
					enabledButton = 1,
				})
			end
		}),
	})
end

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local fragment = Roact.createFragment({
		e(DisabledTestingStory)
	})

	local handle = Roact.mount(StoryWrapper({ modalTarget = target }, fragment), target)

	return function()
		Roact.unmount(handle)
	end
end

