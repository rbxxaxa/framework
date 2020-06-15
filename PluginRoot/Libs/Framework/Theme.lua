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
			Default = c(56, 56, 56),
		},
		ScrollBarBackground = {
			Default = c(41, 41, 41),
		},
		ScrollingFrameContentBackground = {
			Default = c(46, 46, 46),
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
			Hovered = c(66, 66, 66),
			Focused = c(37, 37, 37),
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
