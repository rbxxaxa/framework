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
			Hovered = c(66, 66, 66),
			PressedIn = c(41, 41, 41),
			PressedOut = c(66, 66, 66),
			Disabled = c(60, 60, 60),
		},
		ButtonText = {
			Default = c(204, 204, 204),
			Hovered = c(204, 204, 204),
			PressedIn = c(204, 204, 204),
			PressedOut = c(204, 204, 204),
			Disabled = c(85, 85, 85),
		},
		ButtonBorder = {
			Default = c(53, 53, 53),
			Hovered = c(53, 53, 53),
			PressedIn = c(53, 53, 53),
			PressedOut = c(53, 53, 53),
			Disabled = c(53, 53, 53),
		},
		MainText = {
			Default = c(204, 204, 204),
			Hovered = c(255, 255, 255),
			PressedIn = c(204, 204, 204),
			PressedOut = c(255, 255, 255),
			Disabled = c(85, 85, 85),
		},
		DimmedText = {
			Default = c(102, 102, 102),
			Hovered = c(170, 170, 170),
			PressedIn = c(102, 102, 102),
			PressedOut = c(170, 170, 170),
		},
		ScrollBar = {
			Default = c(60, 60, 60),
		},
		ScrollBarBackground = {
			Default = c(41, 41, 41),
		},
		ScrollingFrameContentBackground = {
			Default = c(37, 37, 37),
		},
		TitledSectionTitleBackground = {
			Default = c(53, 53, 53),
		},
		TitledSectionContentBackground = {
			Default = c(46, 46, 46),
		},
		DropdownChoiceBackground = {
			Default = c(46, 46, 46),
			Hovered = c(66, 66, 66),
		},
		DropdownChoiceText = {
			Default = c(204, 204, 204),
			Hovered = c(204, 204, 204),
		},
		InputFieldBackground = {
			Default = c(37, 37, 37),
			Hovered = c(37, 37, 37),
			Focused = c(37, 37, 37),
			Disabled = c(53, 53, 53),
		},
		InputFieldBorder = {
			Default = c(26, 26, 26),
			Hovered = c(58, 58, 58),
			Focused = c(53, 181, 255),
			Disabled = c(66, 66, 66),
		},
		DropdownArrow = {
			Default = c(204, 204, 204),
			Hovered = c(204, 204, 204),
			Focused = c(204, 204, 204),
			Disabled = c(85, 85, 85),
		},
		DropdownButtonBackground = {
			Default = c(60, 60, 60),
			Hovered = c(66, 66, 66),
			Focused = c(37, 37, 37),
			Disabled = c(60, 60, 60),
		},
		DropdownButtonText = {
			Default = c(204, 204, 204),
			Hovered = c(204, 204, 204),
			Focused = c(204, 204, 204),
			Disabled = c(85, 85, 85),
		},
		DropdownButtonBorder = {
			Default = c(53, 53, 53),
			Hovered = c(53, 53, 53),
			Focused = c(53, 53, 53),
			Disabled = c(53, 53, 53),
		},
		SliderBarBackground = {
			Default = c(255, 255, 255),
		},
		SliderBarFill = {
			Default = c(51, 181, 255),
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
