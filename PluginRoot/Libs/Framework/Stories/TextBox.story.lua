local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local TextBox = load("Framework/TextBox")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

local TextBoxStory = Roact.Component:extend("TextBoxStory")

function TextBoxStory:init()
	self.state.input = "Text!!!"
end

function TextBoxStory:render()
	return e(TextBox, {
		size = UDim2.new(0, 200, 0, 24),
		position = UDim2.new(0, 100, 0, 100),
		inputText = self.state.input,
		placeholderText = "This is some placeholder.",
		focusLost = function(text, submitted)
			self:setState({
				input = text,
			})
		end,
	})
end

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local story = e(TextBoxStory)

	local handle = Roact.mount(StoryWrapper({ modalTarget = target }, story), target)

	return function()
		Roact.unmount(handle)
	end
end

