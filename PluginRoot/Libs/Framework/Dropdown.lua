local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local RunService = game:GetService("RunService")

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ScrollingVerticalList = load("Framework/ScrollingVerticalList")
local ShadowedFrame = load("Framework/ShadowedFrame")
local ThemeContext = load("Framework/ThemeContext")
local ModalTargetContext = load("Framework/ModalTargetContext")
local DropdownChoiceButton = load("Framework/DropdownChoiceButton")
local BorderedFrame = load("Framework/BorderedFrame")

local e = Roact.createElement

local Dropdown = Roact.PureComponent:extend("Dropdown")

Dropdown.defaultProps = {
	size = UDim2.new(0, 100, 0, 24),
	position = UDim2.new(),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	maxRows = 6,
	disabled = false,
	buttonDisplay = nil,
	choiceSelected = nil,
	hoveredIndexChanged = nil,
	choiceDatas = nil,
	choiceDisplays = nil,
	openChanged = nil,
	buttonStateChanged = nil,

	modalTarget = nil, -- Injected by ModalTargetContext.connect
	theme = nil, -- Injected by ThemeContext.connect
}

local IDropdown = t.strictInterface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	maxRows = t.integer,
	disabled = t.boolean,
	buttonDisplay = t.optional(t.table),
	choiceSelected = t.optional(t.callback),
	hoveredIndexChanged = t.optional(t.callback),
	choiceDatas = t.optional(t.table),
	choiceDisplays = t.optional(t.table),
	openChanged = t.optional(t.callback),
	buttonStateChanged = t.optional(t.callback),

	modalTarget = t.table,
	theme = t.table,
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

	self.buttonAbsoluteSize, self.updateButtonAbsoluteSize = Roact.createBinding(Vector2.new())
	self.buttonAbsolutePosition, self.updateButtonAbsolutePosition = Roact.createBinding(Vector2.new())
	self.hoveredIndex, self.updateHoveredIndex = Roact.createBinding(0)
	self.disabled, self.updateDisabled = Roact.createBinding(self.props.disabled)
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
	self.open, self.updateOpen = Roact.createBinding(false)
	self.buttonAppearanceState = Roact.joinBindings({
		open = self.open,
		buttonState = self.buttonState,
		disabled = self.disabled,
	}):map(function(mapped)
		if mapped.disabled then
			return "Disabled"
		elseif mapped.open then
			return "Focused"
		elseif mapped.buttonState == "Hovered" then
			return "Hovered"
		else
			return "Default"
		end
	end)
	self.buttonBackgroundColor = self.buttonAppearanceState:map(function(colorState)
		local colors = self.props.theme.colors
		return colors.DropdownButtonBackground[colorState]
	end)
	self.buttonBorderColor = self.buttonAppearanceState:map(function(colorState)
		local colors = self.props.theme.colors
		return colors.DropdownButtonBorder[colorState]
	end)
	self.scrollingFrameEntrySize = self.buttonAbsoluteSize:map(function(absoluteSize)
		return UDim2.new(1, 0, 0, absoluteSize.Y)
	end)
	self.dropdownSize = self.buttonAbsoluteSize:map(function(absoluteSize)
		local numberOfChoices = self.props.choiceDatas and #self.props.choiceDatas or 0
		return UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y * math.min(self.props.maxRows, numberOfChoices))
	end)
	self.dropdownPosition = Roact.joinBindings({
		buttonAbsoluteSize = self.buttonAbsoluteSize,
		buttonAbsolutePosition = self.buttonAbsolutePosition
	}):map(function(mapped)
		local target = self.props.modalTarget.target

		local absoluteSize, absolutePosition = mapped.buttonAbsoluteSize, mapped.buttonAbsolutePosition
		local x = absolutePosition.X - target.AbsolutePosition.X
		local y = absolutePosition.Y + absoluteSize.Y - target.AbsolutePosition.Y + 3
		return UDim2.new(0, x, 0, y)
	end)

	self.onButtonStateChanged = function(buttonState)
		self.updateButtonState(buttonState)
		if self.props.buttonStateChanged then
			self.props.buttonStateChanged(buttonState)
		end
	end
	self.onDropdownButtonPressed = function()
		if not self.state.open then
			self:setOpen(true)
		end
	end
	self.onBackgroundCloseDetectorClicked = function()
		self:setOpen(false)
	end
	self.onButtonAbsoluteSizeChanged = function(rbx)
		self.updateButtonAbsoluteSize(rbx.AbsoluteSize)
	end
	self.onButtonAbsolutePositionChanged = function(rbx)
		self.updateButtonAbsolutePosition(rbx.AbsolutePosition)
	end
	self.onChoicePressed = function(choiceIndex)
		local props = self.props
		local choiceSelected = props.choiceSelected
		local choiceDatas = props.choiceDatas

		local choiceData = choiceDatas[choiceIndex]

		if choiceSelected then
			choiceSelected(choiceIndex, choiceData)
		end
		self:setOpen(false)
	end
	self.onChoiceButtonStateChanged = function(choiceIndex, buttonState)
		local props = self.props
		local hoveredIndexChanged = props.hoveredIndexChanged

		if buttonState == "Hovered" then
			self.updateHoveredIndex(choiceIndex)
			if hoveredIndexChanged then
				hoveredIndexChanged(choiceIndex)
			end
		elseif self.hoveredIndex:getValue() == choiceIndex then
			self.updateHoveredIndex(0)
			if hoveredIndexChanged then
				hoveredIndexChanged(0)
			end
		end
	end
