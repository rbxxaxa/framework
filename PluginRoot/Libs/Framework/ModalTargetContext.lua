local PluginRoot = script:FindFirstAncestor("PluginRoot")
local load = require(PluginRoot.Loader).load

local Roact = load("Roact")
local Maid = load("Maid")

local e = Roact.createElement

local ModalTargetContext = Roact.createContext()

local ModalTargetController = Roact.Component:extend("ModalTargetController")

function ModalTargetController:init()
	self.state = {
		modalTarget = self.props.target,
	}
	self.maid = Maid.new()
end

function ModalTargetController:didMount()
	self.maid:GiveTask(self.modalTarget:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:setState({})
	end))
	self.maid:GiveTask(self.modalTarget:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:setState({})
	end))
end

function ModalTargetController:render()
	return e(ModalTargetContext.Provider, {
		value = {
			target = self.props.modalTarget,
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

return {
	withController = withController,
	withConsumer = withConsumer,
}

