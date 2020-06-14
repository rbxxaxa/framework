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
	buttonStateChanged = nil,
	mouse1Clicked = nil,
	mouse1Pressed = nil,
}

local IButton = t.interface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	buttonStateChanged = t.optional(t.callback),
	mouse1Clicked = t.optional(t.callback),
	mouse1Pressed = t.optional(t.callback),
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
	local mouse1Clicked = props.mouse1Clicked
	local mouse1Pressed = props.mouse1Pressed

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
				if self.mouseInside and mouse1Pressed then
					mouse1Pressed()
				end
			end
		end,
		[Roact.Event.InputEnded] = function(rbx, inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				self.activated = false
				self:refreshButtonState()
				if self.mouseInside and mouse1Clicked then
					mouse1Clicked()
				end
			end
		end
	}, props[Roact.Children])
end

function Button:refreshButtonState()
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

return Button
