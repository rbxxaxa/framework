local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")

local e = Roact.createElement

local TextButton = Roact.Component:extend("TextButton")

TextButton.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(),
	layoutOrder = 0,
	text = "Default Text",
	mouse1Clicked = nil,
	mouse1Pressed = nil,
}

local ITextButton = t.interface({
	size = t.optional(t.UDim2),
	position = t.optional(t.UDim2),
	layoutOrder = t.integer,
	text = t.string,
	mouse1Clicked = t.optional(t.callback),
	mouse1Pressed = t.optional(t.callback),
})

TextButton.validateProps = function(props)
	return ITextButton(props)
end

function TextButton:init()
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
end

function TextButton:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local text = props.text
	local mouse1Clicked = props.mouse1Clicked
	local mouse1Pressed = props.mouse1Pressed

	return ThemeContext.withConsumer(function(theme)
		local colors = theme.colors

		-- TODO: make me modal
		return e(Button, {
			size = size,
			position = position,
			layoutOrder = layoutOrder,
			buttonStateChanged = self.updateButtonState,
			mouse1Clicked = mouse1Clicked,
			mouse1Pressed = mouse1Pressed,
		}, {
			Text = e("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Text = text,
				TextColor3 = self.buttonState:map(function(state)
					return colors.ButtonText[state]
				end),
				Font = Constants.FONT_DEFAULT,
				BorderSizePixel = 0,
				TextSize = Constants.FONT_SIZE_DEFAULT,
				BackgroundColor3 = self.buttonState:map(function(state)
					return colors.Button[state]
				end)
			})
		})
	end)
end

return TextButton

