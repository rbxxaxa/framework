local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Dropdown = load("Framework/Dropdown")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")

local e = Roact.createElement

local TextDropdown = Roact.Component:extend("TextDropdown")

TextDropdown.defaultProps = {
	size = UDim2.new(0, 100, 0, 24),
	position = UDim2.new(),
	layoutOrder = 0,
	maxRows = 6,
	choiceSelected = nil,
	buttonText = "Select a choice...",
	choiceDatas = nil,
	choiceTexts = nil,
}

local ITextDropdown = t.interface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	maxRows = t.integer,
	choiceSelected = t.optional(t.callback),
	buttonText = t.string,
	choiceDatas = t.optional(t.table),
	choiceTexts = t.optional(t.table),
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
end

local function createTextChoiceDisplay(theme, text, index, hoveredIndexBinding)
	local colors = theme.colors

	return e("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		Text = text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextColor3 = hoveredIndexBinding:map(function(hoveredIndex)
			return index == hoveredIndex and colors.DropdownChoiceText.Hovered or colors.DropdownChoiceText.Default
		end),
		TextSize = Constants.FONT_SIZE_DEFAULT,
	})
end

function TextDropdown:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local maxRows = props.maxRows
	local choiceSelected = props.choiceSelected
	local buttonText = props.buttonText
	local choiceDatas = props.choiceDatas
	local choiceTexts = props.choiceTexts

	return ThemeContext.withConsumer(function(theme)
		local colors = theme.colors

		local choiceDisplays = nil
		if choiceDatas then
			choiceDisplays = {}
			for choiceIndex, choiceText in ipairs(choiceTexts) do
				choiceDisplays[choiceIndex] = createTextChoiceDisplay(theme, choiceText, choiceIndex, self.hoveredIndex)
			end
		end

		local buttonDisplay = e("TextLabel", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			Text = buttonText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			TextColor3 = colors.MainText.Default,
			TextSize = Constants.FONT_SIZE_DEFAULT,
		}, {
			Arrow = e("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 11, 0, 11),
				Image = "rbxassetid://5188755691",
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				ImageColor3 = colors.DropdownArrow.Default,
			}),
		})

		return e(Dropdown, {
			size = size,
			position = position,
			layoutOrder = layoutOrder,
			maxRows = maxRows,
			buttonDisplay = buttonDisplay,
			choiceSelected = choiceSelected,
			hoveredIndexChanged = self.updateHoveredIndex,
			choiceDatas = choiceDatas,
			choiceDisplays = choiceDisplays,
		})
	end)
end

return TextDropdown

