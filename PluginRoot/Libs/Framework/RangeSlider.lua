local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local RunService = game:GetService("RunService")

local Roact = load("Roact")
local t = load("t")
local ButtonDetector = load("Framework/ButtonDetector")
local TextBox = load("Framework/TextBox")
local ThemeContext = load("Framework/ThemeContext")
local ModalTargetContext = load("Framework/ModalTargetContext")
local ShadowedFrame = load("Framework/ShadowedFrame")
local BorderedFrame = load("Framework/BorderedFrame")

local e = Roact.createElement

local RangeSlider = Roact.Component:extend("RangeSlider")

RangeSlider.defaultProps = {
	size = UDim2.new(0, 100, 0, 24),
	position = UDim2.new(),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	min = 0,
	max = 1,
	value = 0.5,
	displayRound = 2,
	editRound = 2,
	step = nil,
	disabled = false,
	valueChanged = nil,

	modalTarget = nil, -- Injected by ModalTargetContext.connect
	theme = nil, -- Injected by ThemeContext.connect
}

local IRangeSlider = t.strictInterface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	min = t.number,
	max = t.number,
	value = t.number,
	displayRound = t.integer,
	editRound = t.integer,
	step = t.optional(t.number),
	disabled = t.boolean,
	valueChanged = t.optional(t.callback),

	modalTarget = t.table,
	theme = t.table,
})

RangeSlider.validateProps = function(props)
	local ok, err = IRangeSlider(props)
	if not ok then
		return false, err
	end

	if props.min >= props.max then
		return false, "max should be greater than min."
	end

	if props.displayRound < 0 then
		return false, "displayRound only supports positive values."
	end

	if props.editRound < 0 then
		return false, "editRound only supports positive values."
	end

	return true
end

local function round(n, multiple)
	multiple = multiple or 1
	return (math.floor(n / multiple + 1 / 2) * multiple)
end

