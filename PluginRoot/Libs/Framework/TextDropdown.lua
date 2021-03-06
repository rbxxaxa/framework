local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Dropdown = load("Framework/Dropdown")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")
local TextDropdownChoiceDisplay = load("Framework/TextDropdownChoiceDisplay")

local e = Roact.createElement

local TextDropdown = Roact.PureComponent:extend("TextDropdown")

TextDropdown.defaultProps = {
	size = UDim2.new(0, 100, 0, 24),
	position = UDim2.new(),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	maxRows = 6,
	disabled = false,
	choiceSelected = nil,
	buttonText = "Select a choice...",
	choiceDatas = nil,
	choiceTexts = nil,

	theme = nil, -- Injected by ThemeContext.connect
}

local ITextDropdown = t.strictInterface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	maxRows = t.integer,
	disabled = t.boolean,
	choiceSelected = t.optional(t.callback),
	buttonText = t.string,
	choiceDatas = t.optional(t.table),
	choiceTexts = t.optional(t.table),

	theme = t.table,
})

TextDropdown.validateProps = function(props)
	local ok, err = ITextDropdown(props)
	if not ok then
		return false, err
	end

	local choiceDatas, choiceTexts = props.choiceDatas, props.choiceTexts
	if choiceDatas == nil and choiceTexts ~= nil then
		return false, "choiceDisplay was provided but choiceDatas is missing."
	end
	if choiceDatas ~= nil and choiceTexts == nil then
		return false, "choiceDatas was provided but choiceTexts is missing."
	end

	if choiceDatas ~= nil and choiceTexts ~= nil then
		if #choiceDatas ~= #choiceTexts then
			return false, "number of choiceDatas and choiceTexts do not match."
		end
	end

	return true
end

function TextDropdown:init()
	self.hoveredIndex, self.updateHoveredIndex = Roact.createBinding(0)
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
	self.disabled, self.updateDisabled = Roact.createBinding(self.props.disabled)
	self.open, self.updateOpen = Roact.createBinding(false)
	self.appearanceState = Roact.joinBindings({
		buttonState = self.buttonState,
		open = self.open,
		disabled = self.disabled,
	}):map(function(joined)
		if joined.disabled then
			return "Disabled"
		elseif joined.open then
			return "Focused"
		elseif joined.buttonState == "Hovered" then
			return "Hovered"
		else
			return "Default"
		end
	end)

	self.arrowColor = self.appearanceState:map(function(appearanceState)
		local colors = self.props.theme.colors
		return colors.DropdownArrow[appearanceState]
	end)

	self.buttonTextColor = self.appearanceState:map(function(appearanceState)
		local colors = self.props.theme.colors
		return colors.DropdownButtonText[appearanceState]
	end)
end

function TextDropdown:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local anchorPoint = props.anchorPoint
	local zIndex = props.zindex
	local maxRows = props.maxRows
	local disabled = props.disabled
	local choiceSelected = props.choiceSelected
	local buttonText = props.buttonText
	local choiceDatas = props.choiceDatas
	local choiceTexts = props.choiceTexts

	local choiceDisplays = nil
	if choiceDatas then
		choiceDisplays = {}
		for choiceIndex, choiceText in ipairs(choiceTexts) do
			choiceDisplays[choiceIndex] = e(TextDropdownChoiceDisplay, {
				text = choiceText,
				index = choiceIndex,
				hoveredIndexBinding = self.hoveredIndex,
			})
		end
	end

	local buttonDisplay = e("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		Text = buttonText,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextColor3 = self.buttonTextColor,
		TextSize = Constants.TEXT_SIZE_DEFAULT,
		Font = Constants.FONT_DEFAULT,
	}, {
		Arrow = e("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 11, 0, 11),
			Image = "rbxassetid://5188755691",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			ImageColor3 = self.arrowColor,
		}),
	})

	return e(Dropdown, {
		size = size,
		position = position,
		layoutOrder = layoutOrder,
		anchorPoint = anchorPoint,
		zIndex = zIndex,
		maxRows = maxRows,
		disabled = disabled,
		buttonDisplay = buttonDisplay,
		choiceSelected = choiceSelected,
		hoveredIndexChanged = self.updateHoveredIndex,
		choiceDatas = choiceDatas,
		choiceDisplays = choiceDisplays,
		buttonStateChanged = self.updateButtonState,
	})
end

function TextDropdown:didUpdate()
	self.updateDisabled(self.props.disabled)
end

return ThemeContext.connect(TextDropdown, function(theme)
	return {theme = theme}
end)
