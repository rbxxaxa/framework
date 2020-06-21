local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

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

	self.absoluteSize, self.updateAbsoluteSize = Roact.createBinding(modalTarget.AbsoluteSize)
	self.absolutePosition, self.updateAbsolutePosition = Roact.createBinding(modalTarget.AbsolutePosition)

	self.maid = Maid.new()
	self.maid:GiveTask(self.state.modalTarget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self.updateAbsoluteSize(self.state.modalTarget.AbsoluteSize)
	end))
	self.maid:GiveTask(self.state.modalTarget:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self.updateAbsolutePosition(self.state.modalTarget.AbsolutePosition)
	end))
end

function ModalTargetController:render()
	return e(ModalTargetContext.Provider, {
		value = {
			target = self.state.modalTarget,
			absolutePositionBinding = self.absolutePosition,
			absoluteSizeBinding = self.absoluteSize,
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