function RangeSlider:init()
	self.state = {
		open = false,
	}

	self.open, self.updateOpen = Roact.createBinding(false)
	self.absoluteSize, self.updateAbsoluteSize = Roact.createBinding(Vector2.new(0, 0))
	self.absolutePosition, self.updateAbsolutePosition = Roact.createBinding(Vector2.new(0, 0))
	self.draggerButtonState, self.updateDraggerButtonState = Roact.createBinding("Default")

	self.onAbsoluteSizeChanged = function(rbx)
		self.updateAbsoluteSize(rbx.AbsoluteSize)
	end
	self.onAbsolutePositionChanged = function(rbx)
		self.updateAbsolutePosition(rbx.AbsolutePosition)
	end
	self.onBackgroundCloseDetectorClicked = function()
		self:setOpen(false)
	end
	self.onMouseMoved = function(rbx, x, y)
		self.updateMousePosition(Vector2.new(x, y))
	end
	self.onActivatedChanged = function(activated)
		self.dragging = activated
		local dragPercent = self:calculateDragPercent()
		self.onValueDragged(dragPercent)
	end
	self.hConn = RunService.RenderStepped:Connect(function()
		if self.dragging then
			local dragPercent = self:calculateDragPercent()
			self.onValueDragged(dragPercent)
		end
	end)
	self.onValueDragged = function(percent)
		local min, max = self.props.min, self.props.max
		percent = math.clamp(percent, 0, 1)

		local newValue
		if percent == 0 then
			newValue = min
		elseif percent == 1 then
			newValue = max
		else
			if self.props.step then
				newValue = min + round((max-min) * percent, self.props.step)
			else
				newValue = min + (max-min) * percent
			end
		end

		if newValue ~= self.props.value then
			if self.props.valueChanged then
				self.props.valueChanged(newValue)
			end
		end
	end

	self.valueToEditText = function(value)
		return tostring(round(value, 1 * 10^(-self.props.editRound)))
	end

	self.valueToDisplayText = function(value)
		return tostring(round(value, 1 * 10^(-self.props.displayRound)))
	end

	self.onTextBoxFocused = function(text)
		if not self.state.open then
			self:setOpen(true)
			local editText = self.valueToEditText(self.props.value)
			return editText
		end
	end
	self.onTextBoxFocusLost = function(text)
		local newValue = tonumber(text)
		if newValue == nil then
			return self.valueToDisplayText(self.props.value)
		end

		newValue = math.clamp(newValue, self.props.min, self.props.max)
		if newValue == self.props.value then
			return self.valueToDisplayText(self.props.value)
		end

		if self.props.valueChanged then
			self.props.valueChanged(newValue)
			return self.valueToDisplayText(newValue)
		end
	end

	local modalBinding = Roact.joinBindings({
		absoluteSize = self.absoluteSize,
		absolutePosition = self.absolutePosition,
		targetAbsoluteSize = self.props.modalTarget.absoluteSizeBinding,
		targetAbsolutePosition = self.props.modalTarget.absolutePositionBinding,
	})

	-- Left blocker
	self.leftBlockerPosition = modalBinding:map(function(mapped)
		local x = 0
		local y = 0
		return UDim2.new(0, x, 0, y)
	end)
	self.leftBlockerSize = modalBinding:map(function(mapped)
		local x = mapped.absolutePosition.X - mapped.targetAbsolutePosition.X
		local y = mapped.targetAbsoluteSize.Y
		return UDim2.new(0, x, 0, y)
	end)

	-- Top blocker
	self.topBlockerPosition = modalBinding:map(function(mapped)
		local x = mapped.absolutePosition.X - mapped.targetAbsolutePosition.X
		local y = 0
		return UDim2.new(0, x, 0, y)
	end)
	self.topBlockerSize = modalBinding:map(function(mapped)
		local x = mapped.absoluteSize.X
		local y = mapped.absolutePosition.Y - mapped.targetAbsolutePosition.Y
		return UDim2.new(0, x, 0, y)
	end)

	-- Right blocker
	self.rightBlockerPosition = modalBinding:map(function(mapped)
		local x = mapped.absolutePosition.X + mapped.absoluteSize.X - mapped.targetAbsolutePosition.X
		local y = 0
		return UDim2.new(0, x, 0, y)
	end)
	self.rightBlockerSize = modalBinding:map(function(mapped)
		local x = mapped.targetAbsoluteSize.X - (mapped.absolutePosition.X - mapped.targetAbsolutePosition.X)
			- mapped.absoluteSize.X
		local y = mapped.targetAbsoluteSize.Y
		return UDim2.new(0, x, 0, y)
	end)

	-- Bottom blocker
	self.bottomBlockerPosition = modalBinding:map(function(mapped)
		local x = mapped.absolutePosition.X - mapped.targetAbsolutePosition.X
		local y = mapped.absolutePosition.Y - mapped.targetAbsolutePosition.Y + mapped.absoluteSize.Y
		return UDim2.new(0, x, 0, y)
	end)
	self.bottomBlockerSize = modalBinding:map(function(mapped)
		local x = mapped.absoluteSize.X
		local y = mapped.targetAbsoluteSize.Y - (mapped.absolutePosition.Y - mapped.targetAbsolutePosition.Y)
			- mapped.absoluteSize.Y
		return UDim2.new(0, x, 0, y)
	end)

	-- Dragger frame
	self.draggerFramePosition = modalBinding:map(function(mapped)
		local x = mapped.absolutePosition.X - mapped.targetAbsolutePosition.X
		local y = mapped.absolutePosition.Y - mapped.targetAbsolutePosition.Y + mapped.absoluteSize.Y + 6
		return UDim2.new(0, x, 0, y)
	end)
	self.draggerFrameSize = modalBinding:map(function(mapped)
		local x = mapped.absoluteSize.X
		local y = 12
		return UDim2.new(0, x, 0, y)
	end)

	-- Faux button
	self.fauxButtonBackgroundColor = self.draggerButtonState:map(function(buttonState)
		local colors = self.props.theme.colors

		if buttonState == "PressedIn" or buttonState == "PressedOut" then
			return colors.Button.PressedIn
		else
			return colors.Button[buttonState]
		end
	end)
	self.fauxButtonBorderColor = self.draggerButtonState:map(function(buttonState)
		local colors = self.props.theme.colors

		if buttonState == "PressedIn" or buttonState == "PressedOut" then
			return colors.ButtonBorder.PressedIn
		else
			return colors.ButtonBorder[buttonState]
		end
	end)
end

