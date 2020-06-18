local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local RunService = game:GetService("RunService")

local TextService = game:GetService("TextService")

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")

local e = Roact.createElement

local TextBox = Roact.PureComponent:extend("TextBox")

TextBox.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	inputText = "",
	placeholderText = "",
	disabled = false,
	focusLost = nil,
}

local ITextBox = t.interface({
	size = t.optional(t.UDim2),
	position = t.optional(t.UDim2),
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	inputText = t.string,
	placeholderText = t.string,
	disabled = t.boolean,
	focusLost = t.optional(t.callback),
})

TextBox.validateProps = function(props)
	return ITextBox(props)
end

function TextBox:init()
	self.textBoxRef = Roact.createRef()
	self.clipperRef = Roact.createRef()

	self.focused, self.updateFocused = Roact.createBinding(false)
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")
	self.frameColor = Roact.joinBindings({
		buttonState = self.buttonState,
		focused = self.focused,
	})
	self.text, self.updateText = Roact.createBinding(self.props.inputText)
	self.textBoxPosition, self.updateTextBoxPosition = Roact.createBinding(UDim2.new())
	self.backgroundColor = self.frameColor:map(function(mapped)
		local colors = self.props.theme.colors

		if mapped.focused then
			return colors.InputFieldBackground.Focused
		else
			if self.props.disabled then
				return colors.InputFieldBorder.Disabled
			elseif mapped.buttonState == "Hovered" then
				return colors.InputFieldBackground.Hovered
			else
				return colors.InputFieldBackground.Default
			end
		end
	end)
	self.borderColor = self.frameColor:map(function(mapped)
		local colors = self.props.theme.colors

		if mapped.focused then
			return colors.InputFieldBorder.Focused
		else
			if self.props.disabled then
				return colors.InputFieldBorder.Disabled
			elseif mapped.buttonState == "Hovered" then
				return colors.InputFieldBorder.Hovered
			else
				return colors.InputFieldBorder.Default
			end
		end
	end)
	self.font = self.text:map(function(text)
		return text == "" and Constants.FONT_ITALIC or Constants.FONT_DEFAULT
	end)
	self.onCursorPositionChanged = function(rbx)
		--[[
			This is delayed by a frame because clipping depends on a bunch of properties
			and these properties might be updated after CursorPosition is updated.
		]]
		RunService.RenderStepped:Wait()
		self:updateClipping()
	end
	self.onFocusLost = function(rbx, enterPressed, inputThatCausedLostFocus)
		local text = rbx.Text
		if self.props.focusLost then
			self.props.focusLost(text, enterPressed)
		end
		self.updateFocused(false)
	end
	self.onFocused = function(rbx)
		self.updateFocused(true)
	end
	self.onTextChanged = function(rbx)
		self.updateText(rbx.Text)
	end
end

function TextBox:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local anchorPoint = props.anchorPoint
	local zIndex = props.zIndex
	local inputText = props.inputText
	local disabled = props.disabled
	local placeholderText = props.placeholderText
	local theme = self.props.theme

	local colors = theme.colors

	--[[
		If the text box is disabled, then updateText will never get called.
		We do that here, otherwise the font of the text will never change.
	]]
	self.updateText(inputText)

	-- TODO: make me modal
	return e(Button, {
		size = size,
		position = position,
		layoutOrder = layoutOrder,
		anchorPoint = anchorPoint,
		zIndex = zIndex,
		buttonStateChanged = self.updateButtonState,
		disabled = disabled,
	}, {
		Background = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 1,
			BackgroundColor3 = self.backgroundColor,
			BorderColor3 = self.borderColor,
			BorderMode = Enum.BorderMode.Inset,
		}),
		-- We fudge some offsets/paddings by -1 so that the cursor will always get rendered in the box.
		Clipper = e("Frame", {
			Size = UDim2.new(1, -15, 1, 0),
			Position = UDim2.new(0, 7, 0, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			[Roact.Ref] = self.clipperRef,
			ZIndex = 2,
		}, {
			Padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 1),
			}),

			TextLabel = disabled and e("TextLabel", {
				Text = inputText == "" and placeholderText or inputText,
				BackgroundTransparency = 1,
				TextWrapped = false,
				Size = UDim2.new(0, 9999, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.new(0, 0, 0, 0),
				TextColor3 = colors.MainText.Disabled,
				Font = self.font,
				TextSize = Constants.TEXT_SIZE_DEFAULT,
			}),

			TextBox = not disabled and e("TextBox", {
				Text = inputText,
				BackgroundTransparency = 1,
				TextWrapped = false,
				ClearTextOnFocus = false,
				PlaceholderText = placeholderText,
				Size = UDim2.new(0, 9999, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = self.textBoxPosition,
				TextColor3 = colors.MainText.Default,
				PlaceholderColor3 = colors.DimmedText.Default,
				Font = self.font,
				TextSize = Constants.TEXT_SIZE_DEFAULT,
				[Roact.Change.CursorPosition] = self.onCursorPositionChanged,
				[Roact.Ref] = self.textBoxRef,
				[Roact.Event.FocusLost] = self.onFocusLost,
				[Roact.Event.Focused] = self.onFocused,
				[Roact.Change.Text] = self.onTextChanged,
			}),
		}),
	})
end

function TextBox:updateClipping()
	local clipper = self.clipperRef:getValue()
	local textBox = self.textBoxRef:getValue()

	if textBox.CursorPosition < 0 then
		return UDim2.new(0, 0, 0, 0)
	end

	local textUpToCursor = string.sub(textBox.Text, 1, textBox.CursorPosition-1)
	local textSize = TextService:GetTextSize(textUpToCursor, Constants.TEXT_SIZE_DEFAULT,
		Constants.FONT_DEFAULT, Vector2.new(9999, 9999))
	local clipperLeft = clipper.AbsolutePosition.X
	local clipperRight = clipper.AbsolutePosition.X + clipper.AbsoluteSize.X
	local cursorX = textBox.AbsolutePosition.X + textSize.X

	local newPosition
	if cursorX >= clipperLeft and cursorX <= clipperRight - 2 then
		newPosition = self.textBoxPosition:getValue()
	elseif cursorX < clipperLeft then
		newPosition = UDim2.new(0, -textSize.X, 0, 0)
	else
		newPosition = UDim2.new(0, clipper.AbsoluteSize.X - textSize.X - 2, 0, 0)
	end

	self.updateTextBoxPosition(newPosition)
end

return ThemeContext.connect(TextBox, function(theme)
	return {theme = theme}
end)
