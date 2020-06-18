local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local ThemeContext = load("Framework/ThemeContext")
local Button = load("Framework/Button")

local e = Roact.createElement

local DropdownChoiceButton = Roact.PureComponent:extend("DropdownChoiceButton")

DropdownChoiceButton.defaultProps = {
	sizeBinding = nil,
	index = nil,
	hoveredIndexBinding = nil,
	choicePressed = nil,
	buttonStateChanged = nil,

	[Roact.Children] = nil,

	-- Injected by ThemeContext.connect
	theme = nil,
}

local IDropdownChoiceButton = t.strictInterface({
	sizeBinding = t.table,
	index = t.integer,
	hoveredIndexBinding = t.table,
	choicePressed = t.callback,
	buttonStateChanged = t.callback,

	[Roact.Children] = t.optional(t.table),

	theme = t.table,
})

DropdownChoiceButton.validateProps = IDropdownChoiceButton

function DropdownChoiceButton:init()
	self.backgroundColor = self.props.hoveredIndexBinding:map(function(idx)
		local colors = self.props.theme.colors

		if self.props.index == idx then
			return colors.DropdownChoiceBackground.Hovered
		else
			return colors.DropdownChoiceBackground.Default
		end
	end)
	self.onChoicePressed = function()
		self.props.choicePressed(self.props.index)
	end
	self.onButtonStateChanged = function(buttonState)
		self.props.buttonStateChanged(self.props.index, buttonState)
	end
end

function DropdownChoiceButton:render()
	local props = self.props
	local sizeBinding = props.sizeBinding
	local index = props.index

	return e("Frame", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = sizeBinding,
		LayoutOrder = index,
		BackgroundColor3 = self.backgroundColor,
	}, {
		ChoiceButton = e(Button, {
			size = UDim2.new(1, 0, 1, 0),
			mouse1Pressed = self.onChoicePressed,
			buttonStateChanged = self.onButtonStateChanged,
		}, props[Roact.Children])
	})
end

return ThemeContext.connect(DropdownChoiceButton, function(theme)
	return {theme = theme}
end)
