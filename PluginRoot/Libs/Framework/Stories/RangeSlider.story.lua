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
	local rangeSlider = e(RangeSlider, {
		size = UDim2.new(0, 200, 0, 24),
		position = UDim2.new(0, 100, 0, 100),
		valueChanged = function(value)
			self:setState({
				value = value,
			})
		end,
		value = self.state.value,
		min = -5,
		max = 5,
	})

	local rangeSliderDisabled = e(RangeSlider, {
		size = UDim2.new(0, 200, 0, 24),
		position = UDim2.new(0, 100, 0, 130),
		disabled = true
	})

	return Roact.createFragment({
		rangeSlider, rangeSliderDisabled,
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


