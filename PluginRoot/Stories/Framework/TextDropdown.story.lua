local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local TextDropdown = load("Framework/TextDropdown")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local TextDropdownStory = Roact.Component:extend("TextDropdownStory")

	function TextDropdownStory:init()
		self.state = {
			selected = nil
		}
	end

	function TextDropdownStory:render()
		local selectedData = self.state.selected

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
					selectedData = data,
					selectedIdx = idx,
				})
			end,
			buttonText = choiceTexts[self.state.selectedIdx],
		})

		return dropdown
	end


	local handle = Roact.mount(StoryWrapper(e(TextDropdownStory)), target)

	return function()
		Roact.unmount(handle)
	end
end
