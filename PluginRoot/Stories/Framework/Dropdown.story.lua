local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local Dropdown = load("Framework/Dropdown")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local DropdownStory = Roact.Component:extend("DropdownStory")

	function DropdownStory:init()
		self.state = {
			selected = nil
		}
	end

	function DropdownStory:render()
		local selected = self.state.selected
		local buttonDisplay = e("TextLabel", {
			Text = selected and "Choice " .. selected or "Select something.",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = Color3.new(1, 1, 1),
		})

		local choices = {}
		for i = 1, 10 do
			choices[i] = {
				data = i,
				display = e("TextLabel", {
					Text = "Choice " .. i,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					TextColor3 = Color3.new(1, 1, 1),
				})
			}
		end

		local dropdown = e(Dropdown, {
			position = UDim2.new(0, 20, 0, 20),
			size = UDim2.new(0, 100, 0, 24),
			choices = choices,
			choiceSelected = function(idx, data)
				self:setState({
					selected = data,
				})
			end,
			buttonDisplay = buttonDisplay,
		})

		return dropdown
	end


	local handle = Roact.mount(e(DropdownStory), target)

	return function()
		Roact.unmount(handle)
	end
end
