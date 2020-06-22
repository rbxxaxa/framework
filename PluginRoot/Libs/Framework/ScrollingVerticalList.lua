local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")
local ThemeContext = load("Framework/ThemeContext")

local e = Roact.createElement

-- TODO: Use a constants module for this.
local SCROLL_BAR_THICKNESS = 12

local ScrollingVerticalList = Roact.PureComponent:extend("ScrollingVerticalList")

ScrollingVerticalList.defaultProps = {
	position = UDim2.new(),
	size = UDim2.new(0, 100, 0, 100),
	layoutOrder = 0,
	anchorPoint = Vector2.new(),
	zIndex = 1,
	paddingTop = 4,
	paddingRight = 4,
	paddingBottom = 4,
	paddingLeft = 4,
	paddingList = 4,
	contentBackgroundColor = nil,

	[Roact.Children] = nil,
}

local IScrollingVerticalList = t.strictInterface({
	position = t.UDim2,
	size = t.UDim2,
	layoutOrder = t.integer,
	anchorPoint = t.Vector2,
	zIndex = t.integer,
	paddingTop = t.integer,
	paddingRight = t.integer,
	paddingBottom = t.integer,
	paddingLeft = t.integer,
	paddingList = t.integer,
	contentBackgroundColor = t.optional(t.Color3),

	[Roact.Children] = t.optional(t.table),
})

ScrollingVerticalList.validateProps = function(props)
    return IScrollingVerticalList(props)
end

function ScrollingVerticalList:init()
	self.contentHeight, self.updateContentHeight = Roact.createBinding(0)
	self.paddingTop, self.updatePaddingTop = Roact.createBinding(self.props.paddingTop)
	self.paddingBottom, self.updatePaddingBottom = Roact.createBinding(self.props.paddingBottom)

	self.onAbsoluteContentSizeChanged = function(rbx)
		local contentHeight = rbx.AbsoluteContentSize.Y
		self.updateContentHeight(contentHeight)
	end

	self.canvasSize = Roact.joinBindings({
		contentHeight = self.contentHeight,
		paddingTop = self.paddingTop,
		paddingBottom = self.paddingBottom,
	}):map(function(joined)
		return UDim2.new(1, 0, 0, joined.contentHeight + joined.paddingTop + joined.paddingBottom)
	end)
end

function ScrollingVerticalList:render()
	local props = self.props
	local position = props.position
	local size = props.size
	local layoutOrder = props.layoutOrder
	local anchorPoint = props.anchorPoint
	local zIndex = props.zIndex
	local paddingTop = props.paddingTop
	local paddingRight = props.paddingRight
	local paddingBottom = props.paddingBottom
	local paddingLeft = props.paddingLeft
	local paddingList = props.paddingList
	local contentBackgroundColor = props.contentBackgroundColor

	return ThemeContext.withConsumer(function(theme)
		local colors = theme.colors

		-- TODO: Use modal to disable scrolling when necessary
		return e("Frame", {
			BackgroundTransparency = 1,
			Position = position,
			Size = size,
			LayoutOrder = layoutOrder,
			AnchorPoint = anchorPoint,
			ZIndex = zIndex,
		}, {
			ContentBackground = e("Frame", {
				Size = UDim2.new(1, -SCROLL_BAR_THICKNESS, 1, 0),
				BackgroundColor3 = contentBackgroundColor or colors.ScrollingFrameContentBackground.Default,
				BorderSizePixel = 0,
			}),

			ScrollbarBackground = e("Frame", {
				Size = UDim2.new(0, SCROLL_BAR_THICKNESS, 1, 0),
				Position = UDim2.new(1, -SCROLL_BAR_THICKNESS, 0, 0),
				BackgroundColor3 = colors.ScrollBarBackground.Default,
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
				CanvasSize = self.canvasSize,
				TopImage = "rbxassetid://2245002518",
				BottomImage = "rbxassetid://2245002518",
				MidImage = "rbxassetid://2245002518",
				ScrollBarImageColor3 = colors.ScrollBar.Default,
			}, {
				Roact.createFragment({
					ScrollingVerticalListUIListLayout = e("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, paddingList),
						[Roact.Change.AbsoluteContentSize] = self.onAbsoluteContentSizeChanged,
					}),

					ScrollingVerticalListUIPadding = e("UIPadding", {
						PaddingTop = UDim.new(0, paddingTop),
						PaddingRight = UDim.new(0, paddingRight + SCROLL_BAR_THICKNESS),
						PaddingBottom = UDim.new(0, paddingBottom),
						PaddingLeft = UDim.new(0, paddingLeft),
					}),

					props[Roact.Children] and Roact.createFragment(props[Roact.Children]) or nil,
				})
			})
		})
	end)
end

function ScrollingVerticalList:didUpdate()
	self.updatePaddingBottom(self.props.paddingBottom)
	self.updatePaddingTop(self.props.paddingTop)
end

return ScrollingVerticalList
