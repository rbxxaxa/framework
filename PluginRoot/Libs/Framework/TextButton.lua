local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local ButtonDetector = load("Framework/ButtonDetector")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")
local BorderedFrame = load("Framework/BorderedFrame")

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

	theme = nil, -- Injected by ThemeContext.connect
}

local ITextButton = t.strictInterface({
	size = t.optional(t.UDim2),
	position = t.optional(t.UDim2),
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	text = t.string,
	mouse1Clicked = t.optional(t.callback),
	mouse1Pressed = t.optional(t.callback),
	disabled = t.boolean,

	theme = t.table,
})

TextButton.validateProps = function(props)
	return ITextButton(props)
end

function TextButton:init()
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
	self.disabled, self.updateDisabled = Roact.createBinding(self.props.disabled)
	local buttonAppearance = Roact.joinBindings({
		disabled = self.disabled,
		buttonState = self.buttonState,
	}):map(function(joined)
		if joined.disabled then
			return "Disabled"
		else
			return joined.buttonState
		end
	end)

	self.textColor = buttonAppearance:map(function(appearance)
		local colors = self.props.theme.colors
		return colors.ButtonText[appearance]
	end)
	self.backgroundColor = buttonAppearance:map(function(appearance)
		local colors = self.props.theme.colors
		return colors.Button[appearance]
	end)
	self.borderColor = buttonAppearance:map(function(appearance)
		local colors = self.props.theme.colors
		return colors.ButtonBorder[appearance]
	end)
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

	-- TODO: make me modal
	return e(ButtonDetector, {
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
		Backer = e(BorderedFrame, {
			size = UDim2.new(1, 0, 1, 0),
			backgroundColorBinding = self.backgroundColor,
			borderColorBinding = self.borderColor,
			borderStyle = "Round",
		}),
		Text = e("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = text,
			TextColor3 = self.textColor,
			Font = Constants.FONT_DEFAULT,
			TextSize = Constants.TEXT_SIZE_DEFAULT,
			BackgroundTransparency = 1,
			ZIndex = 2,
		})
	})
end

function TextButton:didUpdate()
	self.updateDisabled(self.props.disabled)
end

return ThemeContext.connect(TextButton, function(theme)
	return {theme = theme}
end)
