local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local Oyrc = load("Oyrc")

local e = Roact.createElement

-- TODO: Use a constants module for this.
local SCROLL_BAR_THICKNESS = 12

local ScrollingVerticalList = Roact.PureComponent:extend("ScrollingVerticalList")

ScrollingVerticalList.defaultProps = {
	position = UDim2.new(),
	size = UDim2.new(0, 100, 0, 100),
	layoutOrder = 0,
	visible = true,
	paddingTop = 4,
	paddingRight = 4,
	paddingBottom = 4,
	paddingLeft = 4,
	paddingList = 4,
	contentBackgroundColor = nil,
}

local IScrollingVerticalList = t.interface({
	position = t.UDim2,
	size = t.UDim2,
	layoutOrder = t.integer,
	visible = t.boolean,
	paddingTop = t.integer,
	paddingRight = t.integer,
	paddingBottom = t.integer,
	paddingLeft = t.integer,
	paddingList = t.integer,
	contentBackgroundColor = t.optional(t.Color3),
})

ScrollingVerticalList.validateProps = function(props)
    return IScrollingVerticalList(props)
end

function ScrollingVerticalList:init()
	self.contentHeight, self.updateContentHeight = Roact.createBinding(0)
end

function ScrollingVerticalList:render()
	local props = self.props
	local position = props.position
	local size = props.size
	local layoutOrder = props.layoutOrder
	local visible = props.visible
	local paddingTop = props.paddingTop
	local paddingRight = props.paddingRight
	local paddingBottom = props.paddingBottom
	local paddingLeft = props.paddingLeft
	local paddingList = props.paddingList
	local contentBackgroundColor = props.contentBackgroundColor

	-- TODO: Theme me
	local theme = {
		contentBackground = Color3.new(0.8, 0.8, 0.8),
		barBackground = Color3.new(0, 0, 0),
		bar = Color3.new(1, 1, 1),
	}

	local children = props[Roact.Children] ~= nil and Oyrc.Dictionary.join(props[Roact.Children], {
		ScrollingVerticalListUIListLayout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, paddingList),
			[Roact.Change.AbsoluteContentSize] = function(rbx)
				local contentHeight = rbx.AbsoluteContentSize.Y
				self.updateContentHeight(contentHeight)
			end,
		}),

		ScrollingVerticalListUIPadding = e("UIPadding", {
			PaddingTop = UDim.new(0, paddingTop),
			PaddingRight = UDim.new(0, paddingRight + SCROLL_BAR_THICKNESS),
			PaddingBottom = UDim.new(0, paddingBottom),
			PaddingLeft = UDim.new(0, paddingLeft),
		})
	})

	-- TODO: Use modal to disable scrolling when necessary
	return e("Frame", {
		BackgroundTransparency = 1,
		Position = position,
		Size = size,
		LayoutOrder = layoutOrder,
		Visible = visible,
	}, {
		ContentBackground = e("Frame", {
			Size = UDim2.new(1, -SCROLL_BAR_THICKNESS, 1, 0),
			BackgroundColor3 = contentBackgroundColor or theme.contentBackground,
			BorderSizePixel = 0,
		}),

		ScrollbarBackground = e("Frame", {
			Size = UDim2.new(0, SCROLL_BAR_THICKNESS, 1, 0),
			Position = UDim2.new(1, -SCROLL_BAR_THICKNESS, 0, 0),
			BackgroundColor3 = theme.barBackground,
			BorderSizePixel = 0,
		}),

		ScrollingFrame = e("ScrollingFrame",{
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 2,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			VerticalScrollBarInset = Enum.ScrollBarInset.Always,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = SCROLL_BAR_THICKNESS,
			CanvasSize = self.contentHeight:map(function(height)
				return UDim2.new(1, 0, 0, height + paddingTop + paddingBottom)
			end),
			TopImage = "rbxassetid://2245002518",
			BottomImage = "rbxassetid://2245002518",
			MidImage = "rbxassetid://2245002518",
		}, children)
	})
end

return ScrollingVerticalList
