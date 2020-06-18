local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")

local e = Roact.createElement

local ShadowedFrame = Roact.PureComponent:extend("ShadowedFrame")

local RECT_OFFSET = Vector2.new(0, 0)
local RECT_SIZE = Vector2.new(10, 10)
local SLICE_CENTER = Rect.new(4, 4, 5, 5)

ShadowedFrame.defaultProps = {
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(0, 0, 0, 0),
	shadowSizeOffset = Vector2.new(8, 8),
	shadowPositionOffset = Vector2.new(-3, -3),
	anchorPoint = Vector2.new(0, 0),
	layoutOrder = 0,
	zIndex = 1,
	visible = true,

	[Roact.Children] = nil,
}

local IShadowedFrame = t.strictInterface({
	size = t.UDim2,
	position = t.UDim2,
	shadowSizeOffset = t.Vector2,
	shadowPositionOffset = t.Vector2,
	anchorPoint = t.Vector2,
	layoutOrder = t.integer,
	zIndex = t.integer,
	visible = t.boolean,

	[Roact.Children] = t.optional(t.table),
})

ShadowedFrame.validateProps = function(props)
    return IShadowedFrame(props)
end

function ShadowedFrame:render()
	local props = self.props
	local size = props.size
	local position = props.position
	local anchorPoint = props.AnchorPoint
	local layoutOrder = props.LayoutOrder
	local zIndex = props.ZIndex
	local visible = props.Visible
	local shadowSizeOffset = props.shadowSizeOffset
	local shadowPositionOffset = props.shadowPositionOffset

	return e("Frame", {
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		Visible = visible,
	}, {
		Shadow = e("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0) + UDim2.fromOffset(shadowSizeOffset.X, shadowSizeOffset.Y),
			Position = UDim2.fromOffset(shadowPositionOffset.X, shadowPositionOffset.Y),
			BackgroundTransparency = 1,
			ZIndex = 1,
			Image = "rbxassetid://5184882739",
			ImageColor3 = Color3.new(0, 0, 0),
			ScaleType = Enum.ScaleType.Slice,
			ImageRectOffset = RECT_OFFSET,
			ImageRectSize = RECT_SIZE,
			SliceCenter = SLICE_CENTER,
			ImageTransparency = 0,
		}),

		Contents = e("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, props[Roact.Children])
	})
end

return ShadowedFrame
