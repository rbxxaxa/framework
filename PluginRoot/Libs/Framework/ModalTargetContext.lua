local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Roact = load("Roact")
local Maid = load("Maid")
local Oyrc = load("Oyrc")

local e = Roact.createElement

local ModalTargetContext = Roact.createContext()

local ModalTargetController = Roact.Component:extend("ModalTargetController")

function ModalTargetController:init()
	local modalTarget = self.props.modalTarget
	self.state = {
		modalTarget = modalTarget,
	}

	local layerCollector = modalTarget:IsA("LayerCollector") and modalTarget
		or modalTarget:FindFirstAncestorWhichIsA("LayerCollector")
	local getMousePosition
	if layerCollector then
		if layerCollector:IsA("PluginGui") then
			getMousePosition = function()
				return layerCollector:GetRelativeMousePosition()
			end
		elseif layerCollector:IsA("ScreenGui") then
			getMousePosition = function()
				return UserInputService:GetMouseLocation()
			end
		else
			error("ModalTarget only supported for GUI parented under PluginGui or ScreenGui.")
		end
	else
		error("ModalTarget must be parented under PluginGui or ScreenGui.")
	end

	self.absoluteSize, self.updateAbsoluteSize = Roact.createBinding(modalTarget.AbsoluteSize)
	self.absolutePosition, self.updateAbsolutePosition = Roact.createBinding(modalTarget.AbsolutePosition)
	self.mousePosition, self.updateMousePosition = Roact.createBinding(getMousePosition())
	self.absoluteSizeChangedEvent = Instance.new("BindableEvent")
	self.absolutePositionChangedEvent = Instance.new("BindableEvent")
	self.mousePositionChangedEvent = Instance.new("BindableEvent")

	self.maid = Maid.new()
	self.maid:GiveTask(self.state.modalTarget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.updateAbsoluteSize(modalTarget.AbsoluteSize)
		self.absoluteSizeChangedEvent:Fire(modalTarget.AbsoluteSize)
	end))
	self.maid:GiveTask(self.state.modalTarget:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self.updateAbsolutePosition(modalTarget.AbsolutePosition)
		self.absolutePositionChangedEvent:Fire(modalTarget.AbsolutePosition)
	end))
	self.maid:GiveTask(RunService.RenderStepped:Connect(function()
		local mousePosition = getMousePosition()
		if mousePosition ~= self.mousePosition:getValue() then
			self.updateMousePosition(mousePosition)
			self.mousePositionChangedEvent:Fire(mousePosition)
		end
	end))

	self.subscribeToAbsolutePositionChanged = function(callback)
		local conn = self.absolutePositionChangedEvent.Event:Connect(callback)
		return function()
			conn:Disconnect()
		end
	end
	self.subscribeToAbsolutePositionChanged = function(callback)
		local conn = self.absolutePositionChangedEvent.Event:Connect(callback)
		return function()
			conn:Disconnect()
		end
	end
	self.subscribeToMousePositionChanged = function(callback)
		local conn = self.mousePositionChangedEvent.Event:Connect(callback)
		return function()
			conn:Disconnect()
		end
	end
end

function ModalTargetController:render()
	return e(ModalTargetContext.Provider, {
		value = {
			target = self.state.modalTarget,
			absolutePositionBinding = self.absolutePosition,
			absoluteSizeBinding = self.absoluteSize,
			mousePositionBinding = self.mousePosition,
			subscribeToAbsolutePositionChanged = self.subscribeToAbsolutePositionChanged,
			subscribeToAbsoluteSizeChanged = self.subscribeToAbsoluteSizeChanged,
			subscribeToMousePositionChanged = self.subscribeToMousePositionChanged,
		},
	}, self.props[Roact.Children])
end

function ModalTargetController:willUnmount()
	self.maid:Destroy()
end

local function withController(props, children)
	return e(ModalTargetController, props, children)
end

local function withConsumer(render)
	return e(ModalTargetContext.Consumer, {
		render = function(theme)
			return render(theme)
		end
	})
end

local function connect(component, mapValueToProps)
	local newComponent = Roact.PureComponent:extend("ModalTargetContextConnected" .. tostring(component))

	function newComponent:render()
		return withConsumer(function(theme)
			local props = self.props
			props = Oyrc.Dictionary.join(props, mapValueToProps(theme))
			return e(component, props)
		end)
	end

	return newComponent
end

return {
	withController = withController,
	withConsumer = withConsumer,
	connect = connect,
}