function RangeSlider:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local anchorPoint = props.anchorPoint
	local zIndex = props.zIndex
	local disabled = props.disabled
	local modalTarget = props.modalTarget
	local theme = props.theme

	local fillPercent = (self.props.value-self.props.min) / (self.props.max-self.props.min)
	local colors = theme.colors

	return Roact.createFragment({
		TextBoxContainer = e("Frame", {
			Size = size,
			Position = position,
			LayoutOrder = layoutOrder,
			AnchorPoint = anchorPoint,
			ZIndex = zIndex,
			BackgroundTransparency = 1,
			[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
			[Roact.Change.AbsolutePosition] = self.onAbsolutePositionChanged,
		}, {
			TextBox = e(TextBox, {
				size = UDim2.new(1, 0, 1, 0),
				disabled = disabled,
				inputText = self.valueToDisplayText(self.props.value),
				focused = self.onTextBoxFocused,
				focusLost = self.onTextBoxFocusLost,
			}),

			Floating = self.state.open and e(Roact.Portal, {
				target = modalTarget.target,
			}, {
				Left = e("TextButton", {
					Text = "",
					Position = self.leftBlockerPosition,
					Size = self.leftBlockerSize,
					BackgroundTransparency = 1,
					[Roact.Event.MouseButton1Down] = self.onBackgroundCloseDetectorClicked,
				}),

				Top = e("TextButton", {
					Text = "",
					Position = self.topBlockerPosition,
					Size = self.topBlockerSize,
					BackgroundTransparency = 1,
					[Roact.Event.MouseButton1Down] = self.onBackgroundCloseDetectorClicked,
				}),

				Right = e("TextButton", {
					Text = "",
					Position = self.rightBlockerPosition,
					Size = self.rightBlockerSize,
					BackgroundTransparency = 1,
					[Roact.Event.MouseButton1Down] = self.onBackgroundCloseDetectorClicked,
				}),

				Bottom = e("TextButton", {
					Text = "",
					Position = self.bottomBlockerPosition,
					Size = self.bottomBlockerSize,
					BackgroundTransparency = 1,
					[Roact.Event.MouseButton1Down] = self.onBackgroundCloseDetectorClicked,
				}),

				DraggerFrame = e("Frame", {
					Position = self.draggerFramePosition,
					Size = self.draggerFrameSize,
					ZIndex = 2,
					BackgroundTransparency = 1,
				}, {
					Shadow = e(ShadowedFrame, {
						size = UDim2.new(1, 0, 1, 0),
					}),

					DragDetector = e(ButtonDetector, {
						size = UDim2.new(1, 0, 1, 0),
						activatedChanged = self.onActivatedChanged,
						buttonStateChanged = self.updateDraggerButtonState,
					}),

					BarBackground = e("Frame", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = colors.SliderBarBackground.Default,
						BorderSizePixel = 0,
					}),

					BarFill = e("Frame", {
						Size = UDim2.new(fillPercent, 0, 1, 0),
						BackgroundColor3 = colors.SliderBarFill.Default,
						BorderSizePixel = 0,
						ZIndex = 2,
					}),

					FauxButton = e(BorderedFrame, {
						size = UDim2.new(0, 6, 1, 6),
						position = UDim2.new(fillPercent, 0, 0.5, 0),
						anchorPoint = Vector2.new(0.5, 0.5),
						backgroundColorBinding = self.fauxButtonBackgroundColor,
						borderColorBinding = self.fauxButtonBorderColor,
						zIndex = 3,
					}),
				}),
			}),
		})
	})
end

function RangeSlider:willUnmount()
	self.hConn:Disconnect()
end

function RangeSlider:setOpen(open)
	self:setState({
		open = open,
	})
	self.updateOpen(open)
	if self.props.openChanged then
		self.props.openChanged(open)
	end
end

function RangeSlider:calculateDragPercent()
	local minX = self.absolutePosition:getValue().X
	local maxX = self.absolutePosition:getValue().X + self.absoluteSize:getValue().X
	local percent = (self.props.modalTarget.mousePositionBinding:getValue().X-minX) / (maxX-minX)
	return percent
end

return ThemeContext.connect(ModalTargetContext.connect(RangeSlider, function(modalTarget)
	return {modalTarget = modalTarget}
end), function(theme)
	return {theme = theme}
end)

