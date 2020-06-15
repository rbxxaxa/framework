local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local Theme = load("Framework/Theme")
local FrameworkWrapper = load("Framework/FrameworkWrapper")

local e = Roact.createElement

return function(props, children)
	local theme = props.theme or Theme.new()
	local modalTarget = props.modalTarget

	return e(FrameworkWrapper, {
		theme = theme,
		modalTarget = modalTarget
	}, children)
end
