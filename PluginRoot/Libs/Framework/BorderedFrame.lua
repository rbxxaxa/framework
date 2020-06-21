local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local t = load("t")

local e = Roact.createElement

local BorderedFrame = Roact.PureComponent:extend("BorderedFrame")

local RECT_OFFSET = Vector2.new(0, 0)
local RECT_SIZE = Vector2.new(10, 10)
local SLICE_CENTER = Rect.new(4, 4, 5, 5)

-- TODO: is the "borderColor" and "borderColorBinding" a convention the framework should stick with?
BorderedFrame.defaultProps = {
	borderColor = Color3.new(0, 0, 0),
	backgroundColor = Color3.new(1, 1, 1),
	borderColorBinding = nil,
	backgroundColorBinding = nil,
	size = UDim2.new(0, 100, 0, 100),
	position = UDim2.new(0, 0, 0, 0),
	anchorPoint = Vector2.new(0, 0),
	layoutOrder = 0,
	zIndex = 1,
	visible = true,
	borderTransparency = 0,
	backgroundTransparency = 0,
	borderStyle = "Square",

	[Roact.Children] = nil,
}

local IBorderedFrame = t.strictInterface({
	borderColor = t.Color3,
	backgroundColor = t.Color3,
	borderColorBinding = t.optional(t.table),
	backgroundColorBinding = t.optional(t.table),
	size = t.UDim2,
	position = t.UDim2,
	anchorPoint = t.Vector2,
	layoutOrder = t.integer,
	zIndex = t.integer,
	visible = t.boolean,
	borderTransparency = t.numberConstrained(0, 1),
	backgroundTransparency = t.numberConstrained(0, 1),
	borderStyle = t.literal("Square", "Round"),

	[Roact.Children] = t.optional(t.table),
})

BorderedFrame.validateProps = function(props)
    return IBorderedFrame(props)
end

function BorderedFrame:render()
	local props = self.props
	local borderColor = props.borderColor
	local backgroundColor = props.backgroundColor
	local borderColorBinding = props.borderColorBinding
	local backgroundColorBinding = props.backgroundColorBinding
	local size = props.size
	local position = props.position
	local anchorPoint = props.anchorPoint
	local layoutOrder = props.layoutOrder
	local zIndex = props.zIndex
	local visible = props.visible
	local borderTransparency = props.borderTransparency
	local backgroundTransparency = props.backgroundTransparency
	local borderStyle = props.borderStyle

	local borderImage, fillImage
	if borderStyle == "Round" then
		borderImage = "rbxassetid://3008790403"
		fillImage = "rbxassetid://3008645364"
	elseif borderStyle == "Square" then
		borderImage = "rbxassetid://3460107198"
		fillImage = "rbxassetid://3460107337"
	end

	return e("ImageLabel", {
		Size = size,
		Position = position,
		LayoutOrder = layoutOrder,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		Visible = visible,
		BackgroundTransparency = 1,
		Image = fillImage,
		ImageTransparency = backgroundTransparency,
		ImageColor3 = backgroundColorBinding or backgroundColor,
		ScaleType = Enum.ScaleType.Slice,
		ImageRectOffset = RECT_OFFSET,
		ImageRectSize = RECT_SIZE,
		SliceCenter = SLICE_CENTER,
		[Roact.Ref] = props[Roact.Ref] or nil,
	}, {
		Border = e("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Image = borderImage,
			ImageColor3 = borderColorBinding or borderColor,
			ScaleType = Enum.ScaleType.Slice,
			ImageRectOffset = RECT_OFFSET,
			ImageRectSize = RECT_SIZE,
			SliceCenter = SLICE_CENTER,
			ImageTransparency = borderTransparency,
		}, props[Roact.Children])
	})
end

return BorderedFrame
