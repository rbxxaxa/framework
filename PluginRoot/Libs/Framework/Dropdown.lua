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

	-- Injected by ModalTargetContext.connect
	modalTarget = nil,
	-- Injected by ThemeContext.connect
	theme = nil,
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
	self.onDropdownButtonPressed = function()
		if not self.state.open then
			self:setState({
				open = true,
			})
			if self.props.openChanged then
				self.props.openChanged(true)
			end
		end
	end
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
	self.onButtonStateChanged = function(buttonState)
		self.updateButtonState(buttonState)
		if self.props.buttonStateChanged then
			self.props.buttonStateChanged(buttonState)
		end
	end
	self.buttonBackgroundColor = self.buttonState:map(function(bs)
		local colors = self.props.theme.colors

		if self.props.disabled then
			return colors.DropdownButtonBackground.Disabled
		elseif self.state.open then
			return colors.DropdownButtonBackground.Focused
		elseif bs == "Hovered" then
			return colors.DropdownButtonBackground.Hovered
		else
			return colors.DropdownButtonBackground.Default
		end
	end)
	self.buttonBorderColor = self.buttonState:map(function(bs)
		local colors = self.props.theme.colors

		if self.props.disabled then
			return colors.DropdownButtonBorder.Disabled
		elseif self.state.open then
			return colors.DropdownButtonBorder.Focused
		elseif bs == "Hovered" then
			return colors.DropdownButtonBorder.Hovered
		else
			return colors.DropdownButtonBorder.Default
		end
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
	self.onBackgroundCloseDetectorClicked = function()
		self:setState({
			open = false,
		})
		if self.props.openChanged then
			self.props.openChanged(false)
		end
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
		local openChanged = props.openChanged

		local choiceData = choiceDatas[choiceIndex]

		if choiceSelected then
			choiceSelected(choiceIndex, choiceData)
		end
		self:setState({
			open = false
		})
		if openChanged then
			openChanged(false)
		end
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
	if prevProps.disabled ~= self.props.disabled then
		if self.props.disabled then
			-- Can't set state here... so we have to wait a frame.
			-- A little hacky, but this shouldn't be that bad.
			-- TODO: Revisit this at some point.
			RunService.RenderStepped:Wait()
			self:setState({
				open = false,
			})
			if self.props.openChanged then
				self.props.openChanged(false)
			end
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
	local maxRows = props.maxRows
	local disabled = props.disabled
	local buttonDisplay = props.buttonDisplay
	local choiceSelected = props.choiceSelected
	local hoveredIndexChanged = props.hoveredIndexChanged
	local choiceDatas = props.choiceDatas
	local choiceDisplays = props.choiceDisplays
	local openChanged = props.openChanged
	local modalTarget = self.props.modalTarget
	local theme = self.props.theme

	local numberOfChoices = choiceDatas and #choiceDatas or 0
	local colors = theme.colors

	local children = {}
	children.DisplayBacker = e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = self.buttonBackgroundColor,
		BorderColor3 = self.buttonBorderColor,
		BorderMode = Enum.BorderMode.Inset,
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
	children.DropdownEntries = self.state.open and ModalTargetContext.withConsumer(function(modalTarget)
		return e(Roact.Portal, {
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
	end)


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

return ThemeContext.connect(ModalTargetContext.connect(Dropdown, function(modalTarget)
	return {modalTarget = modalTarget}
end), function(theme)
	return {theme = theme}
end)
