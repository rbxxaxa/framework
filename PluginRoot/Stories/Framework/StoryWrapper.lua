local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Theme = load("Framework/Theme")
local ThemeContext = load("Framework/ThemeContext")
local ModalTargetContext = load("Framework/ModalTargetContext")

return function(props, children)
	local theme = props.theme or Theme.new()
	local modalTarget = props.modalTarget

	return ThemeContext.withController({
		theme = theme,
	}, {
		ModalTargetContext.withController({
			modalTarget = modalTarget,
		}, children)
	})
end
