local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local ThemeContext = load("Framework/ThemeContext")
local ModalTargetContext = load("Framework/ModalTargetContext")

local FrameworkWrapper = Roact.Component:extend("FrameworkWrapper")

function FrameworkWrapper:render()
	local props = self.props
	local theme = props.theme
	local modalTarget = props.modalTarget

	return ThemeContext.withController({
		theme = theme,
	}, {
		ModalTargetContext.withController({
			modalTarget = modalTarget,
		}, self.props[Roact.Children])
	})
end

return FrameworkWrapper
