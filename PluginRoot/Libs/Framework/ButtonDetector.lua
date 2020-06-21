local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")

local e = Roact.createElement

local ButtonDetector = Roact.Component:extend("ButtonDetector")

ButtonDetector.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	buttonStateChanged = nil,
	mouseInsideChanged = nil,
	activatedChanged = nil,
	mouse1Clicked = nil,
	mouse1Pressed = nil,
	disabled = false,

	[Roact.Children] = nil,
}

local IButtonDetector = t.strictInterface({
	size = t.optional(t.UDim2),
	position = t.optional(t.UDim2),
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	buttonStateChanged = t.optional(t.callback),
	mouseInsideChanged = t.optional(t.callback),
	activatedChanged = t.optional(t.callback),
	mouse1Clicked = t.optional(t.callback),
	mouse1Pressed = t.optional(t.callback),
	disabled = t.boolean,

	[Roact.Children] = t.optional(t.table),
})

ButtonDetector.validateProps = function(props)
	return IButtonDetector(props)
end

local function isMouseInside(frame, mousePos)
	local topLeft = frame.AbsolutePosition
	local bottomRight = frame.AbsolutePosition + frame.AbsoluteSize - Vector2.new(1, 1)
	local x, y = mousePos.X, mousePos.Y
	return x >= topLeft.X and y >= topLeft.Y and x <= bottomRight.X and y <= bottomRight.Y
end

function ButtonDetector:init()
	self.activated = false
	self.mouseInside = false

	self.lastMousePos = Vector2.new(0, 0)

	self.onInputChanged = function(rbx, inputObject)
		self:updateMouseInside(rbx, inputObject.Position)
	end
	self.onMouseEnter = function(rbx, x, y)
		local mousePos = Vector2.new(x, y)
		self:updateMouseInside(rbx, mousePos)
	end
	self.onMouseMoved = function(rbx, x, y)
		local mousePos = Vector2.new(x, y)
		self:updateMouseInside(rbx, mousePos)
	end
	self.onMouseLeave = function(rbx, x, y)
		local mousePos = Vector2.new(x, y)
		self:updateMouseInside(rbx, mousePos)
	end
	self.onInputBegan = function(rbx, inputObject)
		if self.props.disabled then return end
		if not self.mouseInside then return end

		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setActivated(true)
			if self.mouseInside and self.props.mouse1Pressed then
				self.props.mouse1Pressed()
			end
		end
	end
	self.onInputEnded =function(rbx, inputObject)
		self:updateMouseInside(rbx, inputObject.Position)

		if self.props.disabled then return end

		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:setActivated(false)
			if self.mouseInside and self.props.mouse1Clicked then
				self.props.mouse1Clicked()
			end
		end
	end
end

function ButtonDetector:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local anchorPoint = props.anchorPoint
	local zIndex = props.zIndex

	-- TODO: make me modal
	return e("TextButton", {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		Text = "",
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		[Roact.Event.InputChanged] = self.onInputChanged,
		[Roact.Event.MouseEnter] = self.onMouseEnter,
		[Roact.Event.MouseMoved] = self.onMouseMoved,
		[Roact.Event.MouseLeave] = self.onMouseLeave,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
	}, props[Roact.Children])
end

function ButtonDetector:updateMouseInside(frame, mousePos)
	local mouseInside = isMouseInside(frame, mousePos)
	self:setMouseInside(mouseInside)
end

function ButtonDetector:setActivated(activated)
	if self.activated ~= activated then
		self.activated = activated
		if self.props.activatedChanged then
			self.props.activatedChanged(activated)
		end
		self:refreshButtonState()
	end
end

function ButtonDetector:setMouseInside(mouseInside)
	if self.mouseInside ~= mouseInside then
		self.mouseInside = mouseInside
		if self.props.mouseInsideChanged then
			self.props.mouseInsideChanged(mouseInside)
		end
		self:refreshButtonState()
	end
end

function ButtonDetector:didUpdate(prevProps, prevState)
	if prevProps.disabled ~= self.props.disabled then
		self:setActivated(false)
	end
end

function ButtonDetector:refreshButtonState()
	local newState
	if self.activated and self.mouseInside then
		newState = "PressedIn"
	elseif self.activated and not self.mouseInside then
		newState = "PressedOut"
	elseif not self.activated and self.mouseInside then
		newState = "Hovered"
	else
		newState = "Default"
	end

	if self.buttonState ~= newState then
		self.buttonState = newState
		if self.props.buttonStateChanged then
			self.props.buttonStateChanged(newState)
		end
	end
end

return ButtonDetector
