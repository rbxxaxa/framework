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
	choices = nil,
	buttonDisplay = nil,
	selected = nil,
}

local IDropdown = t.interface({
	size = t.UDim2,
	choiceSize = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	maxRows = t.integer,
	choices = t.optional(t.table),
	buttonDisplay = t.optional(t.table),
	selected = t.optional(t.callback),
})

Dropdown.validateProps = function(props)
	return IDropdown(props)
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
	local choices = props.choices
	local buttonDisplay = props.buttonDisplay
	local selected = props.selected

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
	if choices then
		for i, choice in ipairs(choices) do
			scrollingFrameChildren[i] = e(Button,{
				size = self.choiceHeight:map(function(height) return UDim2.new(1, 0, 0, height) end),
				layoutOrder = i,
				mouse1Pressed = function()
					if selected then
						selected(i, choice.data)
					end
					self:setState({
						open = false
					})
				end,
			}, {
				choice.display,
			})
		end
	end

	children.EntriesScrollingFrame = e(ScrollingVerticalList, {
		position = UDim2.new(0, 0, 1, 4),
		size = UDim2.new(1, 0, math.min(maxRows, choices and #choices or 0), 0),
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
