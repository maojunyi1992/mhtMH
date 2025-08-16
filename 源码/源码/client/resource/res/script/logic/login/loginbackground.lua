require "logic.dialog"

loginBg = {}
setmetatable(loginBg, Dialog)
loginBg.__index = loginBg

local spineWidth = 3584
local spineHeight = 2268

local _instance
function loginBg.getInstance()
	if not _instance then
		_instance = loginBg:new()
		_instance:OnCreate()
	end
	return _instance
end

function loginBg.getInstanceAndShow()
	if not _instance then
		_instance = loginBg:new()
		_instance:OnCreate()
	else
		_instance:SetVisible(true)
	end
	return _instance
end

function loginBg.getInstanceNotCreate()
	return _instance
end

function loginBg.DestroyDialog()
	if _instance then
        if _instance.spine then
            _instance.spine:delete()
            _instance.spine = nil
        end
		if not _instance.m_bCloseIsHide then
			_instance:OnClose()
			_instance = nil
		else
			_instance:ToggleOpenClose()
		end
	end
end

function loginBg.ToggleOpenClose()
	if not _instance then
		_instance = loginBg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function loginBg.GetLayoutFileName()
	return "gugedonghua.layout"
end

function loginBg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, loginBg)
	return self
end

function loginBg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.bg = winMgr:getWindow("gugedonghua")
    local pos = self.bg:GetScreenPosOfCenter()
	local loc = Nuclear.NuclearPoint(pos.x, pos.y)
    self.spine = UISpineSprite:new("denglu")
    self.spine:SetUILocation(loc)
    self.bg:getGeometryBuffer():setRenderEffect(GameUImanager:createXPRenderEffect(0, loginBg.performPostRenderFunctions))
 	local xscale = Nuclear.GetEngine():GetLogicWidth() / 3584
    local yscale = Nuclear.GetEngine():GetLogicHeight() / 2268
    local scale = math.max(xscale, yscale)
    self.spine:SetUIScale(scale)
end

function loginBg.performPostRenderFunctions()
	if loginBg:getInstance().spine then
		loginBg:getInstance().spine:RenderUISprite()
	end
end

return loginBg