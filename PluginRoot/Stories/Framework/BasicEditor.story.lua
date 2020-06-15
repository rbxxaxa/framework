local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local ScrollingVerticalList = load("Framework/ScrollingVerticalList")
local TextButton = load("Framework/TextButton")
local TitledSection = load("Framework/TitledSection")
local TextDropdown = load("Framework/TextDropdown")
local StoryWrapper = load("Stories/StoryWrapper")

local e = Roact.createElement

return function(target)
	Roact.setGlobalConfig({
		typeChecks = true,
		propValidation = true,
	})

	local BasicEditor = Roact.Component:extend("BasicEditor")

	function BasicEditor:init()
	end

	function BasicEditor:render()
		return e(ScrollingVerticalList, {
			size = UDim2.new(1, 0, 1, 0),
		}, {
			Section1 = e(TitledSection, {
				title = "SECTION 1",
				width = UDim.new(1, 0),
				layoutOrder = 1,
			}, {
				Dropdown1 = e(TextDropdown, {
					size = UDim2.new(1, 0, 0, 24),
					choiceDatas = {
						1, 2, 3, 4, 5, 6,
					},
					choiceTexts = {
						"1", "2", "3", "4", "5", "6",
					},
					buttonText = "Select a choice.",
					layoutOrder = 1,
				}),

				Dropdown2 = e(TextDropdown, {
					size = UDim2.new(1, 0, 0, 24),
					choiceDatas = {
						"A", "B", "C", "D", "E", "E",
					},
					choiceTexts = {
						"A", "B", "C", "D", "E", "E",
					},
					buttonText = "Select a choice.",
					layoutOrder = 2,
				})
			}),

			Section2 = e(TitledSection, {
				title = "SECTION 2",
				width = UDim.new(1, 0),
				layoutOrder = 2,
			}, {
				List = e(ScrollingVerticalList, {
					size = UDim2.new(1, 0, 0, 200),
				}, (function()
					local children = {}

					for i = 1, 5 do
						children[i] = e(TextButton, {
							size = UDim2.new(1, 0, 0, 24),
							text = "Button " .. i,
							layoutOrder = i,
						})
					end

					for i = 6, 10 do
						children[i] = e(TextDropdown, {
							size = UDim2.new(1, 0, 0, 24),
							choiceDatas = {
								"A", "B", "C", "D", "E", "E",
							},
							choiceTexts = {
								"A", "B", "C", "D", "E", "E",
							},
							buttonText = "Select a choice.",
							layoutOrder = i,
						})
					end

					return children
				end)())
			}),

			BigButton1 = e(TextButton, {
				size = UDim2.new(1, 0, 0, 48),
				text = "Big Button",
				layoutOrder = 3,
			}),

			BigButton2 = e(TextButton, {
				size = UDim2.new(1, 0, 0, 48),
				text = "Big Button",
				layoutOrder = 4,
			})
		})
	end

	local handle = Roact.mount(StoryWrapper(e(BasicEditor)), target)

	return function()
		Roact.unmount(handle)
	end
end
