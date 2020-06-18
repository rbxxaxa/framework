local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local TextDropdown = load("Framework/TextDropdown")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

local TextDropdownStory = Roact.Component:extend("TextDropdownStory")

function TextDropdownStory:init()
	self.state = {
		selected = nil
	}
end

function TextDropdownStory:render()
	local choiceDatas = {}
	local choiceTexts = {}
	for i = 1, 10 do
		choiceDatas[i] = i
		choiceTexts[i] = "Choice " .. i
	end

	local dropdown = e(TextDropdown, {
		position = UDim2.new(0, 20, 0, 20),
		size = UDim2.new(0, 200, 0, 24),
		choiceDatas = choiceDatas,
		choiceTexts = choiceTexts,
		choiceSelected = function(idx, data)
			self:setState({
				selected = data,
				selectedIdx = idx,
			})
		end,
		buttonText = choiceTexts[self.state.selectedIdx],
		disabled = false,
	})

	local disabledDropdown = e(TextDropdown, {
		position = UDim2.new(0, 20, 0, 50),
		size = UDim2.new(0, 200, 0, 24),
		choiceDatas = {},
		choiceTexts = {},
		buttonText = "This dropdown is disabled.",
		disabled = true,
	})

	return Roact.createFragment({
		dropdown, disabledDropdown,
	})
end

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local handle = Roact.mount(
		StoryWrapper(
			{ modalTarget = target },
			e(TextDropdownStory)
	), target)

	return function()
		Roact.unmount(handle)
	end
end
