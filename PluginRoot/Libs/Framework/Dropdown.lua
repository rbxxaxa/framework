local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ScrollingVerticalList = load("Framework/ScrollingVerticalList")
local ShadowedFrame = load("Framework/ShadowedFrame")
local ThemeContext = load("Framework/ThemeContext")
local ModalTargetContext = load("Framework/ModalTargetContext")

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

	self.buttonAbsoluteSize, self.updateButtonAbsoluteSize = Roact.createBinding(Vector2.new())
	self.buttonAbsolutePosition, self.updateButtonAbsolutePosition = Roact.createBinding(Vector2.new())
	self.canvasOffset, self.updateCanvasOffset = Roact.createBinding(0)
	self.hoveredIndex, self.updateHoveredIndex = Roact.createBinding(0)
	self.onDropdownButtonPressed = function()
		if not self.state.open then
			self:setState({
				open = true,
			})
		else
			self:setState({
				open = false,
			})
		end
	end
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
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

	return ThemeContext.withConsumer(function(theme)
		local colors = theme.colors

		-- TODO: render an arrow
		local children = {}
		children.DisplayBacker = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = self.buttonState:map(function(bs)
				if self.state.open then
					return colors.InputFieldBackground.Focused
				elseif bs == "Hovered" then
					return colors.InputFieldBackground.Hovered
				else
					return colors.InputFieldBackground.Default
				end
			end),
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
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					Size = self.buttonAbsoluteSize:map(function(absoluteSize) return UDim2.new(1, 0, 0, absoluteSize.Y) end),
					LayoutOrder = choiceIndex,
					BackgroundColor3 = self.hoveredIndex:map(function(idx)
						if choiceIndex == idx then
							return colors.DropdownChoiceBackground.Hovered
						else
							return colors.DropdownChoiceBackground.Default
						end
					end)
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
							self.updateCanvasOffset(0)
						end,
						buttonStateChanged = function(buttonState)
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
						end,
					}, {
						choiceDisplay,
					})
				})
			end
		end

		children.DropdownEntries = self.state.open and ModalTargetContext.withConsumer(function(modalTarget)
			return e(Roact.Portal, {
				target = modalTarget.target,
			}, {
				e("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					BackgroundTransparency = 1,
					[Roact.Event.MouseButton1Down] = function()
						self:setState({
							open = false,
						})
					end,
				}),

				e("Frame", {
					Size = self.buttonAbsoluteSize:map(function(absoluteSize)
						return UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y * math.min(maxRows, numberOfChoices))
					end),
					Position = Roact.joinBindings({self.buttonAbsoluteSize, self.buttonAbsolutePosition}):map(function(joined)
						local absoluteSize, absolutePosition = joined[1], joined[2]
						local x = absolutePosition.X - modalTarget.target.AbsolutePosition.X
						local y = absolutePosition.Y + absoluteSize.Y - modalTarget.target.AbsolutePosition.Y + 3
						return UDim2.new(0, x, 0, y)
					end),
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
							CanvasPosition = self.canvasOffset:map(function(offset)
								return Vector2.new(0, offset)
							end),
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
			[Roact.Change.AbsoluteSize] = function(rbx)
				self.updateButtonAbsoluteSize(rbx.AbsoluteSize)
			end,
			[Roact.Change.AbsolutePosition] = function(rbx)
				self.updateButtonAbsolutePosition(rbx.AbsolutePosition)
			end,
			BackgroundTransparency = 1,
		}, {
			e(Button, {
				size = UDim2.new(1, 0, 1, 0),
				mouse1Pressed = self.onDropdownButtonPressed,
				buttonStateChanged = self.updateButtonState,
			}, children)
		})
	end)
end

return Dropdown
