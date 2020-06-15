local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Theme = load("Framework/Theme")
local ThemeContext = load("Framework/ThemeContext")

return function(children)
	local theme = Theme.new()

	return ThemeContext.withController({
		theme = theme
	}, children)
end
