local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")

local e = Roact.createElement

local Button = Roact.Component:extend("Button")

Button.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(),
	layoutOrder = 0,
	buttonStateChange = nil,
	mouse1Click = nil,
	mouse1Press = nil,
}

local IButton = t.interface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	buttonStateChange = t.optional(t.callback),
	mouse1Click = t.optional(t.callback),
	mouse1Press = t.optional(t.callback),
})

Button.validateProps = function(props)
    return IButton(props)
end

function Button:init()
	self.activated = false
	self.mouseInside = false
end

function Button:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local mouse1Click = props.mouse1Click
	local mouse1Press = props.mouse1Press

	-- TODO: make me modal
	return e("TextButton", {
		Size = size,
		Position = position,
		Text = "",
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		[Roact.Event.InputChanged] = function(rbx, inputObject)
			local mousePos = inputObject.Position
			local topLeft = rbx.AbsolutePosition
			local bottomRight = rbx.AbsolutePosition + rbx.AbsoluteSize - Vector2.new(1, 1)
			if mousePos.X >= topLeft.X and mousePos.Y >= topLeft.Y
				and mousePos.X <= bottomRight.X and mousePos.Y <= bottomRight.Y then

				self.mouseInside = true
				self:refreshButtonState()
			else
				self.mouseInside = false
				self:refreshButtonState()
			end
		end,
		[Roact.Event.MouseLeave] = function()
			self.mouseInside = false
			self:refreshButtonState()
		end,
		[Roact.Event.InputBegan] = function(rbx, inputObject)
			if not self.mouseInside then return end

			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				self.activated = true
				self:refreshButtonState()
				if self.mouseInside and mouse1Press then
					mouse1Press()
				end
			end
		end,
		[Roact.Event.InputEnded] = function(rbx, inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				self.activated = false
				self:refreshButtonState()
				if self.mouseInside and mouse1Click then
					mouse1Click()
				end
			end
		end
	}, props[Roact.Children])
end

function Button:refreshButtonState()
	local newState
	if self.activated and self.mouseInside then
		newState = "Pressed"
	elseif self.activated or self.mouseInside then
		newState = "Hovered"
	else
		newState = "Default"
	end

	if self.buttonState ~= newState then
		self.buttonState = newState
		if self.props.buttonStateChange then
			self.props.buttonStateChange(newState)
		end
	end
end

return Button
