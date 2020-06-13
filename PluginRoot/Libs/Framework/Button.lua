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
	onClick = nil,
}

local IButton = t.interface({
	size = t.UDim2,
	position = t.UDim2,
	layoutOrder = t.integer,
	onClick = t.optional(t.callback),
})

Button.validateProps = function(props)
    return IButton(props)
end

function Button:init()
	self.activated = false
	self.mouseInside = false
	self.buttonState, self.updateButtonState = Roact.createBinding("default")
end

function Button:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local onClick = props.onClick

	-- TODO: theme me
	local theme = {
		default = Color3.new(1, 0, 0),
		hovered = Color3.new(0, 1, 0),
		pressed = Color3.new(0, 0, 1),
	}

	-- TODO: make me modal
	return e("TextButton", {
		Size = size,
		Position = position,
		Text = "",
		BorderSizePixel = 0,
		BackgroundColor3 = self.buttonState:map(function(buttonState)
			return theme[buttonState]
		end),
		AutoButtonColor = false,
		[Roact.Event.InputChanged] = function(rbx, inputObject)
			local mousePos = inputObject.Position
			local topLeft = rbx.AbsolutePosition
			local bottomRight = rbx.AbsolutePosition + rbx.AbsoluteSize
			if mousePos.X >= topLeft.X and mousePos.Y >= topLeft.Y
				and mousePos.X <= bottomRight.X-1 and mousePos.Y <= bottomRight.Y-1 then

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
			end
		end,
		[Roact.Event.InputEnded] = function(rbx, inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				self.activated = false
				self:refreshButtonState()
				if self.mouseInside and onClick then
					onClick()
				end
			end
		end
	}, props[Roact.Children])
end

function Button:refreshButtonState()
	if self.activated and self.mouseInside then
		self.updateButtonState("pressed")
	elseif self.activated or self.mouseInside then
		self.updateButtonState("hovered")
	else
		self.updateButtonState("default")
	end
end

return Button
