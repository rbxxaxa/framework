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
	self.clipperPosition, self.updateClipperPosition = Roact.createBinding(Vector2.new())
	self.textBoxPosition, self.updateTextBoxPosition = Roact.createBinding(Vector2.new())
	self.textInTextBox, self.updateTextInTextBox = Roact.createBinding(self.props.inputText)
	self.clipperBindings = Roact.joinBindings({
		cursorPosition = self.cursorPosition,
		clipperSize = self.clipperSize,
		clipperPosition = self.clipperPosition,
		textBoxPosition = self.textBoxPosition,
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
			Clipper = e("Frame", {
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				[Roact.Change.AbsoluteSize] = function(rbx)
					self.updateClipperSize(rbx.AbsoluteSize)
				end,
				[Roact.Change.AbsolutePosition] = function(rbx)
					self.updateClipperPosition(rbx.AbsolutePosition)
				end,
				ZIndex = 2,
			}, {
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
					Position = self.clipperBindings:map(function(mapped)
						if mapped.cursorPosition < 0 then
							return UDim2.new(0, 0, 0, 0)
						end

						local textUpToCursor = string.sub(mapped.textInTextBox, 1, mapped.cursorPosition-1)
						local textSize = TextService:GetTextSize(textUpToCursor, Constants.FONT_SIZE_DEFAULT,
							Constants.FONT_DEFAULT, Vector2.new(9999, 9999))
						local clipperLeft = mapped.clipperPosition.X
						local clipperRight = mapped.clipperPosition.X + mapped.clipperSize.X
						local cursorX = mapped.textBoxPosition.X + textSize.X

						-- We fudge the right by -1 so that the cursor still gets rendered in the box.
						if cursorX >= clipperLeft and cursorX <= clipperRight - 1 then
							return UDim2.new(0, mapped.textBoxPosition.X-mapped.clipperPosition.X, 0, 0)
						elseif cursorX < clipperLeft then
							return UDim2.new(0, -textSize.X, 0, 0)
						else
							return UDim2.new(0, mapped.clipperSize.X - textSize.X - 1, 0, 0)
						end
					end),
					TextColor3 = colors.MainText.Default,
					PlaceholderColor3 = colors.DimmedText.Default,
					Font = Constants.FONT_DEFAULT,
					TextSize = Constants.FONT_SIZE_DEFAULT,
					[Roact.Change.CursorPosition] = function(rbx)
						self.updateCursorPosition(rbx.CursorPosition)
					end,
					[Roact.Change.AbsolutePosition] = function(rbx)
						self.updateTextBoxPosition(rbx.AbsolutePosition)
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

