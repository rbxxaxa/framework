local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")

local e = Roact.createElement

local TextDropdownChoiceDisplay = Roact.PureComponent:extend("TextDropdownChoiceDisplay")

TextDropdownChoiceDisplay.defaultProps = {
	text = nil,
	index = nil,
	hoveredIndexBinding = nil,

	theme = nil, -- Injected by ThemeContext.connect
}

local ITextDropdownChoiceDisplay = t.strictInterface({
	text = t.string,
	index = t.integer,
	hoveredIndexBinding = t.table,

	theme = t.table,
})

TextDropdownChoiceDisplay.validateProps = ITextDropdownChoiceDisplay

function TextDropdownChoiceDisplay:init()
	self.textColor = self.props.hoveredIndexBinding:map(function(hoveredIndex)
		local colors = self.props.theme.colors

		return self.props.index == hoveredIndex and colors.DropdownChoiceText.Hovered or colors.DropdownChoiceText.Default
	end)
end

function TextDropdownChoiceDisplay:render()
	local text = self.props.text

	return e("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextColor3 = self.textColor,
		TextSize = Constants.TEXT_SIZE_DEFAULT,
		Font = Constants.FONT_DEFAULT
	})
end

return ThemeContext.connect(TextDropdownChoiceDisplay, function(theme)
	return {theme = theme}
end)
