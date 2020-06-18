local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")

local e = Roact.createElement

local TextButton = Roact.PureComponent:extend("TextButton")

TextButton.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	text = "Default Text",
	mouse1Clicked = nil,
	mouse1Pressed = nil,
	disabled = false,
}

local ITextButton = t.interface({
	size = t.optional(t.UDim2),
	position = t.optional(t.UDim2),
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	text = t.string,
	mouse1Clicked = t.optional(t.callback),
	mouse1Pressed = t.optional(t.callback),
	disabled = t.boolean,
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
	local anchorPoint = props.anchorPoint
	local zIndex = props.zIndex
	local text = props.text
	local mouse1Clicked = props.mouse1Clicked
	local mouse1Pressed = props.mouse1Pressed
	local disabled = props.disabled

	return ThemeContext.withConsumer(function(theme)
		local colors = theme.colors

		-- TODO: make me modal
		return e(Button, {
			size = size,
			position = position,
			layoutOrder = layoutOrder,
			anchorPoint = anchorPoint,
			zIndex = zIndex,
			buttonStateChanged = self.updateButtonState,
			mouse1Clicked = mouse1Clicked,
			mouse1Pressed = mouse1Pressed,
			disabled = disabled,
		}, {
			Text = e("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Text = text,
				TextColor3 = self.buttonState:map(function(state)
					if disabled then
						return colors.ButtonText.Disabled
					else
						return colors.ButtonText[state]
					end
				end),
				Font = Constants.FONT_DEFAULT,
				TextSize = Constants.TEXT_SIZE_DEFAULT,
				BackgroundColor3 = self.buttonState:map(function(state)
					if disabled then
						return colors.Button.Disabled
					else
						return colors.Button[state]
					end
				end),
				BorderColor3 = self.buttonState:map(function(state)
					if disabled then
						return colors.ButtonBorder.Disabled
					else
						return colors.ButtonBorder[state]
					end
				end),
				BorderMode = Enum.BorderMode.Inset,
			})
		})
	end)
end

return TextButton
