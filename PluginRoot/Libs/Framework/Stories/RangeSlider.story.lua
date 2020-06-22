local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local RangeSlider = load("Framework/RangeSlider")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

local RangeSliderStory = Roact.Component:extend("RangeSliderStory")

function RangeSliderStory:init()
	self.state = {
		value = 1,
	}
end

function RangeSliderStory:render()
	local snapSlider = e(RangeSlider, {
		size = UDim2.new(0, 213, 0, 24),
		position = UDim2.new(0, 24, 0, 24),
		valueChanged = function(value)
			self:setState({
				value = value,
			})
		end,
		value = self.state.value,
		min = 0,
		max = 10,
		step = 0.5,
		editRound = 4,
		displayRound = 4,
	})

	local freeSlider = e(RangeSlider, {
		size = UDim2.new(0, 213, 0, 24),
		position = UDim2.new(0, 24, 0, 52),
		valueChanged = function(value)
			self:setState({
				value = value,
			})
		end,
		value = self.state.value,
		min = 0,
		max = 10,
		editRound = 4,
		displayRound = 4,
	})

	local disabledSlider = e(RangeSlider, {
		size = UDim2.new(0, 213, 0, 24),
		position = UDim2.new(0, 24, 0, 80),
		value = self.state.value,
		min = -5,
		max = 5,
		disabled = true
	})

	return Roact.createFragment({
		snapSlider, freeSlider, disabledSlider,
	})
end

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local story = e(RangeSliderStory)

	local handle = Roact.mount(
		StoryWrapper(
			{ modalTarget = target },
			story
	), target)

	return function()
		Roact.unmount(handle)
	end
end


