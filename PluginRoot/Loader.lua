local PluginRoot = script:FindFirstAncestor("PluginRoot")

local function load(path)
	assert(path, "Loader.load called with no arguments.")
	local current = PluginRoot
	for _, name in ipairs(string.split(path, "/")) do
		current = current:FindFirstChild(name, true)
		assert(current, ([[Path "%s" did not match a module.]]):format(path))
	end
	assert(current:IsA("ModuleScript"), ([[Path "%s" does not point to a module.]]):format(path))
	return require(current)
end

return {
	load = load,
}
