local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Dropdown = load("Framework/Dropdown")

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

-- TODO: Theme me
-- PS: hoveredIndexBinding may turn out to be unecessary
local function createTextChoiceDisplay(theme, text, index, hoveredIndexBinding)
	return e("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		Text = text,
		BackgroundTransparency = 1,
		TextColor3 = hoveredIndexBinding:map(function(hoveredIndex)
			return index == hoveredIndex and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
		end),
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

	-- TODO: Theme me
	local theme = {}

	local choiceDisplays = nil
	if choiceDatas then
		choiceDisplays = {}
		for choiceIndex, choiceText in ipairs(choiceTexts) do
			choiceDisplays[choiceIndex] = createTextChoiceDisplay(theme, choiceText, choiceIndex, self.hoveredIndex)
		end
	end

	local buttonDisplay = e("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		Text = buttonText,
		BackgroundTransparency = 1,
		TextColor3 = Color3.new(1, 1, 1),
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
end

return TextDropdown

