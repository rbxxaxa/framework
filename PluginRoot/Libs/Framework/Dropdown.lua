local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ScrollingVerticalList = load("Framework/ScrollingVerticalList")

local e = Roact.createElement

local Dropdown = Roact.Component:extend("Dropdown")

Dropdown.defaultProps = {
	size = UDim2.new(0, 100, 0, 24),
	position = UDim2.new(),
	layoutOrder = 0,
	maxRows = 6,
	buttonDisplay = nil,
	choiceSelected = nil,
	hoveredIndexChanged = nil,
	choiceDatas = nil,
	choiceDisplays = nil,
}

local IDropdown = t.interface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	maxRows = t.integer,
	buttonDisplay = t.optional(t.table),
	choiceSelected = t.optional(t.callback),
	hoveredIndexChanged = t.optional(t.callback),
	choiceDatas = t.optional(t.table),
	choiceDisplays = t.optional(t.table),
})

Dropdown.validateProps = function(props)
	local ok, err = IDropdown(props)
	if not ok then
		return false, err
	end

	local choiceDatas, choiceDisplays = props.choiceDatas, props.choiceDisplays
	if choiceDatas == nil and choiceDisplays ~= nil then
		return false, "choiceDisplay was provided but choiceDatas is missing."
	end
	if choiceDatas ~= nil and choiceDisplays == nil then
		return false, "choiceDatas was provided but choiceDisplays is missing."
	end

	if choiceDatas ~= nil and choiceDisplays ~= nil then
		if #choiceDatas ~= #choiceDisplays then
			return false, "number of choiceDatas and choiceDisplays do not match."
		end
	end

	return true
end

function Dropdown:init()
	self.state = {
		open = false,
	}

	self.choiceHeight, self.updateChoiceHeight = Roact.createBinding(self.props.size.Y.Offset)
	self.onDropdownButtonPressed = function()
		self:setState({
			open = true,
		})
	end
end

function Dropdown:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local maxRows = props.maxRows
	local buttonDisplay = props.buttonDisplay
	local choiceSelected = props.choiceSelected
	local hoveredIndexChanged = props.hoveredIndexChanged
	local choiceDatas = props.choiceDatas
	local choiceDisplays = props.choiceDisplays

	local numberOfChoices = choiceDatas and #choiceDatas or 0

	-- TODO: theme me
	local theme = {
		choicesBackground = Color3.new(0, 0, 0),
		buttonBackground = Color3.new(0, 0, 0),
		arrow = Color3.new(1, 1, 1),
	}

	-- TODO: render an arrow
	-- TODO: highlight when mousing over + other button state changes
	local children = {}
	children.DisplayBacker = e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.buttonBackground,
		BorderSizePixel = 0,
	}, {
		Display = buttonDisplay,
	})

	local scrollingFrameChildren = {}
	if numberOfChoices > 0 then
		for choiceIndex = 1, numberOfChoices do
			local choiceDisplay = choiceDisplays[choiceIndex]
			local choiceData = choiceDatas[choiceIndex]
			scrollingFrameChildren[choiceIndex] = e("Frame", {
				BackgroundTransparency = 1,
				Size = self.choiceHeight:map(function(height) return UDim2.new(1, 0, 0, height) end),
				LayoutOrder = choiceIndex,
			}, {
				ChoiceButton = e(Button, {
					size = UDim2.new(1, 0, 1, 0),
					mouse1Pressed = function()
						if choiceSelected then
							choiceSelected(choiceIndex, choiceData)
						end
						self:setState({
							open = false
						})
						if hoveredIndexChanged then
							hoveredIndexChanged(0)
						end
					end,
					buttonStateChanged = function(buttonState)
						if buttonState == "Hovered" then
							if hoveredIndexChanged then
								hoveredIndexChanged(choiceIndex)
							end
						end
					end,
				}, {
					choiceDisplay,
				})
			})
		end
	end

	children.EntriesScrollingFrame = e(ScrollingVerticalList, {
		position = UDim2.new(0, 0, 1, 4),
		size = UDim2.new(1, 0, math.min(maxRows, numberOfChoices), 0),
		visible = self.state.open,
		paddingTop = 0,
		paddingRight = 0,
		paddingBottom = 0,
		paddingLeft = 0,
		paddingList = 0,
		contentBackgroundColor = theme.choicesBackground,
	}, scrollingFrameChildren)

	-- TODO: make me modal
	-- TODO: close when clicking out of the dropdown
	return e(Button, {
		size = size,
		position = position,
		layoutOrder = layoutOrder,
		mouse1Pressed = self.onDropdownButtonPressed,
		[Roact.Change.AbsoluteSize] = function(rbx)
			self.updateChoiceHeight(rbx.AbsoluteSize.Y)
		end,
	}, children)
end

return Dropdown
