local Theme = {}
Theme.__index = Theme

local c = Color3.fromRGB

-- TODO: Refresh when studio theme changes
-- TODO: Light theme
function Theme.new()
	local self = {}

	self.colors = {
		Button = {
			Default = c(60, 60, 60),
			Hovered = c(70, 70, 70),
			PressedIn = c(50, 50, 50),
			PressedOut = c(70, 70, 70),
		},
		ButtonText = {
			Default = c(204, 204, 204),
			Hovered = c(204, 204, 204),
			PressedIn = c(204, 204, 204),
			PressedOut = c(204, 204, 204),
		},
		MainText = {
			Default = c(204, 204, 204),
			Hovered = c(255, 255, 255),
			PressedIn = c(204, 204, 204),
			PressedOut = c(255, 255, 255),
		},
		ScrollBar = {
			Default = c(80, 80, 80),
		},
		ScrollBarBackground = {
			Default = c(60, 60, 60),
		},
		ScrollingFrameContentBackground = {
			Default = c(40, 40, 40),
		},
		TitledSectionTitleBackground = {
			Default = c(20, 20, 20),
		},
		TitledSectionContentBackground = {
			Default = c(30, 30, 30),
		},
		DropdownChoiceBackground = {
			Default = c(40, 40, 40),
			Hovered = c(50, 50, 50),
		},
		DropdownChoiceText = {
			Default = c(204, 204, 204),
			Hovered = c(204, 204, 204),
		},
		InputFieldBackground = {
			Default = c(50, 50, 50),
			Hovered = c(60, 60, 60),
			Focused = c(50, 50, 50),
		},
		DropdownArrow = {
			Default = c(204, 204, 204),
		},
	}

	return setmetatable(self, Theme)
end

function Theme:getColors()
	return self.colors
end

function Theme:subscribe()
	return function() end
end

return Theme