end

function Dropdown:didUpdate(prevProps, prevState)
	self.updateDisabled(self.props.disabled)
	if prevProps.disabled ~= self.props.disabled then
		if self.props.disabled and self.state.open then
			-- Can't set state here... so we have to wait a frame.
			-- A little hacky, but this shouldn't be that bad.
			-- TODO: Revisit this at some point.
			RunService.RenderStepped:Wait()
			self:setOpen(false)
		end
	end
end

function Dropdown:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local anchorPoint = props.anchorPoint
	local zIndex = props.zIndex
	local disabled = props.disabled
	local buttonDisplay = props.buttonDisplay
	local choiceDatas = props.choiceDatas
	local choiceDisplays = props.choiceDisplays
	local modalTarget = self.props.modalTarget
	local theme = self.props.theme

	local numberOfChoices = choiceDatas and #choiceDatas or 0

	local children = {}
	children.ButtonDisplayBacker = e(BorderedFrame, {
		size = UDim2.new(1, 0, 1, 0),
		backgroundColorBinding = self.buttonBackgroundColor,
		borderColorBinding = self.buttonBorderColor,
		borderStyle = "Round",
	}, {
		Display = buttonDisplay,
	})

	local scrollingFrameChildren = {}
	if numberOfChoices > 0 then
		for choiceIndex = 1, numberOfChoices do
			local choiceDisplay = choiceDisplays[choiceIndex]
			scrollingFrameChildren[choiceIndex] = e(DropdownChoiceButton, {
				sizeBinding = self.scrollingFrameEntrySize,
				index = choiceIndex,
				hoveredIndexBinding = self.hoveredIndex,
				choicePressed = self.onChoicePressed,
				buttonStateChanged = self.onChoiceButtonStateChanged,
			}, {choiceDisplay})
		end
	end

	-- TODO: Render the dropdown above the button if there isn't enough space below to show the whole dropdown.
	children.DropdownEntries = self.state.open and e(Roact.Portal, {
		target = modalTarget.target,
	}, {
		e("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			BackgroundTransparency = 1,
			[Roact.Event.MouseButton1Down] = self.onBackgroundCloseDetectorClicked,
		}),

		e("Frame", {
			Size = self.dropdownSize,
			Position = self.dropdownPosition,
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			e(ShadowedFrame, {
				position = UDim2.new(0, 0, 0, 0),
				size = UDim2.new(1, 0, 1, 0),
			}, {
				e(ScrollingVerticalList, {
					size = UDim2.new(1, 0, 1, 0),
					paddingTop = 0,
					paddingRight = 0,
					paddingBottom = 0,
					paddingLeft = 0,
					paddingList = 0,
					contentBackgroundColor = theme.choicesBackground,
				}, scrollingFrameChildren)
			})
		})
	})

	-- TODO: make me modal
	return e("Frame", {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		[Roact.Change.AbsoluteSize] = self.onButtonAbsoluteSizeChanged,
		[Roact.Change.AbsolutePosition] = self.onButtonAbsolutePositionChanged,
		BackgroundTransparency = 1,
	}, {
		e(Button, {
			size = UDim2.new(1, 0, 1, 0),
			mouse1Pressed = self.onDropdownButtonPressed,
			buttonStateChanged = self.onButtonStateChanged,
			disabled = disabled,
		}, children)
	})
end

function Dropdown:setOpen(open)
	self:setState({
		open = open,
	})
	self.updateOpen(open)
	if self.props.openChanged then
		self.props.openChanged(open)
	end
end

return ThemeContext.connect(ModalTargetContext.connect(Dropdown, function(modalTarget)
	return {modalTarget = modalTarget}
end), function(theme)
	return {theme = theme}
end)
