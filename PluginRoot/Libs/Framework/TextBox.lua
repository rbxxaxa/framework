local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local TextService = game:GetService("TextService")

local Roact = load("Roact")
local t = load("t")
local Button = load("Framework/Button")
local ThemeContext = load("Framework/ThemeContext")
local Constants = load("Framework/Constants")

local e = Roact.createElement

local TextBox = Roact.Component:extend("TextBox")

TextBox.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(),
	layoutOrder = 0,
	inputText = "",
	placeholderText = "",
	focusLost = nil,
}

local ITextBox = t.interface({
	size = t.optional(t.UDim2),
	position = t.optional(t.UDim2),
	layoutOrder = t.integer,
	inputText = t.string,
	placeholderText = t.string,
	focusLost = t.optional(t.callback),
})

TextBox.validateProps = function(props)
	return ITextBox(props)
end

function TextBox:init()
	self.buttonState, self.updateButtonState = Roact.createBinding("Default")

	self.cursorPosition, self.updateCursorPosition = Roact.createBinding(-1)
	self.clipperSize, self.updateClipperSize = Roact.createBinding(Vector2.new())
	self.clipperAbsolutePosition, self.updateClipperAbsolutePosition = Roact.createBinding(Vector2.new())
	self.textBoxAbsolutePosition, self.updateTextBoxAbsolutePosition = Roact.createBinding(Vector2.new())
	self.textInTextBox, self.updateTextInTextBox = Roact.createBinding(self.props.inputText)
	self.clipperBindings = Roact.joinBindings({
		cursorPosition = self.cursorPosition,
		clipperSize = self.clipperSize,
		clipperAbsolutePosition = self.clipperAbsolutePosition,
		textBoxAbsolutePosition = self.textBoxAbsolutePosition,
		textInTextBox = self.textInTextBox,
	})
	self.textBoxRef = Roact.createRef()
	self.focused, self.updateFocused = Roact.createBinding(false)
	self.frameColorBindings = Roact.joinBindings({
		buttonState = self.buttonState,
		focused = self.focused,
	})
end

function TextBox:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local layoutOrder = props.layoutOrder
	local inputText = props.inputText
	local focusLost = props.focusLost
	local placeholderText = props.placeholderText

	return ThemeContext.withConsumer(function(theme)
		local colors = theme.colors

		-- TODO: make me modal
		return e(Button, {
			size = size,
			position = position,
			layoutOrder = layoutOrder,
			buttonStateChanged = self.updateButtonState,
			mouse1Pressed = function()
				self.textBoxRef:getValue():CaptureFocus()
			end,
		}, {
			Background = e("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BorderSizePixel = 1,
				BackgroundColor3 = self.frameColorBindings:map(function(mapped)
					if mapped.focused then
						return colors.InputFieldBackground.Focused
					else
						if mapped.buttonState == "Hovered" then
							return colors.InputFieldBackground.Hovered
						else
							return colors.InputFieldBackground.Default
						end
					end
				end),
				BorderColor3 = self.frameColorBindings:map(function(mapped)
					if mapped.focused then
						return colors.InputFieldBorder.Focused
					else
						if mapped.buttonState == "Hovered" then
							return colors.InputFieldBorder.Hovered
						else
							return colors.InputFieldBorder.Default
						end
					end
				end),
				BorderMode = Enum.BorderMode.Inset,
			}),
			-- We fudge some offsets/paddings by -1 so that the cursor will always get rendered in the box.
			Clipper = e("Frame", {
				Size = UDim2.new(1, -15, 1, 0),
				Position = UDim2.new(0, 7, 0, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				[Roact.Change.AbsoluteSize] = function(rbx)
					self.updateClipperSize(rbx.AbsoluteSize)
				end,
				[Roact.Change.AbsolutePosition] = function(rbx)
					self.updateClipperAbsolutePosition(rbx.AbsolutePosition)
				end,
				ZIndex = 2,
			}, {
				Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 1),
				}),
				Textbox = e("TextBox", {
					Text = inputText,
					BackgroundTransparency = 1,
					TextWrapped = false,
					ClearTextOnFocus = false,
					PlaceholderText = placeholderText,
					--[[
						Somehow, when the text behind the cursor is 2X that of the box's absolute size, Roblox
						stops rendering it... As a fix, we just make the textbox's size some huge number.
					]]
					Size = UDim2.new(0, 9999, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					-- TODO: Improve this. This behaves poorly when the text box is resized.
					Position = self.clipperBindings:map(function(mapped)
						if mapped.cursorPosition < 0 then
							return UDim2.new(0, 0, 0, 0)
						end

						local textUpToCursor = string.sub(mapped.textInTextBox, 1, mapped.cursorPosition-1)
						local textSize = TextService:GetTextSize(textUpToCursor, Constants.TEXT_SIZE_DEFAULT,
							Constants.FONT_DEFAULT, Vector2.new(9999, 9999))
						local clipperLeft = mapped.clipperAbsolutePosition.X
						local clipperRight = mapped.clipperAbsolutePosition.X + mapped.clipperSize.X
						local cursorX = mapped.textBoxAbsolutePosition.X + textSize.X

						local newPosition
						if cursorX >= clipperLeft and cursorX <= clipperRight - 1 then
							newPosition = UDim2.new(0, mapped.textBoxAbsolutePosition.X-mapped.clipperAbsolutePosition.X - 1, 0, 0)
						elseif cursorX < clipperLeft then
							newPosition = UDim2.new(0, -textSize.X, 0, 0)
						else
							newPosition = UDim2.new(0, mapped.clipperSize.X - textSize.X - 1, 0, 0)
						end

						return newPosition
					end),
					TextColor3 = colors.MainText.Default,
					PlaceholderColor3 = colors.DimmedText.Default,
					Font = Constants.FONT_DEFAULT,
					TextSize = Constants.TEXT_SIZE_DEFAULT,
					[Roact.Change.CursorPosition] = function(rbx)
						self.updateCursorPosition(rbx.CursorPosition)
					end,
					[Roact.Change.AbsolutePosition] = function(rbx)
						self.updateTextBoxAbsolutePosition(rbx.AbsolutePosition)
					end,
					[Roact.Change.Text] = function(rbx)
						self.updateTextInTextBox(rbx.Text)
					end,
					[Roact.Ref] = self.textBoxRef,
					[Roact.Event.FocusLost] = function(rbx, enterPressed, inputThatCausedLostFocus)
						local text = rbx.Text
						if focusLost then
							focusLost(text, enterPressed)
						end
						self.updateFocused(false)
					end,
					[Roact.Event.Focused] = function(rbx)
						self.updateFocused(true)
					end,
				}),
			}),
		})
	end)
end

return TextBox

